import 'package:flutter/material.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';

class SystemChip extends StatelessWidget {
  const SystemChip({
    super.key,
    required this.text,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.outline.withValues(alpha: 0.55),
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(
            text,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}
