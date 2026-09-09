import 'package:flutter/material.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';
import 'package:realtime_chat_application/core/models/chat_message.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.showSender,
  });

  final ChatMessage message;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    if (message.isMine) {
      return _OwnBubble(message: message);
    }
    return _OtherBubble(message: message, showSender: showSender);
  }
}

class _OwnBubble extends StatelessWidget {
  const _OwnBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.only(top: 2, bottom: 2, left: 64),
        padding: const EdgeInsets.fromLTRB(12, 8, 10, 6),
        decoration: const BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onPrimary,
                  ),
            ),
            const SizedBox(height: 2),
            Icon(
              message.deliveryStatus == DeliveryStatus.delivered
                  ? Icons.done_all
                  : Icons.done,
              size: 14,
              color: AppColors.onPrimary.withValues(alpha: 0.85),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherBubble extends StatelessWidget {
  const _OtherBubble({
    required this.message,
    required this.showSender,
  });

  final ChatMessage message;
  final bool showSender;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          top: showSender ? 8 : 2,
          bottom: 2,
          right: 64,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: const BoxDecoration(
          color: AppColors.otherBubble,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(4),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showSender) ...[
              Text(
                message.senderName,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 2),
            ],
            Text(
              message.body,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurface,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
