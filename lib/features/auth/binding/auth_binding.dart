import 'package:get/get.dart';
import 'package:realtime_chat_application/features/auth/controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthController>(AuthController.new);
  }
}
