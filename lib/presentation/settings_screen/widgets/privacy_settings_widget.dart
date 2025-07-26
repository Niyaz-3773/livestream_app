import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class PrivacySettingsWidget extends StatelessWidget {
  final Map<String, dynamic> privacySettings;
  final VoidCallback onOpenCameraSettings;
  final VoidCallback onOpenMicrophoneSettings;

  const PrivacySettingsWidget({
    Key? key,
    required this.privacySettings,
    required this.onOpenCameraSettings,
    required this.onOpenMicrophoneSettings,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.lightTheme.colorScheme.shadow.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Privacy Settings',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildPermissionOption(
            'camera_alt',
            'Camera Permission',
            privacySettings['cameraPermission'] as String? ?? 'Granted',
            onOpenCameraSettings,
          ),
          SizedBox(height: 2.h),
          _buildPermissionOption(
            'mic',
            'Microphone Permission',
            privacySettings['microphonePermission'] as String? ?? 'Granted',
            onOpenMicrophoneSettings,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionOption(
    String iconName,
    String title,
    String status,
    VoidCallback onOpenSettings,
  ) {
    final bool isGranted = status.toLowerCase() == 'granted';

    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: isGranted
              ? AppTheme.lightTheme.colorScheme.primary
              : AppTheme.lightTheme.colorScheme.error,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              Row(
                children: [
                  Container(
                    width: 2.w,
                    height: 2.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isGranted
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.error,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    status,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: isGranted
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.error,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        TextButton(
          onPressed: onOpenSettings,
          style: TextButton.styleFrom(
            padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
          ),
          child: Text(
            'Open Settings',
            style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.primary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
