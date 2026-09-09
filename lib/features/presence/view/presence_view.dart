import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/features/presence/controller/presence_controller.dart';

class PresenceView extends GetView<PresenceController> {
  const PresenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Presence'),
      ),
    );
  }
}
