import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/core/constants/app_strings.dart';
import 'package:realtime_chat_application/core/widgets/app_button.dart';
import 'package:realtime_chat_application/features/home/controller/home_controller.dart';
import 'package:realtime_chat_application/features/home/widgets/welcome_banner.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.homeTitle),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Spacer(),
            Obx(
              () => WelcomeBanner(
                message: controller.welcomeMessage.value,
              ),
            ),
            const SizedBox(height: 32),
            AppButton(
              label: 'Open Chat',
              onPressed: controller.openChat,
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}
