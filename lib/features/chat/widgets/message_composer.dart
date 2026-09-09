import 'package:flutter/material.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';

class MessageComposer extends StatelessWidget {
  const MessageComposer({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onChanged: onChanged,
                onSubmitted: (_) => onSend(),
                decoration: const InputDecoration(
                  hintText: 'Message',
                  isDense: true,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              onPressed: onSend,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
              ),
              icon: const Icon(Icons.send_rounded),
            ),
          ],
        ),
      ),
    );
  }
}
