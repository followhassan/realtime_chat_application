import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:realtime_chat_application/core/constants/firebase_paths.dart';
import 'package:realtime_chat_application/core/models/app_user.dart';
import 'package:realtime_chat_application/core/utils/identity.dart';

class AuthService {
  AuthService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection(FirebasePaths.users);

  Future<AppUser> joinWithEmail({
    required String email,
    String? displayName,
  }) async {
    final normalized = EmailUtils.normalize(email);
    if (!EmailUtils.isValid(normalized)) {
      throw ArgumentError('Enter a valid email');
    }

    if (_auth.currentUser == null) {
      await _auth.signInAnonymously();
    }

    final id = EmailUtils.docId(normalized);
    final ref = _users.doc(id);
    final existing = await ref.get();

    final name = (displayName == null || displayName.trim().isEmpty)
        ? (existing.data()?['displayName'] as String? ??
            EmailUtils.defaultDisplayName(normalized))
        : displayName.trim();

    if (existing.exists) {
      await ref.set({
        'displayName': name,
        'email': normalized,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastAuthUid': _auth.currentUser?.uid,
      }, SetOptions(merge: true));
      return AppUser.fromDoc(await ref.get());
    }

    final color = avatarColorFromEmail(normalized);
    await ref.set({
      'email': normalized,
      'displayName': name,
      'avatarColor': color.toARGB32(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'lastAuthUid': _auth.currentUser?.uid,
    });

    return AppUser.fromDoc(await ref.get());
  }

  Future<void> signOut() => _auth.signOut();
}
