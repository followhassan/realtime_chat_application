import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/features/auth/controller/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text('Auth'),
      ),
    );
  }
}
