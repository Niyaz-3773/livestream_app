import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NotificationSettingsWidget extends StatelessWidget {
  final Map<String, dynamic> notificationSettings;
  final Function(String, bool) onNotificationChanged;

  const NotificationSettingsWidget({
    Key? key,
    required this.notificationSettings,
    required this.onNotificationChanged,
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
            'Notifications',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildNotificationOption(
            'notifications',
            'Broadcast Invitations',
            'Receive notifications for new broadcast invitations',
            notificationSettings['broadcastInvitations'] as bool? ?? true,
            'broadcastInvitations',
          ),
          SizedBox(height: 2.h),
          _buildNotificationOption(
            'play_circle',
            'Session Start/End Alerts',
            'Get notified when broadcast sessions begin or end',
            notificationSettings['sessionAlerts'] as bool? ?? true,
            'sessionAlerts',
          ),
          SizedBox(height: 2.h),
          _buildNotificationOption(
            'network_check',
            'Network Status Warnings',
            'Receive alerts about connection quality issues',
            notificationSettings['networkWarnings'] as bool? ?? true,
            'networkWarnings',
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(
    String iconName,
    String title,
    String description,
    bool value,
    String key,
  ) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
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
              Text(
                description,
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: (bool newValue) {
            onNotificationChanged(key, newValue);
          },
        ),
      ],
    );
  }
}
