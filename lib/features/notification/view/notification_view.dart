import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/features/notification/controller/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  const NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Notification'),
      ),
    );
  }
}
