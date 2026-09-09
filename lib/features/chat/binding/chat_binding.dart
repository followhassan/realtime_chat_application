import 'package:get/get.dart';
import 'package:realtime_chat_application/core/services/fcm_service.dart';
import 'package:realtime_chat_application/core/services/message_service.dart';
import 'package:realtime_chat_application/core/services/presence_service.dart';
import 'package:realtime_chat_application/core/services/typing_service.dart';
import 'package:realtime_chat_application/features/chat/controller/chat_controller.dart';

class ChatBinding extends Bindings {
  @override
  void dependencies() {
    final messageService = Get.isRegistered<MessageService>()
        ? Get.find<MessageService>()
        : Get.put(MessageService());
    final presenceService = Get.isRegistered<PresenceService>()
        ? Get.find<PresenceService>()
        : Get.put(PresenceService());
    final typingService = Get.put(TypingService());
    final fcmService = Get.isRegistered<FcmService>()
        ? Get.find<FcmService>()
        : Get.put(FcmService());

    Get.put(
      ChatController(
        messageService: messageService,
        presenceService: presenceService,
        typingService: typingService,
        fcmService: fcmService,
      ),
    );
  }
}
