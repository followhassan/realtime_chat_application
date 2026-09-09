import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';
import 'package:realtime_chat_application/core/models/chat_message.dart';
import 'package:realtime_chat_application/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat_application/features/chat/widgets/day_separator.dart';
import 'package:realtime_chat_application/features/chat/widgets/jump_to_latest_button.dart';
import 'package:realtime_chat_application/features/chat/widgets/member_strip.dart';
import 'package:realtime_chat_application/features/chat/widgets/message_bubble.dart';
import 'package:realtime_chat_application/features/chat/widgets/message_composer.dart';
import 'package:realtime_chat_application/features/chat/widgets/system_chip.dart';
import 'package:realtime_chat_application/features/chat/widgets/typing_indicator.dart';
import 'package:realtime_chat_application/features/chat/widgets/unread_divider.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(controller.roomTitle),
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.presence,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${controller.onlineCount} online',
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                          color: AppColors.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Leave room',
            onPressed: controller.leaveRoom,
            icon: const Icon(Icons.logout_rounded),
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            if (!controller.isReconnecting.value) {
              return const SizedBox.shrink();
            }
            return Material(
              color: const Color(0xFFFFF7ED),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Reconnecting… history will sync automatically',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                  ],
                ),
              ),
            );
          }),
          Obx(() => MemberStrip(members: controller.members.toList())),
          const Divider(height: 1, color: AppColors.outline),
          Expanded(
            child: Stack(
              children: [
                Obx(() {
                  final items = _buildItems(controller.messages.toList());
                  return ListView.builder(
                    controller: controller.scrollController,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                    itemCount: items.length + (controller.isLoadingMore.value ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (controller.isLoadingMore.value && index == 0) {
                        return const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        );
                      }
                      final itemIndex =
                          controller.isLoadingMore.value ? index - 1 : index;
                      return items[itemIndex];
                    },
                  );
                }),
                Obx(() {
                  if (!controller.showJumpToLatest.value) {
                    return const SizedBox.shrink();
                  }
                  return Positioned(
                    right: 16,
                    bottom: 12,
                    child: JumpToLatestButton(
                      count: controller.unreadCount.value,
                      onPressed: controller.jumpToLatest,
                    ),
                  );
                }),
              ],
            ),
          ),
          Obx(() => TypingIndicator(names: controller.typingUsers.toList())),
          MessageComposer(
            controller: controller.textController,
            onChanged: controller.onComposerChanged,
            onSend: controller.sendMessage,
          ),
        ],
      ),
    );
  }

  List<Widget> _buildItems(List<ChatMessage> messages) {
    final widgets = <Widget>[];
    DateTime? lastDay;
    final dividerAt = controller.unreadDividerIndex.value;

    for (var i = 0; i < messages.length; i++) {
      final message = messages[i];
      final day = DateTime(
        message.createdAt.year,
        message.createdAt.month,
        message.createdAt.day,
      );

      if (lastDay == null || day != lastDay) {
        widgets.add(DaySeparator(date: message.createdAt));
        lastDay = day;
      }

      if (i == dividerAt && controller.unreadCount.value > 0) {
        widgets.add(UnreadDivider(count: controller.unreadCount.value));
      }

      if (message.kind == MessageKind.system) {
        widgets.add(SystemChip(text: message.body));
        continue;
      }

      final previous = i > 0 ? messages[i - 1] : null;
      final showSender = previous == null ||
          previous.kind == MessageKind.system ||
          previous.senderId != message.senderId ||
          message.createdAt.difference(previous.createdAt).inMinutes > 2;

      widgets.add(
        MessageBubble(
          message: message,
          showSender: showSender && !message.isMine,
        ),
      );
    }

    return widgets;
  }
}
