import 'package:get/get.dart';
import 'package:realtime_chat_application/core/services/auth_service.dart';
import 'package:realtime_chat_application/core/services/message_service.dart';
import 'package:realtime_chat_application/core/services/presence_service.dart';
import 'package:realtime_chat_application/features/auth/controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final authService = Get.put(AuthService());
    final messageService = Get.put(MessageService());
    final presenceService = Get.put(PresenceService());
    Get.put(
      AuthController(
        authService: authService,
        messageService: messageService,
        presenceService: presenceService,
      ),
    );
  }
}
