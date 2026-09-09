import 'package:flutter/material.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';

class UnreadDivider extends StatelessWidget {
  const UnreadDivider({
    super.key,
    required this.count,
  });

  final int count;

  @override
  Widget build(BuildContext context) {
    final label = count == 1 ? '1 new message' : '$count new messages';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          const Expanded(
            child: Divider(color: AppColors.unread, thickness: 1.2),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.unread,
                    fontWeight: FontWeight.w700,
                  ),
            ),
          ),
          const Expanded(
            child: Divider(color: AppColors.unread, thickness: 1.2),
          ),
        ],
      ),
    );
  }
}
