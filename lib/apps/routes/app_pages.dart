import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';
import 'package:realtime_chat_application/features/auth/binding/auth_binding.dart';
import 'package:realtime_chat_application/features/auth/view/auth_view.dart';
import 'package:realtime_chat_application/features/chat/binding/chat_binding.dart';
import 'package:realtime_chat_application/features/chat/view/chat_view.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
  ];
}
