import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_chat_application/core/constants/firebase_paths.dart';
import 'package:realtime_chat_application/core/models/chat_message.dart';
import 'package:uuid/uuid.dart';

class MessageService {
  MessageService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;
  final _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _messages(String roomId) =>
      _db.collection(FirebasePaths.messages(roomId));

  String newClientId() => _uuid.v4();

  Future<List<ChatMessage>> loadLatestPage({
    required String roomId,
    required String currentUserId,
    int limit = ChatLimits.pageSize,
  }) async {
    final snap = await _messages(roomId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    final items = snap.docs
        .map((d) => ChatMessage.fromDoc(d, currentUserId: currentUserId))
        .toList()
        .reversed
        .toList();
    return items;
  }

  Future<List<ChatMessage>> loadOlderPage({
    required String roomId,
    required String currentUserId,
    required DateTime before,
    int limit = ChatLimits.pageSize,
  }) async {
    final snap = await _messages(roomId)
        .orderBy('createdAt', descending: true)
        .startAfter([Timestamp.fromDate(before)])
        .limit(limit)
        .get();

    return snap.docs
        .map((d) => ChatMessage.fromDoc(d, currentUserId: currentUserId))
        .toList()
        .reversed
        .toList();
  }

  /// Live stream of the newest page (reconnect-safe via Firestore snapshots).
  Stream<List<ChatMessage>> watchLatestPage({
    required String roomId,
    required String currentUserId,
    int limit = ChatLimits.pageSize,
  }) {
    return _messages(roomId)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snap) {
      return snap.docs
          .map((d) => ChatMessage.fromDoc(d, currentUserId: currentUserId))
          .toList()
          .reversed
          .toList();
    });
  }

  Future<void> sendText({
    required String roomId,
    required String senderId,
    required String senderName,
    required String body,
    required String clientId,
  }) async {
    await _messages(roomId).add({
      'type': 'text',
      'senderId': senderId,
      'senderName': senderName,
      'body': body,
      'clientId': clientId,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> sendJoinAnnouncement({
    required String roomId,
    required String senderId,
    required String displayName,
  }) async {
    await _messages(roomId).add({
      'type': 'system',
      'senderId': senderId,
      'senderName': 'system',
      'body': '$displayName joined the room',
      'clientId': _uuid.v4(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
