import 'package:flutter/material.dart';
import 'package:get/get.dart';

class ChatController extends GetxController {
  final messages = <String>[].obs;
  final textController = TextEditingController();

  void sendMessage() {
    final text = textController.text.trim();
    if (text.isEmpty) return;

    messages.add(text);
    textController.clear();
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
