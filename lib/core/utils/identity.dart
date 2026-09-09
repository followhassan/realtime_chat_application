import 'dart:ui';

abstract class EmailUtils {
  static String normalize(String email) => email.trim().toLowerCase();

  static String docId(String email) {
    return normalize(email).replaceAll('.', '_');
  }

  static bool isValid(String email) {
    final value = normalize(email);
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value);
  }

  static String defaultDisplayName(String email) {
    final local = normalize(email).split('@').first;
    if (local.isEmpty) return 'User';
    return local[0].toUpperCase() + local.substring(1);
  }
}

/// Deterministic avatar colour from email. Never uses presence/unread green.
Color avatarColorFromEmail(String email) {
  const palette = <Color>[
    Color(0xFF4F46E5),
    Color(0xFF7C3AED),
    Color(0xFFDB2777),
    Color(0xFFEA580C),
    Color(0xFF0891B2),
    Color(0xFF2563EB),
    Color(0xFF9333EA),
    Color(0xFFC026D3),
  ];
  final hash = EmailUtils.normalize(email).hashCode.abs();
  return palette[hash % palette.length];
}
