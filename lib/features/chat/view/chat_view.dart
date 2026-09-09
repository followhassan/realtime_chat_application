import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/features/chat/controller/chat_controller.dart';

class ChatView extends GetView<ChatController> {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Chat'),
      ),
    );
  }
}
