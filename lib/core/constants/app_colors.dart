import 'package:flutter/material.dart';

/// Colour language
/// - Primary / own messages: #4F46E5
/// - Presence / unread only: #22C55E / #16A34A
abstract class AppColors {
  static const primary = Color(0xFF4F46E5);
  static const presence = Color(0xFF22C55E);
  static const unread = Color(0xFF16A34A);

  static const onPrimary = Color(0xFFFFFFFF);
  static const background = Color(0xFFF8FAFC);
  static const surface = Color(0xFFFFFFFF);
  static const onSurface = Color(0xFF0F172A);
  static const onSurfaceVariant = Color(0xFF64748B);
  static const outline = Color(0xFFE2E8F0);
  static const otherBubble = Color(0xFFF1F5F9);
}
