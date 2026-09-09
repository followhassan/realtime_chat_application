import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_pages.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';
import 'package:realtime_chat_application/core/theme/app_theme.dart';
import 'package:realtime_chat_application/features/auth/binding/auth_binding.dart';

class RealtimeChatApp extends StatelessWidget {
  const RealtimeChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Realtime Chat',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      initialBinding: AuthBinding(),
      initialRoute: AppRoutes.auth,
      getPages: AppPages.pages,
    );
  }
}
