import 'package:get/get.dart';
import 'package:realtime_chat_application/core/services/fcm_service.dart';

/// Push notifications use **FCM** (Firebase Cloud Messaging),
/// with local notifications for foreground display.
class NotificationController extends GetxController {
  NotificationController({FcmService? fcmService})
      : _fcm = fcmService ?? FcmService();

  final FcmService _fcm;

  @override
  void onInit() {
    super.onInit();
    _fcm.init();
  }
}
