import 'package:get/get.dart';
import 'package:realtime_chat_application/features/chat/controller/chat_controller.dart';
import 'package:realtime_chat_application/features/notification/controller/notification_controller.dart';
import 'package:realtime_chat_application/features/presence/controller/presence_controller.dart';
import 'package:realtime_chat_application/features/room/controller/room_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomController>(RoomController.new);
    Get.lazyPut<PresenceController>(PresenceController.new);
    Get.lazyPut<NotificationController>(NotificationController.new);
    Get.lazyPut<ChatController>(
      () => ChatController(
        roomController: Get.find(),
        presenceController: Get.find(),
        notificationController: Get.find(),
      ),
    );
  }
}
