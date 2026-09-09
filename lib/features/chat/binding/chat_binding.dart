import 'package:get/get.dart';
import 'package:realtime_chat_application/features/chat/controller/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ChatController>(ChatController.new);
  }
}
