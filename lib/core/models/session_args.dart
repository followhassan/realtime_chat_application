class SessionArgs {
  const SessionArgs({
    required this.email,
    required this.displayName,
    required this.serverUrl,
    this.roomName = 'General',
  });

  final String email;
  final String displayName;
  final String serverUrl;
  final String roomName;
}
