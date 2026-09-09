abstract class FirebasePaths {
  static const defaultRoomId = 'general';
  static const defaultRoomName = 'General';

  static const users = 'users';
  static const rooms = 'rooms';

  static String room(String roomId) => '$rooms/$roomId';
  static String members(String roomId) => '$rooms/$roomId/members';
  static String messages(String roomId) => '$rooms/$roomId/messages';
  static String typing(String roomId) => '$rooms/$roomId/typing';
}

abstract class ChatLimits {
  static const pageSize = 40;
}
