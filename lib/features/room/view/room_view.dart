import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/features/room/controller/room_controller.dart';

class RoomView extends GetView<RoomController> {
  const RoomView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Room'),
      ),
    );
  }
}
