import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';
import 'package:realtime_chat_application/core/models/chat_message.dart';
import 'package:realtime_chat_application/core/models/room_member.dart';
import 'package:realtime_chat_application/core/models/session_args.dart';
import 'package:realtime_chat_application/core/services/fcm_service.dart';
import 'package:realtime_chat_application/core/services/message_service.dart';
import 'package:realtime_chat_application/core/services/presence_service.dart';
import 'package:realtime_chat_application/core/services/typing_service.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
  ChatController({
    MessageService? messageService,
    PresenceService? presenceService,
    TypingService? typingService,
    FcmService? fcmService,
  })  : _messages = messageService ?? MessageService(),
        _presence = presenceService ?? PresenceService(),
        _typing = typingService ?? TypingService(),
        _fcm = fcmService ?? FcmService();

  final MessageService _messages;
  final PresenceService _presence;
  final TypingService _typing;
  final FcmService _fcm;

  final messages = <ChatMessage>[].obs;
  final members = <RoomMember>[].obs;
  final typingUsers = <String>[].obs;

  final textController = TextEditingController();
  final scrollController = ScrollController();

  final unreadCount = 0.obs;
  final showJumpToLatest = false.obs;
  final isAtBottom = true.obs;
  final isLoadingMore = false.obs;
  final hasMore = true.obs;
  final isReconnecting = false.obs;

  /// Index in [messages] for unread divider, or -1.
  final unreadDividerIndex = (-1).obs;

  late SessionArgs session;
  var _isInBackground = false;
  var _bootstrapped = false;

  final _pendingClientIds = <String>{};
  Timer? _typingTimer;
  StreamSubscription? _messagesSub;
  StreamSubscription? _membersSub;
  StreamSubscription? _typingSub;
  StreamSubscription? _connectivitySub;
  StreamSubscription? _tokenSub;

  String get roomTitle => session.roomName;
  String get roomId => session.roomId;
  String get userId => session.user.id;
  int get onlineCount => members.where((m) => m.isOnline).length;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    final args = Get.arguments;
    if (args is! SessionArgs) {
      Get.offAllNamed(AppRoutes.auth);
      return;
    }
    session = args;

    scrollController.addListener(_onScroll);
    _presence.setOnline(roomId: roomId, userId: userId, online: true);
    _bindStreams();
    _setupFcm();
    _setupConnectivity();
  }

  Future<void> _setupFcm() async {
    await _fcm.init();
    final token = await _fcm.getToken();
    if (token != null) {
      await _presence.saveFcmToken(
        roomId: roomId,
        userId: userId,
        token: token,
      );
    }
    _tokenSub = _fcm.onTokenRefresh.listen((token) {
      _presence.saveFcmToken(roomId: roomId, userId: userId, token: token);
    });
  }

  void _setupConnectivity() {
    _connectivitySub = Connectivity().onConnectivityChanged.listen((results) {
      final offline = results.every((r) => r == ConnectivityResult.none);
      isReconnecting.value = offline;
      if (!offline) {
        _presence.setOnline(roomId: roomId, userId: userId, online: true);
        if (_bootstrapped) {
          unawaited(_resyncAfterReconnect());
        }
      }
    });
  }

  /// Reloads the newest page and pages backward until history is contiguous.
  Future<void> _resyncAfterReconnect() async {
    try {
      final page = await _messages.loadLatestPage(
        roomId: roomId,
        currentUserId: userId,
      );
      _onRemoteMessages(page);
      await _backfillGaps(page);
      isReconnecting.value = false;
    } catch (_) {
      isReconnecting.value = true;
    }
  }

  Future<void> _backfillGaps(List<ChatMessage> latestPage) async {
    if (latestPage.isEmpty || messages.isEmpty) return;
    var before = latestPage.first.createdAt;
    final known = messages.map((m) => m.clientId).toSet();
    final oldestWanted = messages.first.createdAt;
    for (var i = 0; i < 12; i++) {
      final older = await _messages.loadOlderPage(
        roomId: roomId,
        currentUserId: userId,
        before: before,
      );
      if (older.isEmpty) {
        hasMore.value = false;
        break;
      }
      final missing = older.where((m) => !known.contains(m.clientId)).toList();
      if (missing.isNotEmpty) {
        for (final m in missing) {
          known.add(m.clientId);
        }
        final merged = <ChatMessage>[...messages, ...missing]
          ..sort((a, b) {
            final c = a.createdAt.compareTo(b.createdAt);
            if (c != 0) return c;
            return a.clientId.compareTo(b.clientId);
          });
        messages.assignAll(merged);
      }
      before = older.first.createdAt;
      if (!before.isAfter(oldestWanted)) break;
    }
  }

  void _bindStreams() {
    _messagesSub?.cancel();
    _messagesSub = _messages
        .watchLatestPage(roomId: roomId, currentUserId: userId)
        .listen(_onRemoteMessages, onError: (e) {
      isReconnecting.value = true;
    });

    _membersSub?.cancel();
    _membersSub = _presence.watchMembersWithHeartbeat(roomId).listen((list) {
      members.assignAll(_applyUnreadFlags(list));
    });

    _typingSub?.cancel();
    _typingSub = _typing
        .watchTypingNames(roomId: roomId, currentUserId: userId)
        .listen(typingUsers.assignAll);
  }

  List<RoomMember> _applyUnreadFlags(List<RoomMember> list) {
    if (unreadCount.value <= 0) {
      return list.map((m) => m.copyWith(hasUnread: false)).toList();
    }
    final unreadSenderIds = messages
        .skip(unreadDividerIndex.value < 0 ? messages.length : unreadDividerIndex.value)
        .where((m) => !m.isMine && !m.isSystem)
        .map((m) => m.senderId)
        .toSet();
    return list
        .map((m) => m.copyWith(hasUnread: unreadSenderIds.contains(m.id)))
        .toList();
  }

  void _onRemoteMessages(List<ChatMessage> remotePage) {
    isReconnecting.value = false;

    for (final remote in remotePage) {
      _pendingClientIds.remove(remote.clientId);
    }

    final olderKeep = <ChatMessage>[];
    for (final local in messages) {
      final inRemote = remotePage.any(
        (r) => r.id == local.id || r.clientId == local.clientId,
      );
      if (inRemote) continue;
      if (local.id.startsWith('local_') &&
          _pendingClientIds.contains(local.clientId)) {
        olderKeep.add(local);
        continue;
      }
      if (remotePage.isNotEmpty &&
          local.createdAt.isBefore(remotePage.first.createdAt)) {
        olderKeep.add(local);
      }
    }

    final merged = <ChatMessage>[...olderKeep, ...remotePage]
      ..sort((a, b) {
        final c = a.createdAt.compareTo(b.createdAt);
        if (c != 0) return c;
        return a.clientId.compareTo(b.clientId);
      });

    final previousLastId = messages.isEmpty ? null : messages.last.id;
    final wasAtBottom = isAtBottom.value;
    messages.assignAll(merged);

    if (!_bootstrapped) {
      _bootstrapped = true;
      WidgetsBinding.instance
          .addPostFrameCallback((_) => _scrollToBottom(force: true));
      _markRead();
      return;
    }

    final newest = messages.isEmpty ? null : messages.last;
    final isNewIncoming = newest != null &&
        newest.id != previousLastId &&
        !newest.isMine &&
        !newest.isSystem;

    if (isNewIncoming) {
      if (!wasAtBottom || _isInBackground) {
        if (unreadDividerIndex.value == -1) {
          final idx = messages.indexWhere((m) => m.id == newest.id);
          unreadDividerIndex.value = idx < 0 ? messages.length - 1 : idx;
        }
        unreadCount.value += 1;
        showJumpToLatest.value = !wasAtBottom;
        members.assignAll(_applyUnreadFlags(members));

        if (_isInBackground) {
          _fcm.showLocalNotification(
            senderName: newest.senderName,
            roomName: roomTitle,
            body: newest.body,
          );
        }
      } else {
        _scrollToBottom();
        _markRead();
      }
    } else if (wasAtBottom) {
      _scrollToBottom();
      _markRead();
    }
  }

  Future<void> loadOlderMessages() async {
    if (isLoadingMore.value || !hasMore.value || messages.isEmpty) return;
    isLoadingMore.value = true;
    try {
      final oldest = messages.first;
      final older = await _messages.loadOlderPage(
        roomId: roomId,
        currentUserId: userId,
        before: oldest.createdAt,
      );
      if (older.isEmpty) {
        hasMore.value = false;
      } else {
        final existingIds = messages.map((m) => m.clientId).toSet();
        final toInsert =
            older.where((m) => !existingIds.contains(m.clientId)).toList();
        messages.insertAll(0, toInsert);
        if (unreadDividerIndex.value >= 0) {
          unreadDividerIndex.value += toInsert.length;
        }
      }
    } finally {
      isLoadingMore.value = false;
    }
  }

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 48;
    isAtBottom.value = atBottom;
    showJumpToLatest.value = !atBottom && unreadCount.value > 0;

    if (position.pixels <= 48) {
      loadOlderMessages();
    }

    if (atBottom) {
      _clearUnread();
      _markRead();
    }
  }

  void _clearUnread() {
    if (unreadCount.value == 0 && unreadDividerIndex.value == -1) return;
    unreadCount.value = 0;
    unreadDividerIndex.value = -1;
    showJumpToLatest.value = false;
    members.assignAll(_applyUnreadFlags(members));
  }

  Future<void> _markRead() async {
    await _presence.updateLastRead(roomId: roomId, userId: userId);
  }

  Future<void> jumpToLatest() async {
    await _scrollToBottom(force: true);
    _clearUnread();
    await _markRead();
  }

  void onComposerChanged(String value) {
    _typingTimer?.cancel();
    _typing.setTyping(
      roomId: roomId,
      userId: userId,
      displayName: session.user.displayName,
      isTyping: value.trim().isNotEmpty,
    );
    if (value.trim().isEmpty) return;
    _typingTimer = Timer(const Duration(seconds: 2), () {
      _typing.setTyping(
        roomId: roomId,
        userId: userId,
        displayName: session.user.displayName,
        isTyping: false,
      );
    });
  }

  Future<void> sendMessage() async {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final clientId = _messages.newClientId();
    final optimistic = ChatMessage(
      id: 'local_$clientId',
      senderId: userId,
      senderName: session.user.displayName,
      body: text,
      createdAt: DateTime.now(),
      clientId: clientId,
      isMine: true,
      deliveryStatus: DeliveryStatus.sending,
    );

    _pendingClientIds.add(clientId);
    messages.add(optimistic);
    textController.clear();
    onComposerChanged('');
    await _scrollToBottom(force: true);

    try {
      await _messages.sendText(
        roomId: roomId,
        senderId: userId,
        senderName: session.user.displayName,
        body: text,
        clientId: clientId,
      );
      final idx = messages.indexWhere((m) => m.clientId == clientId);
      if (idx != -1) {
        messages[idx] =
            messages[idx].copyWith(deliveryStatus: DeliveryStatus.sent);
      }
    } catch (_) {
      final idx = messages.indexWhere((m) => m.clientId == clientId);
      if (idx != -1) {
        messages.removeAt(idx);
      }
      _pendingClientIds.remove(clientId);
      Get.snackbar('Send failed', 'Message was not delivered. Try again.');
    }
  }

  Future<void> _scrollToBottom({bool force = false}) async {
    await Future<void>.delayed(const Duration(milliseconds: 40));
    if (!scrollController.hasClients) return;
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: force ? 1 : 200),
      curve: Curves.easeOut,
    );
    isAtBottom.value = true;
  }

  Future<void> leaveRoom() async {
    await _typing.setTyping(
      roomId: roomId,
      userId: userId,
      displayName: session.user.displayName,
      isTyping: false,
    );
    await _presence.setOnline(roomId: roomId, userId: userId, online: false);
    Get.offAllNamed(AppRoutes.auth);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isInBackground = state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached;

    if (_isInBackground) {
      _presence.setOnline(roomId: roomId, userId: userId, online: false);
    } else {
      _presence.setOnline(roomId: roomId, userId: userId, online: true);
      if (isAtBottom.value) {
        _clearUnread();
        _markRead();
      }
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _typingTimer?.cancel();
    _messagesSub?.cancel();
    _membersSub?.cancel();
    _typingSub?.cancel();
    _connectivitySub?.cancel();
    _tokenSub?.cancel();
    _presence.setOnline(roomId: roomId, userId: userId, online: false);
    _presence.dispose();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
