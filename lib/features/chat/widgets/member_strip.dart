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
    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: members.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final member = members[index];
          return SizedBox(
            width: 56,
            child: Column(
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                      foregroundColor: AppColors.primary,
                      child: Text(
                        member.initials,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    if (member.isOnline)
                      Positioned(
                        right: -1,
                        bottom: -1,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.presence,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    if (member.hasUnread)
                      Positioned(
                        right: -2,
                        top: -2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: AppColors.unread,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.surface,
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  member.name.split(' ').first,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
