import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';
import 'package:realtime_chat_application/features/chat/binding/chat_binding.dart';
import 'package:realtime_chat_application/features/chat/view/chat_view.dart';
import 'package:realtime_chat_application/features/home/binding/home_binding.dart';
import 'package:realtime_chat_application/features/home/view/home_view.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
  ];
}
