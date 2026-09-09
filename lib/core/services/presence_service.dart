import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_chat_application/core/constants/firebase_paths.dart';
import 'package:realtime_chat_application/core/models/app_user.dart';
import 'package:realtime_chat_application/core/models/room_member.dart';

class PresenceService {
  PresenceService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  Timer? _heartbeat;
  String? _roomId;
  String? _userId;
  var _wantOnline = false;

  CollectionReference<Map<String, dynamic>> _members(String roomId) =>
      _db.collection(FirebasePaths.members(roomId));

  /// Online if flagged and [lastSeen] is fresh. Re-emits on a timer so
  /// everyone sees a peer go offline even when no further writes arrive.
  Stream<List<RoomMember>> watchMembersWithHeartbeat(String roomId) {
    StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? sub;
    Timer? tick;
    QuerySnapshot<Map<String, dynamic>>? latest;

    late final StreamController<List<RoomMember>> controller;
    controller = StreamController<List<RoomMember>>(
      onListen: () {
        sub = _members(roomId).snapshots().listen((snap) {
          latest = snap;
          controller.add(_mapMembers(snap));
        });
        tick = Timer.periodic(const Duration(seconds: 8), (_) {
          if (latest != null) controller.add(_mapMembers(latest!));
        });
      },
      onCancel: () {
        sub?.cancel();
        tick?.cancel();
      },
    );
    return controller.stream;
  }

  List<RoomMember> _mapMembers(QuerySnapshot<Map<String, dynamic>> snap) {
    final now = DateTime.now();
    return snap.docs.map((doc) {
      final member = RoomMember.fromDoc(doc);
      final lastSeen = doc.data()['lastSeen'];
      final lastSeenAt = lastSeen is Timestamp ? lastSeen.toDate() : null;
      final fresh = lastSeenAt != null &&
          now.difference(lastSeenAt) < const Duration(seconds: 60);
      return member.copyWith(isOnline: member.isOnline && fresh);
    }).toList()
      ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
  }

  /// Returns `true` when this user has never been in the room before.
  Future<bool> joinRoom({
    required String roomId,
    required AppUser user,
  }) async {
    _roomId = roomId;
    _userId = user.id;
    final ref = _members(roomId).doc(user.id);
    final existing = await ref.get();
    final isFirstJoin = !existing.exists;

    final data = <String, dynamic>{
      'email': user.email,
      'displayName': user.displayName,
      'avatarColor': user.avatarColor.toARGB32(),
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
    };
    if (isFirstJoin) {
      data['joinedAt'] = FieldValue.serverTimestamp();
    }

    await ref.set(data, SetOptions(merge: true));
    await setOnline(roomId: roomId, userId: user.id, online: true);
    return isFirstJoin;
  }

  Future<void> setOnline({
    required String roomId,
    required String userId,
    required bool online,
  }) async {
    _roomId = roomId;
    _userId = userId;
    _wantOnline = online;
    await _writePresence(online: online);
    if (online) {
      _heartbeat ??= Timer.periodic(const Duration(seconds: 25), (_) {
        if (_wantOnline && _roomId != null && _userId != null) {
          _writePresence(online: true);
        }
      });
    } else {
      _heartbeat?.cancel();
      _heartbeat = null;
    }
  }

  Future<void> _writePresence({required bool online}) async {
    final roomId = _roomId;
    final userId = _userId;
    if (roomId == null || userId == null) return;
    await _members(roomId).doc(userId).set({
      'isOnline': online,
      'lastSeen': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> updateLastRead({
    required String roomId,
    required String userId,
  }) async {
    await _members(roomId).doc(userId).set({
      'lastReadAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<void> saveFcmToken({
    required String roomId,
    required String userId,
    required String token,
  }) async {
    await _members(roomId).doc(userId).set({
      'fcmTokens': FieldValue.arrayUnion([token]),
    }, SetOptions(merge: true));
  }

  void dispose() {
    _heartbeat?.cancel();
    _heartbeat = null;
    _wantOnline = false;
  }
}
