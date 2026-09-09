import 'package:get/get.dart';
import 'package:realtime_chat_application/features/notification/controller/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationController>(NotificationController.new);
  }
}
