import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';
import 'package:realtime_chat_application/features/auth/controller/auth_controller.dart';

class ServerUrlSection extends GetView<AuthController> {
  const ServerUrlSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final expanded = controller.isServerExpanded.value;
      return Column(
        children: [
          ListTile(
            contentPadding: EdgeInsets.zero,
            dense: true,
            title: Text(
              'Server settings',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
            ),
            trailing: Icon(
              expanded ? Icons.expand_less : Icons.expand_more,
              color: AppColors.onSurfaceVariant,
            ),
            onTap: controller.toggleServerSettings,
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextFormField(
                controller: controller.serverUrlController,
                keyboardType: TextInputType.url,
                decoration: const InputDecoration(
                  labelText: 'Server URL',
                  hintText: AuthController.defaultServerUrl,
                ),
              ),
            ),
            crossFadeState:
                expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      );
    });
  }
}
