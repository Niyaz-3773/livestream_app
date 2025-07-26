import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class EmergencyFallbackWidget extends StatelessWidget {
  final bool showEmergencyOptions;
  final VoidCallback onAudioOnlyMode;
  final VoidCallback onOfflineRecording;
  final VoidCallback onContactSupport;

  const EmergencyFallbackWidget({
    Key? key,
    required this.showEmergencyOptions,
    required this.onAudioOnlyMode,
    required this.onOfflineRecording,
    required this.onContactSupport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!showEmergencyOptions) {
      return const SizedBox.shrink();
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CustomIconWidget(
                  iconName: 'warning',
                  color: AppTheme.connectionBadLight,
                  size: 24,
                ),
                SizedBox(width: 3.w),
                Text(
                  'Emergency Options',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.connectionBadLight,
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.connectionBadLight.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Severe connectivity issues detected. Use these options to continue your broadcast.',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.connectionBadLight,
                ),
              ),
            ),
            SizedBox(height: 3.h),
            _buildEmergencyOption(
              icon: 'volume_up',
              title: 'Audio-Only Mode',
              description: 'Continue with audio streaming only',
              onTap: onAudioOnlyMode,
            ),
            SizedBox(height: 2.h),
            _buildEmergencyOption(
              icon: 'mic',
              title: 'Offline Recording',
              description: 'Record message for later upload',
              onTap: onOfflineRecording,
            ),
            SizedBox(height: 2.h),
            _buildEmergencyOption(
              icon: 'support_agent',
              title: 'Contact Support',
              description: 'Get technical assistance',
              onTap: onContactSupport,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmergencyOption({
    required String icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppTheme.lightTheme.dividerColor,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(2.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.primary
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: CustomIconWidget(
                iconName: icon,
                color: AppTheme.lightTheme.colorScheme.primary,
                size: 24,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    description,
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            CustomIconWidget(
              iconName: 'arrow_forward_ios',
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
