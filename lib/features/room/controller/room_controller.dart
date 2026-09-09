import 'package:get/get.dart';
import 'package:realtime_chat_application/core/constants/firebase_paths.dart';

class RoomController extends GetxController {
  final roomId = FirebasePaths.defaultRoomId.obs;
  final roomName = FirebasePaths.defaultRoomName.obs;
}
