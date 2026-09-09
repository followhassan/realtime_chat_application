import 'package:flutter/material.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';

class DaySeparator extends StatelessWidget {
  const DaySeparator({
    super.key,
    required this.date,
  });

  final DateTime date;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.outline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              _labelFor(date),
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.outline)),
        ],
      ),
    );
  }

  String _labelFor(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(date.year, date.month, date.day);
    if (day == today) return 'Today';
    if (day == today.subtract(const Duration(days: 1))) return 'Yesterday';
    return '${date.day}/${date.month}/${date.year}';
  }
}
