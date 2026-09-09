import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';
import 'package:realtime_chat_application/features/auth/controller/auth_controller.dart';
import 'package:realtime_chat_application/features/auth/widgets/server_url_section.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Form(
                key: controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      'Join room',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.onSurface,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Enter your email to join the chat room.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 32),
                    TextFormField(
                      controller: controller.emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: controller.validateEmail,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'you@example.com',
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: controller.displayNameController,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.joinRoom(),
                      decoration: const InputDecoration(
                        labelText: 'Display name (optional)',
                        hintText: 'How others see you',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const ServerUrlSection(),
                    const SizedBox(height: 28),
                    Obx(
                      () => FilledButton(
                        onPressed:
                            controller.isJoining.value ? null : controller.joinRoom,
                        child: controller.isJoining.value
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onPrimary,
                                ),
                              )
                            : const Text('Join Room'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
