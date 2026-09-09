import 'package:get/get.dart';
import 'package:realtime_chat_application/core/services/auth_service.dart';
import 'package:realtime_chat_application/core/services/message_service.dart';
import 'package:realtime_chat_application/core/services/presence_service.dart';
import 'package:realtime_chat_application/features/auth/controller/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    final authService = _permanent(AuthService.new);
    final messageService = _permanent(MessageService.new);
    final presenceService = _permanent(PresenceService.new);
    Get.put(
      AuthController(
        authService: authService,
        messageService: messageService,
        presenceService: presenceService,
      ),
    );
  }

  T _permanent<T>(T Function() create) {
    if (Get.isRegistered<T>()) return Get.find<T>();
    return Get.put(create(), permanent: true);
  }
}
