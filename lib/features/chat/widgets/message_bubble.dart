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

String _formatTime(DateTime date) {
  final hour = date.hour.toString().padLeft(2, '0');
  final minute = date.minute.toString().padLeft(2, '0');
  return '$hour:$minute';
}

class _OwnBubble extends StatelessWidget {
  const _OwnBubble({required this.message});

  final ChatMessage message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          margin: const EdgeInsets.only(top: 3, bottom: 3, left: 56),
          padding: const EdgeInsets.fromLTRB(14, 9, 12, 7),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(6),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onPrimary,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatTime(message.createdAt),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.onPrimary.withValues(alpha: 0.78),
                          fontSize: 11,
                        ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    message.deliveryStatus == DeliveryStatus.delivered
                        ? Icons.done_all
                        : Icons.done,
                    size: 14,
                    color: AppColors.onPrimary.withValues(alpha: 0.85),
                  ),
                ],
              ),
            ],
          ),
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 300),
        child: Container(
          margin: EdgeInsets.only(
            top: showSender ? 10 : 3,
            bottom: 3,
            right: 56,
          ),
          padding: const EdgeInsets.fromLTRB(14, 9, 14, 7),
          decoration: const BoxDecoration(
            color: AppColors.otherBubble,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(6),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
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
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 3),
              ],
              Text(
                message.body,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurface,
                      height: 1.35,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                _formatTime(message.createdAt),
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
