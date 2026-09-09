import 'package:get/get.dart';
import 'package:realtime_chat_application/features/room/controller/room_controller.dart';

class RoomBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RoomController>(RoomController.new);
  }
}
