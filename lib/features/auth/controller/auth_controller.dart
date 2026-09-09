import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';
import 'package:realtime_chat_application/core/models/session_args.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  static const defaultServerUrl = 'ws://localhost:8080';

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final displayNameController = TextEditingController();
  final serverUrlController = TextEditingController(text: defaultServerUrl);

  final isServerExpanded = false.obs;
  final isJoining = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadSavedServerUrl();
  }

  Future<void> _loadSavedServerUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('server_url');
    if (saved != null && saved.isNotEmpty) {
      serverUrlController.text = saved;
    }
  }

  void toggleServerSettings() {
    isServerExpanded.value = !isServerExpanded.value;
  }

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email';
    return null;
  }

  Future<void> joinRoom() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isJoining.value = true;
    final email = emailController.text.trim();
    final displayName = displayNameController.text.trim().isEmpty
        ? email.split('@').first
        : displayNameController.text.trim();
    final serverUrl = serverUrlController.text.trim().isEmpty
        ? defaultServerUrl
        : serverUrlController.text.trim();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('server_url', serverUrl);

    isJoining.value = false;

    Get.offAllNamed(
      AppRoutes.chat,
      arguments: SessionArgs(
        email: email,
        displayName: displayName,
        serverUrl: serverUrl,
      ),
    );
  }

  @override
  void onClose() {
    emailController.dispose();
    displayNameController.dispose();
    serverUrlController.dispose();
    super.onClose();
  }
}
