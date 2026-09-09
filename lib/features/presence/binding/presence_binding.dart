import 'package:get/get.dart';
import 'package:realtime_chat_application/features/presence/controller/presence_controller.dart';

class PresenceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PresenceController>(PresenceController.new);
  }
}
