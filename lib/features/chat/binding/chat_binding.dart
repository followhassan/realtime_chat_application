import 'package:get/get.dart';
import 'package:realtime_chat_application/core/services/fcm_service.dart';
import 'package:realtime_chat_application/core/services/message_service.dart';
import 'package:realtime_chat_application/core/services/presence_service.dart';
import 'package:realtime_chat_application/core/services/typing_service.dart';
import 'package:realtime_chat_application/features/chat/controller/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    final messageService = _permanent(MessageService.new);
    final presenceService = _permanent(PresenceService.new);
    final typingService = _permanent(TypingService.new);
    final fcmService = _permanent(FcmService.new);

    Get.put(
      ChatController(
        messageService: messageService,
        presenceService: presenceService,
        typingService: typingService,
        fcmService: fcmService,
      ),
    );
  }

  T _permanent<T>(T Function() create) {
    if (Get.isRegistered<T>()) return Get.find<T>();
    return Get.put(create(), permanent: true);
  }
}
