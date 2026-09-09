import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';
import 'package:realtime_chat_application/features/auth/binding/auth_binding.dart';
import 'package:realtime_chat_application/features/auth/view/auth_view.dart';
import 'package:realtime_chat_application/features/chat/binding/chat_binding.dart';
import 'package:realtime_chat_application/features/chat/view/chat_view.dart';
import 'package:realtime_chat_application/features/notification/binding/notification_binding.dart';
import 'package:realtime_chat_application/features/notification/view/notification_view.dart';
import 'package:realtime_chat_application/features/presence/binding/presence_binding.dart';
import 'package:realtime_chat_application/features/presence/view/presence_view.dart';
import 'package:realtime_chat_application/features/room/binding/room_binding.dart';
import 'package:realtime_chat_application/features/room/view/room_view.dart';

abstract class AppPages {
  static final pages = <GetPage>[
    GetPage(
      name: AppRoutes.auth,
      page: () => const AuthView(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.room,
      page: () => const RoomView(),
      binding: RoomBinding(),
    ),
    GetPage(
      name: AppRoutes.chat,
      page: () => const ChatView(),
      binding: ChatBinding(),
    ),
    GetPage(
      name: AppRoutes.notification,
      page: () => const NotificationView(),
      binding: NotificationBinding(),
    ),
    GetPage(
      name: AppRoutes.presence,
      page: () => const PresenceView(),
      binding: PresenceBinding(),
    ),
  ];
}
