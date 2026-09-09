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
      throw StateError('Enter a valid email address.');
    }

    try {
      if (_auth.currentUser == null) {
        await _auth.signInAnonymously();
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'operation-not-allowed') {
        throw StateError(
          'Anonymous Auth is disabled. Enable it in Firebase Console → Authentication → Sign-in method → Anonymous.',
        );
      }
      throw StateError('Sign-in failed: ${e.message ?? e.code}');
    }

    final id = EmailUtils.docId(normalized);
    final ref = _users.doc(id);

    try {
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
      } else {
        final color = avatarColorFromEmail(normalized);
        await ref.set({
          'email': normalized,
          'displayName': name,
          'avatarColor': color.toARGB32(),
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
          'lastAuthUid': _auth.currentUser?.uid,
        });
      }

      return AppUser.fromDoc(await ref.get());
    } on FirebaseException catch (e) {
      if (e.code == 'not-found' || e.code == 'unavailable') {
        throw StateError(
          'Cloud Firestore is not set up. Create the default database in Firebase Console → Firestore.',
        );
      }
      if (e.code == 'permission-denied') {
        throw StateError(
          'Firestore permission denied. Deploy rules or use test mode temporarily.',
        );
      }
      throw StateError('Firestore error: ${e.message ?? e.code}');
    }
  }

  Future<void> signOut() => _auth.signOut();
}
