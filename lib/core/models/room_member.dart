class RoomMember {
  const RoomMember({
    required this.id,
    required this.name,
    required this.email,
    this.isOnline = false,
    this.hasUnread = false,
  });

  final String id;
  final String name;
  final String email;
  final bool isOnline;
  final bool hasUnread;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  RoomMember copyWith({
    bool? isOnline,
    bool? hasUnread,
  }) {
    return RoomMember(
      id: id,
      name: name,
      email: email,
      isOnline: isOnline ?? this.isOnline,
      hasUnread: hasUnread ?? this.hasUnread,
    );
  }
}
