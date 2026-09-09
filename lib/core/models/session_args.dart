import 'package:realtime_chat_application/core/models/app_user.dart';

class SessionArgs {
  const SessionArgs({
    required this.user,
    this.roomId = 'general',
    this.roomName = 'General',
  });

  final AppUser user;
  final String roomId;
  final String roomName;
}
