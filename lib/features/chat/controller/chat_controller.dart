import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';
import 'package:realtime_chat_application/core/models/chat_message.dart';
import 'package:realtime_chat_application/core/models/session_args.dart';
import 'package:realtime_chat_application/features/notification/controller/notification_controller.dart';
import 'package:realtime_chat_application/features/presence/controller/presence_controller.dart';
import 'package:realtime_chat_application/features/room/controller/room_controller.dart';

class ChatController extends GetxController with WidgetsBindingObserver {
  ChatController({
    required this.roomController,
    required this.presenceController,
    required this.notificationController,
  });

  final RoomController roomController;
  final PresenceController presenceController;
  final NotificationController notificationController;

  final messages = <ChatMessage>[].obs;
  final typingUsers = <String>[].obs;
  final textController = TextEditingController();
  final scrollController = ScrollController();

  final unreadCount = 0.obs;
  final showJumpToLatest = false.obs;
  final isAtBottom = true.obs;

  /// Index in [messages] where the unread divider should appear, or -1.
  final unreadDividerIndex = (-1).obs;

  late SessionArgs session;
  var _isInBackground = false;
  Timer? _deliveryTimer;
  Timer? _demoIncomingTimer;
  Timer? _typingClearTimer;
  var _idCounter = 0;

  String get roomTitle => roomController.roomName.value;
  int get onlineCount => presenceController.onlineCount;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    final args = Get.arguments;
    if (args is! SessionArgs) {
      Get.back();
      return;
    }
    session = args;

    roomController.bindSession(session);
    presenceController.bootstrap(session);
    notificationController.init();

    _seedInitialMessages();
    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    // Demo: incoming message for unread / typing / background notification.
    _demoIncomingTimer = Timer(const Duration(seconds: 8), _simulateIncoming);
  }

  void _seedInitialMessages() {
    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));
    messages.assignAll([
      ChatMessage(
        id: _nextId(),
        senderId: 'sam@example.com',
        senderName: 'Sam Chen',
        body: 'Room created — say hi when you join.',
        createdAt: yesterday.subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: _nextId(),
        senderId: 'alex@example.com',
        senderName: 'Alex Rivera',
        body: 'Looking forward to chatting here.',
        createdAt: yesterday.subtract(const Duration(hours: 1)),
      ),
      ChatMessage(
        id: _nextId(),
        senderId: 'system',
        senderName: 'system',
        body: '${session.displayName} joined the room',
        createdAt: now.subtract(const Duration(minutes: 12)),
        kind: MessageKind.system,
      ),
      ChatMessage(
        id: _nextId(),
        senderId: 'alex@example.com',
        senderName: 'Alex Rivera',
        body: 'Hey everyone — welcome in.',
        createdAt: now.subtract(const Duration(minutes: 10)),
      ),
      ChatMessage(
        id: _nextId(),
        senderId: 'alex@example.com',
        senderName: 'Alex Rivera',
        body: 'Feel free to say hello.',
        createdAt: now.subtract(const Duration(minutes: 9, seconds: 40)),
      ),
      ChatMessage(
        id: _nextId(),
        senderId: 'sam@example.com',
        senderName: 'Sam Chen',
        body: 'Hi! Glad to be here.',
        createdAt: now.subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        id: _nextId(),
        senderId: 'jordan@example.com',
        senderName: 'Jordan Lee',
        body: 'I may drop offline for a bit.',
        createdAt: now.subtract(const Duration(minutes: 6)),
      ),
      ChatMessage(
        id: _nextId(),
        senderId: 'alex@example.com',
        senderName: 'Alex Rivera',
        body: 'No worries — catch you later.',
        createdAt: now.subtract(const Duration(minutes: 5)),
      ),
    ]);
  }

  String _nextId() => 'msg_${_idCounter++}';

  void _onScroll() {
    if (!scrollController.hasClients) return;
    final position = scrollController.position;
    final atBottom = position.pixels >= position.maxScrollExtent - 48;
    isAtBottom.value = atBottom;
    showJumpToLatest.value = !atBottom && unreadCount.value > 0;

    if (atBottom) {
      _clearUnreadIfNewestVisible();
    }
  }

  void _clearUnreadIfNewestVisible() {
    if (!isAtBottom.value) return;
    if (unreadCount.value == 0 && unreadDividerIndex.value == -1) return;

    unreadCount.value = 0;
    unreadDividerIndex.value = -1;
    showJumpToLatest.value = false;
    presenceController.clearAllUnread();
  }

  Future<void> jumpToLatest() async {
    if (!scrollController.hasClients) return;
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOut,
    );
    _clearUnreadIfNewestVisible();
  }

  void onComposerChanged(String value) {
    // Local typing signal placeholder for realtime wiring.
  }

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    final message = ChatMessage(
      id: _nextId(),
      senderId: session.email,
      senderName: session.displayName,
      body: text,
      createdAt: DateTime.now(),
      isMine: true,
      deliveryStatus: DeliveryStatus.sending,
    );

    messages.add(message);
    textController.clear();
    _scrollToBottom();

    _deliveryTimer?.cancel();
    _deliveryTimer = Timer(const Duration(milliseconds: 600), () {
      final index = messages.indexWhere((m) => m.id == message.id);
      if (index == -1) return;
      messages[index] =
          messages[index].copyWith(deliveryStatus: DeliveryStatus.delivered);
    });
  }

  void _simulateIncoming() {
    typingUsers.assignAll(['Alex Rivera']);
    _typingClearTimer?.cancel();
    _typingClearTimer = Timer(const Duration(seconds: 2), () {
      typingUsers.clear();
      _appendIncoming(
        senderId: 'alex@example.com',
        senderName: 'Alex Rivera',
        body: 'Just checking in — are you still there?',
      );
    });
  }

  void _appendIncoming({
    required String senderId,
    required String senderName,
    required String body,
  }) {
    final wasAtBottom = isAtBottom.value;

    if (unreadDividerIndex.value == -1 && !wasAtBottom) {
      unreadDividerIndex.value = messages.length;
    }

    messages.add(
      ChatMessage(
        id: _nextId(),
        senderId: senderId,
        senderName: senderName,
        body: body,
        createdAt: DateTime.now(),
      ),
    );

    if (!wasAtBottom) {
      unreadCount.value += 1;
      showJumpToLatest.value = true;
      presenceController.markUnread(senderId, value: true);
    } else {
      _scrollToBottom();
      _clearUnreadIfNewestVisible();
    }

    if (_isInBackground) {
      notificationController.showMessageNotification(
        senderName: senderName,
        roomName: roomTitle,
        body: body,
      );
    }
  }

  void leaveRoom() {
    Get.offAllNamed(AppRoutes.auth);
  }

  Future<void> _scrollToBottom() async {
    await Future<void>.delayed(const Duration(milliseconds: 50));
    if (!scrollController.hasClients) return;
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
    isAtBottom.value = true;
    _clearUnreadIfNewestVisible();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isInBackground = state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden;

    if (state == AppLifecycleState.resumed && isAtBottom.value) {
      _clearUnreadIfNewestVisible();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    _deliveryTimer?.cancel();
    _demoIncomingTimer?.cancel();
    _typingClearTimer?.cancel();
    textController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
