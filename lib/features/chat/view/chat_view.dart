import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/core/constants/app_strings.dart';
import 'package:realtime_chat_application/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat_application/features/chat/widgets/message_bubble.dart';
import 'package:realtime_chat_application/features/chat/widgets/message_input.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.chatTitle),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (controller.messages.isEmpty) {
                return const Center(
                  child: Text('No messages yet. Say hello!'),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  return MessageBubble(
                    message: controller.messages[index],
                    isMine: true,
                  );
                },
              );
            }),
          ),
          MessageInput(
            controller: controller.textController,
            onSend: controller.sendMessage,
          ),
        ],
      ),
    );
  }
}
