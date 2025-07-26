import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class VideoOverlayControlsWidget extends StatelessWidget {
  final String broadcastTitle;
  final int participantCount;
  final String connectionQuality;
  final bool isMuted;
  final bool isCameraOn;
  final bool isHandRaised;
  final int? handRaisePosition;
  final VoidCallback onMuteToggle;
  final VoidCallback onCameraToggle;
  final VoidCallback onHandRaiseToggle;
  final VoidCallback onLeaveBroadcast;
  final bool isVisible;

  const VideoOverlayControlsWidget({
    super.key,
    required this.broadcastTitle,
    required this.participantCount,
    required this.connectionQuality,
    required this.isMuted,
    required this.isCameraOn,
    required this.isHandRaised,
    this.handRaisePosition,
    required this.onMuteToggle,
    required this.onCameraToggle,
    required this.onHandRaiseToggle,
    required this.onLeaveBroadcast,
    required this.isVisible,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Top overlay
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 2.h,
                  left: 4.w,
                  right: 4.w,
                  bottom: 3.h,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            broadcastTitle,
                            style: AppTheme.lightTheme.textTheme.titleLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: 0.5.h),
                          Row(
                            children: [
                              CustomIconWidget(
                                iconName: 'people',
                                color: Colors.white.withValues(alpha: 0.8),
                                size: 16,
                              ),
                              SizedBox(width: 1.w),
                              Text(
                                '$participantCount participants',
                                style: AppTheme.lightTheme.textTheme.bodyMedium
                                    ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 3.w),
                    _buildConnectionIndicator(),
                  ],
                ),
              ),
            ),

            // Bottom overlay
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.7),
                      Colors.transparent,
                    ],
                  ),
                ),
                padding: EdgeInsets.only(
                  top: 3.h,
                  left: 4.w,
                  right: 4.w,
                  bottom: MediaQuery.of(context).padding.bottom + 2.h,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildControlButton(
                      icon: isMuted ? 'mic_off' : 'mic',
                      isActive: !isMuted,
                      onTap: onMuteToggle,
                    ),
                    _buildControlButton(
                      icon: isCameraOn ? 'videocam' : 'videocam_off',
                      isActive: isCameraOn,
                      onTap: onCameraToggle,
                    ),
                    _buildHandRaiseButton(),
                    _buildControlButton(
                      icon: 'call_end',
                      isActive: false,
                      onTap: onLeaveBroadcast,
                      backgroundColor: AppTheme.errorLight,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConnectionIndicator() {
    Color indicatorColor;
    String indicatorText;

    switch (connectionQuality.toLowerCase()) {
      case 'excellent':
      case 'good':
        indicatorColor = AppTheme.connectionGoodLight;
        indicatorText = 'Good';
        break;
      case 'fair':
      case 'poor':
        indicatorColor = AppTheme.connectionPoorLight;
        indicatorText = 'Poor';
        break;
      case 'bad':
      case 'disconnected':
        indicatorColor = AppTheme.connectionBadLight;
        indicatorText = 'Bad';
        break;
      default:
        indicatorColor = AppTheme.connectionGoodLight;
        indicatorText = 'Good';
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: indicatorColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: indicatorColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: indicatorColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.w),
          Text(
            indicatorText,
            style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required String icon,
    required bool isActive,
    required VoidCallback onTap,
    Color? backgroundColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: backgroundColor ??
              (isActive
                  ? AppTheme.lightTheme.colorScheme.primary
                  : Colors.white.withValues(alpha: 0.2)),
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Center(
          child: CustomIconWidget(
            iconName: icon,
            color: Colors.white,
            size: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildHandRaiseButton() {
    return GestureDetector(
      onTap: onHandRaiseToggle,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          color: isHandRaised
              ? AppTheme.accentLight
              : Colors.white.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(
            color: isHandRaised
                ? AppTheme.accentLight
                : Colors.white.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Stack(
          children: [
            Center(
              child: CustomIconWidget(
                iconName: 'pan_tool',
                color: Colors.white,
                size: 24,
              ),
            ),
            if (isHandRaised && handRaisePosition != null)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: EdgeInsets.all(0.5.w),
                  decoration: const BoxDecoration(
                    color: AppTheme.errorLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$handRaisePosition',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
