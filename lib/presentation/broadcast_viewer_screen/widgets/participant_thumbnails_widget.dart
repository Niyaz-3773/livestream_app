import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ParticipantThumbnailsWidget extends StatelessWidget {
  final List<Map<String, dynamic>> participants;
  final String? activeSpeakerId;
  final Function(String participantId) onParticipantTap;

  const ParticipantThumbnailsWidget({
    super.key,
    required this.participants,
    this.activeSpeakerId,
    required this.onParticipantTap,
  });

  @override
  Widget build(BuildContext context) {
    if (participants.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 20.h,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.6),
            Colors.transparent,
          ],
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              itemCount: participants.length,
              itemBuilder: (context, index) {
                final participant = participants[index];
                final participantId = participant['id']?.toString() ?? '';
                final isActiveSpeaker = activeSpeakerId == participantId;

                return Padding(
                  padding: EdgeInsets.only(right: 3.w),
                  child: _buildParticipantThumbnail(
                    participant: participant,
                    isActiveSpeaker: isActiveSpeaker,
                    onTap: () => onParticipantTap(participantId),
                  ),
                );
              },
            ),
          ),
          SizedBox(height: 2.h),
        ],
      ),
    );
  }

  Widget _buildParticipantThumbnail({
    required Map<String, dynamic> participant,
    required bool isActiveSpeaker,
    required VoidCallback onTap,
  }) {
    final name = participant['name']?.toString() ?? 'Unknown';
    final avatar = participant['avatar']?.toString();
    final isMuted = participant['isMuted'] == true;
    final isVideoOn = participant['isVideoOn'] == true;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 20.w,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActiveSpeaker
                ? AppTheme.accentLight
                : Colors.white.withValues(alpha: 0.3),
            width: isActiveSpeaker ? 3 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            children: [
              // Video/Avatar background
              Container(
                width: double.infinity,
                height: double.infinity,
                color: AppTheme.lightTheme.colorScheme.surface
                    .withValues(alpha: 0.1),
                child: isVideoOn && avatar != null
                    ? CustomImageWidget(
                        imageUrl: avatar,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      )
                    : _buildAvatarPlaceholder(name),
              ),

              // Video off overlay
              if (!isVideoOn)
                Container(
                  width: double.infinity,
                  height: double.infinity,
                  color: Colors.black.withValues(alpha: 0.7),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: 'videocam_off',
                      color: Colors.white.withValues(alpha: 0.8),
                      size: 24,
                    ),
                  ),
                ),

              // Mute indicator
              if (isMuted)
                Positioned(
                  top: 1.w,
                  right: 1.w,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.errorLight,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'mic_off',
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),

              // Active speaker indicator
              if (isActiveSpeaker)
                Positioned(
                  top: 1.w,
                  left: 1.w,
                  child: Container(
                    padding: EdgeInsets.all(1.w),
                    decoration: BoxDecoration(
                      color: AppTheme.accentLight,
                      shape: BoxShape.circle,
                    ),
                    child: CustomIconWidget(
                      iconName: 'volume_up',
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),

              // Name label
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 1.w, vertical: 0.5.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Text(
                    name,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarPlaceholder(String name) {
    final initials = name.isNotEmpty
        ? name
            .split(' ')
            .map((word) => word.isNotEmpty ? word[0] : '')
            .take(2)
            .join()
            .toUpperCase()
        : '?';

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.lightTheme.colorScheme.primary,
            AppTheme.lightTheme.colorScheme.secondary,
          ],
        ),
      ),
      child: Center(
        child: Text(
          initials,
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
