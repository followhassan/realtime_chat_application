import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_chat_application/core/utils/identity.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.displayName,
    required this.avatarColor,
  });

  final String id;
  final String email;
  final String displayName;
  final Color avatarColor;

  factory AppUser.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final email = (data['email'] as String?) ?? doc.id;
    return AppUser(
      id: doc.id,
      email: email,
      displayName: (data['displayName'] as String?) ??
          EmailUtils.defaultDisplayName(email),
      avatarColor: Color(
        (data['avatarColor'] as int?) ??
            avatarColorFromEmail(email).toARGB32(),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'displayName': displayName,
      'avatarColor': avatarColor.toARGB32(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }
}
