import 'package:flutter/material.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({
    super.key,
    required this.names,
  });

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    if (names.isEmpty) return const SizedBox.shrink();

    final label = names.length == 1
        ? '${names.first} is typing…'
        : '${names.join(', ')} are typing…';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
              fontStyle: FontStyle.italic,
            ),
      ),
    );
  }
}
