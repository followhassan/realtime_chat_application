import 'package:get/get.dart';
import 'package:realtime_chat_application/apps/routes/app_routes.dart';

class HomeController extends GetxController {
  final welcomeMessage = 'Welcome to Realtime Chat'.obs;

  void openChat() {
    Get.toNamed(AppRoutes.chat);
  }
}
