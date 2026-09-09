import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_chat_application/core/constants/firebase_paths.dart';

class TypingService {
  TypingService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _typing(String roomId) =>
      _db.collection(FirebasePaths.typing(roomId));

  Stream<List<String>> watchTypingNames({
    required String roomId,
    required String currentUserId,
  }) {
    return _typing(roomId).snapshots().map((snap) {
      final now = DateTime.now();
      final names = <String>[];
      for (final doc in snap.docs) {
        if (doc.id == currentUserId) continue;
        final data = doc.data();
        if (data['isTyping'] != true) continue;
        final updated = data['updatedAt'];
        final at = updated is Timestamp ? updated.toDate() : null;
        if (at == null || now.difference(at) > const Duration(seconds: 5)) {
          continue;
        }
        final name = data['displayName'] as String? ?? 'Someone';
        names.add(name);
      }
      return names;
    });
  }

  Future<void> setTyping({
    required String roomId,
    required String userId,
    required String displayName,
    required bool isTyping,
  }) async {
    await _typing(roomId).doc(userId).set({
      'isTyping': isTyping,
      'displayName': displayName,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
