import 'package:get/get.dart';
import 'package:realtime_chat_application/core/models/session_args.dart';

class RoomController extends GetxController {
  final roomName = 'General'.obs;
  final serverUrl = ''.obs;

  void bindSession(SessionArgs session) {
    roomName.value = session.roomName;
    serverUrl.value = session.serverUrl;
  }
}
