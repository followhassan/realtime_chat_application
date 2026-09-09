import 'package:get/get.dart';
import 'package:realtime_chat_application/core/models/room_member.dart';

/// Presence state is owned by [PresenceService] and surfaced via ChatController.
class PresenceController extends GetxController {
  final members = <RoomMember>[].obs;
  int get onlineCount => members.where((m) => m.isOnline).length;
}
