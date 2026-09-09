import 'package:flutter/material.dart';
import 'package:realtime_chat_application/core/constants/app_colors.dart';
import 'package:realtime_chat_application/core/models/room_member.dart';

class MemberStrip extends StatelessWidget {
  const MemberStrip({
    super.key,
    required this.members,
  });

  final List<RoomMember> members;

  @override
  Widget build(BuildContext context) {
    final sorted = [...members]..sort((a, b) {
      if (a.isOnline != b.isOnline) return a.isOnline ? -1 : 1;
      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return ColoredBox(
      color: AppColors.surface,
      child: SizedBox(
        height: 100,
        child: sorted.isEmpty
            ? const Center(child: Text('No one in the room yet'))
            : ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                itemCount: sorted.length,
                separatorBuilder: (_, _) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  return _MemberTile(member: sorted[index]);
                },
              ),
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  const _MemberTile({required this.member});

  final RoomMember member;

  @override
  Widget build(BuildContext context) {
    final online = member.isOnline;
    final ringColor = online ? AppColors.presence : AppColors.outline;

    return SizedBox(
      width: 68,
      child: Column(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: ringColor, width: online ? 2.5 : 1.5),
                  ),
                  child: CircleAvatar(
                    backgroundColor: member.avatarColor.withValues(alpha: 0.18),
                    foregroundColor: member.avatarColor,
                    child: Text(
                      member.initials,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: online
                          ? AppColors.presence
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.surface, width: 2),
                    ),
                  ),
                ),
                if (member.hasUnread)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: AppColors.unread,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.surface, width: 2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            member.name.split(' ').first,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: online ? AppColors.onSurface : AppColors.onSurfaceVariant,
                  fontWeight: online ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 11,
                  height: 1.1,
                ),
          ),
        ],
      ),
    );
  }
}
