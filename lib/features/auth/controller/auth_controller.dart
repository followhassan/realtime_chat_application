import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';
import 'package:realtime_chat_application/core/models/session_args.dart';
import 'package:realtime_chat_application/core/services/auth_service.dart';
import 'package:realtime_chat_application/core/services/message_service.dart';
import 'package:realtime_chat_application/core/services/presence_service.dart';
import 'package:realtime_chat_application/core/constants/firebase_paths.dart';
import 'package:flutter/material.dart';

class AuthController extends GetxController {
  AuthController({
    AuthService? authService,
    MessageService? messageService,
    PresenceService? presenceService,
  })  : _authService = authService ?? AuthService(),
        _messageService = messageService ?? MessageService(),
        _presenceService = presenceService ?? PresenceService();

  final AuthService _authService;
  final MessageService _messageService;
  final PresenceService _presenceService;

  final formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final displayNameController = TextEditingController();

  final isJoining = false.obs;
  final errorText = RxnString();

  String? validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Email is required';
    if (!GetUtils.isEmail(email)) return 'Enter a valid email';
    return null;
  }

  Future<void> joinRoom() async {
    if (!(formKey.currentState?.validate() ?? false)) return;

    isJoining.value = true;
    errorText.value = null;

    try {
      final user = await _authService.joinWithEmail(
        email: emailController.text,
        displayName: displayNameController.text,
      );

      await _presenceService.joinRoom(
        roomId: FirebasePaths.defaultRoomId,
        user: user,
      );

      await _messageService.sendJoinAnnouncement(
        roomId: FirebasePaths.defaultRoomId,
        senderId: user.id,
        displayName: user.displayName,
      );

      Get.offAllNamed(
        AppRoutes.chat,
        arguments: SessionArgs(user: user),
      );
    } catch (e) {
      final message = e is StateError ? e.message : '$e';
      errorText.value = message;
      Get.snackbar(
        'Join failed',
        message,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 5),
      );
    } finally {
      isJoining.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    displayNameController.dispose();
    super.onClose();
  }
}
