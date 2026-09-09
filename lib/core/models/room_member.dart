import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:realtime_chat_application/core/utils/identity.dart';

class RoomMember {
  const RoomMember({
    required this.id,
    required this.name,
    required this.email,
    required this.avatarColor,
    this.isOnline = false,
    this.hasUnread = false,
    this.lastReadAt,
    this.fcmTokens = const [],
  });

  final String id;
  final String name;
  final String email;
  final Color avatarColor;
  final bool isOnline;
  final bool hasUnread;
  final DateTime? lastReadAt;
  final List<String> fcmTokens;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  factory RoomMember.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? {};
    final email = (data['email'] as String?) ?? doc.id;
    final lastRead = data['lastReadAt'];
    return RoomMember(
      id: doc.id,
      name: (data['displayName'] as String?) ??
          EmailUtils.defaultDisplayName(email),
      email: email,
      avatarColor: Color(
        (data['avatarColor'] as int?) ??
            avatarColorFromEmail(email).toARGB32(),
      ),
      isOnline: data['isOnline'] == true,
      lastReadAt: lastRead is Timestamp ? lastRead.toDate() : null,
      fcmTokens: ((data['fcmTokens'] as List?) ?? const [])
          .whereType<String>()
          .toList(),
    );
  }

  RoomMember copyWith({
    bool? isOnline,
    bool? hasUnread,
    DateTime? lastReadAt,
  }) {
    return RoomMember(
      id: id,
      name: name,
      email: email,
      avatarColor: avatarColor,
      isOnline: isOnline ?? this.isOnline,
      hasUnread: hasUnread ?? this.hasUnread,
      lastReadAt: lastReadAt ?? this.lastReadAt,
      fcmTokens: fcmTokens,
    );
  }
}
