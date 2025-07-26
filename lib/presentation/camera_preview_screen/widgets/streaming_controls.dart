import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class StreamingControls extends StatelessWidget {
  final VoidCallback onStartVideo;
  final VoidCallback onAudioOnly;
  final VoidCallback onCancel;
  final bool isLoading;
  final String networkQuality;

  const StreamingControls({
    super.key,
    required this.onStartVideo,
    required this.onAudioOnly,
    required this.onCancel,
    this.isLoading = false,
    required this.networkQuality,
  });

  @override
  Widget build(BuildContext context) {
    final bool showVideoOption =
        networkQuality != 'bad' && networkQuality != 'disconnected';

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.95),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (showVideoOption) ...[
              SizedBox(
                width: double.infinity,
                height: 6.h,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onStartVideo,
                  icon: isLoading
                      ? SizedBox(
                          width: 5.w,
                          height: 5.w,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        )
                      : CustomIconWidget(
                          iconName: 'videocam',
                          size: 5.w,
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                        ),
                  label: Text(
                    isLoading ? 'Starting...' : 'Start Video',
                    style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onPrimary,
                    ),
                  ),
                  style: AppTheme.lightTheme.elevatedButtonTheme.style,
                ),
              ),
              SizedBox(height: 2.h),
            ],
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: OutlinedButton.icon(
                onPressed: isLoading ? null : onAudioOnly,
                icon: CustomIconWidget(
                  iconName: 'mic',
                  size: 5.w,
                  color: AppTheme.lightTheme.colorScheme.primary,
                ),
                label: Text(
                  'Audio Only',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                  ),
                ),
                style: AppTheme.lightTheme.outlinedButtonTheme.style,
              ),
            ),
            SizedBox(height: 2.h),
            SizedBox(
              width: double.infinity,
              height: 6.h,
              child: TextButton(
                onPressed: isLoading ? null : onCancel,
                child: Text(
                  'Cancel',
                  style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                  ),
                ),
                style: AppTheme.lightTheme.textButtonTheme.style,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
