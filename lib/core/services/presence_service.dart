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

  CollectionReference<Map<String, dynamic>> _members(String roomId) =>
      _db.collection(FirebasePaths.members(roomId));

  Stream<List<RoomMember>> watchMembers(String roomId) {
    return _members(roomId).snapshots().map((snap) {
      final members = snap.docs.map(RoomMember.fromDoc).toList()
        ..sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return members.map((m) {
        final stale = m.lastReadAt == null
            ? false
            : false;
        // Online if flagged and heartbeat fresh (< 60s).
        final dataOnline = m.isOnline;
        return m.copyWith(isOnline: dataOnline && !stale);
      }).toList();
    });
  }

  /// Refined online check using lastSeen from raw docs.
  Stream<List<RoomMember>> watchMembersWithHeartbeat(String roomId) {
    return _members(roomId).snapshots().map((snap) {
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
    });
  }

  Future<void> joinRoom({
    required String roomId,
    required AppUser user,
  }) async {
    await _members(roomId).doc(user.id).set({
      'email': user.email,
      'displayName': user.displayName,
      'avatarColor': user.avatarColor.toARGB32(),
      'isOnline': true,
      'lastSeen': FieldValue.serverTimestamp(),
      'joinedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(const Duration(seconds: 25), (_) {
      setOnline(roomId: roomId, userId: user.id, online: true);
    });
  }

  Future<void> setOnline({
    required String roomId,
    required String userId,
    required bool online,
  }) async {
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
  }
}
