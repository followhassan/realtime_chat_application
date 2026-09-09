import 'package:get/get.dart';
import 'package:realtime_chat_application/core/models/room_member.dart';
import 'package:realtime_chat_application/core/models/session_args.dart';

class PresenceController extends GetxController {
  final members = <RoomMember>[].obs;

  int get onlineCount => members.where((m) => m.isOnline).length;

  void bootstrap(SessionArgs session) {
    members.assignAll([
      RoomMember(
        id: session.email,
        name: session.displayName,
        email: session.email,
        isOnline: true,
      ),
      const RoomMember(
        id: 'alex@example.com',
        name: 'Alex Rivera',
        email: 'alex@example.com',
        isOnline: true,
      ),
      const RoomMember(
        id: 'sam@example.com',
        name: 'Sam Chen',
        email: 'sam@example.com',
        isOnline: true,
      ),
      const RoomMember(
        id: 'jordan@example.com',
        name: 'Jordan Lee',
        email: 'jordan@example.com',
        isOnline: false,
      ),
    ]);
  }

  void markUnread(String senderId, {required bool value}) {
    final index = members.indexWhere((m) => m.id == senderId);
    if (index == -1) return;
    members[index] = members[index].copyWith(hasUnread: value);
  }

  void clearAllUnread() {
    members.assignAll(
      members.map((m) => m.copyWith(hasUnread: false)).toList(),
    );
  }

  void setOnline(String memberId, {required bool isOnline}) {
    final index = members.indexWhere((m) => m.id == memberId);
    if (index == -1) return;
    members[index] = members[index].copyWith(isOnline: isOnline);
  }
}
