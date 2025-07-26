import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AccessibilitySettingsWidget extends StatelessWidget {
  final Map<String, dynamic> accessibilitySettings;
  final Function(String, bool) onAccessibilityChanged;

  const AccessibilitySettingsWidget({
    Key? key,
    required this.accessibilitySettings,
    required this.onAccessibilityChanged,
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
            'Accessibility',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildAccessibilityOption(
            'motion_photos_off',
            'Reduced Motion',
            'Minimize animations and transitions',
            accessibilitySettings['reducedMotion'] as bool? ?? false,
            'reducedMotion',
          ),
          SizedBox(height: 2.h),
          _buildAccessibilityOption(
            'contrast',
            'High Contrast Mode',
            'Increase color contrast for better visibility',
            accessibilitySettings['highContrast'] as bool? ?? false,
            'highContrast',
          ),
        ],
      ),
    );
  }

  Widget _buildAccessibilityOption(
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
            onAccessibilityChanged(key, newValue);
          },
        ),
      ],
    );
  }
}
