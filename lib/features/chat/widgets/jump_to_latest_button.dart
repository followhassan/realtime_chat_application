import 'package:flutter/material.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';

class JumpToLatestButton extends StatelessWidget {
  const JumpToLatestButton({
    super.key,
    required this.count,
    required this.onPressed,
  });

  final int count;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final label = count > 0 ? '$count new · Jump to latest' : 'Jump to latest';
    return Material(
      elevation: 2,
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.arrow_downward_rounded,
                size: 16,
                color: AppColors.unread,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      color: AppColors.unread,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
