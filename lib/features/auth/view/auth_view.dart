import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';
import 'package:realtime_chat_application/features/auth/controller/auth_controller.dart';

class AuthView extends GetView<AuthController> {
  const AuthView({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
              child: Form(
                key: controller.formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const _BrandMark(),
                    const SizedBox(height: 28),
                    Text(
                      'Join the room',
                      textAlign: TextAlign.center,
                      style: textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.onSurface,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Your email is your identity here — use the same one next time and your history comes back with you.',
                      textAlign: TextAlign.center,
                      style: textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 32),
                    _AuthTextField(
                      controller: controller.emailController,
                      icon: Icons.person_outline_rounded,
                      hintText: 'hasanmahamud@gmail.com',
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      autofillHints: const [AutofillHints.email],
                      validator: controller.validateEmail,
                    ),
                    const SizedBox(height: 14),
                    _AuthTextField(
                      controller: controller.displayNameController,
                      icon: Icons.badge_outlined,
                      hintText: 'Display name (optional)',
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => controller.joinRoom(),
                    ),
                    const SizedBox(height: 28),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: FilledButton(
                          onPressed: controller.isJoining.value
                              ? null
                              : controller.joinRoom,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: controller.isJoining.value
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppColors.onPrimary,
                                  ),
                                )
                              : const Text(
                                  'Enter chat room',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                        ),
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

class _BrandMark extends StatelessWidget {
  const _BrandMark();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 96,
      height: 96,
      child: CustomPaint(painter: _ChatMarkPainter()),
    );
  }
}

class _ChatMarkPainter extends CustomPainter {
  const _ChatMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final background = Paint()..color = AppColors.primary;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.width * 0.24),
      ),
      background,
    );

    final bubblePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final bubble = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        size.width * 0.18,
        size.height * 0.20,
        size.width * 0.64,
        size.height * 0.44,
      ),
      Radius.circular(size.width * 0.16),
    );
    canvas.drawRRect(bubble, bubblePaint);

    final tail = Path()
      ..moveTo(size.width * 0.28, size.height * 0.60)
      ..lineTo(size.width * 0.22, size.height * 0.78)
      ..quadraticBezierTo(
        size.width * 0.30,
        size.height * 0.72,
        size.width * 0.40,
        size.height * 0.62,
      )
      ..close();
    canvas.drawPath(tail, bubblePaint);

    final linePaint = Paint()
      ..color = Colors.black
      ..strokeWidth = size.height * 0.055
      ..strokeCap = StrokeCap.round;

    final left = size.width * 0.28;
    void drawLine(double y, double widthFactor) {
      canvas.drawLine(
        Offset(left, y),
        Offset(left + size.width * widthFactor, y),
        linePaint,
      );
    }

    drawLine(size.height * 0.34, 0.42);
    drawLine(size.height * 0.42, 0.32);
    drawLine(size.height * 0.50, 0.22);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Shared field so icon + text use the same vertical alignment.
class _AuthTextField extends StatelessWidget {
  const _AuthTextField({
    required this.controller,
    required this.icon,
    required this.hintText,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.validator,
    this.onFieldSubmitted,
  });

  final TextEditingController controller;
  final IconData icon;
  final String hintText;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final String? Function(String?)? validator;
  final ValueChanged<String>? onFieldSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: AppColors.onSurface,
        fontSize: 16,
        height: 1.25,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontSize: 16,
          height: 1.25,
        ),
        prefixIcon: Icon(
          icon,
          size: 22,
          color: Colors.black,
        ),
        // Keeps icon vertically centered with the text baseline area.
        prefixIconConstraints: const BoxConstraints(
          minWidth: 52,
          minHeight: 52,
        ),
        filled: true,
        fillColor: AppColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626)),
        ),
      ),
    );
  }
}
