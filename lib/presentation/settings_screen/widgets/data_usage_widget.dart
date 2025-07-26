import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class DataUsageWidget extends StatelessWidget {
  final Map<String, dynamic> dataUsage;
  final VoidCallback onResetUsage;

  const DataUsageWidget({
    Key? key,
    required this.dataUsage,
    required this.onResetUsage,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Data Usage',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              TextButton(
                onPressed: onResetUsage,
                style: TextButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                ),
                child: Text(
                  'Reset',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 2.h),
          _buildUsageItem(
            'Current Session',
            dataUsage['currentSession'] as String? ?? '0 MB',
            'data_usage',
          ),
          SizedBox(height: 1.5.h),
          _buildUsageItem(
            'Today',
            dataUsage['today'] as String? ?? '0 MB',
            'today',
          ),
          SizedBox(height: 1.5.h),
          _buildUsageItem(
            'This Month',
            dataUsage['thisMonth'] as String? ?? '0 MB',
            'calendar_month',
          ),
          SizedBox(height: 1.5.h),
          _buildUsageItem(
            'Total',
            dataUsage['total'] as String? ?? '0 MB',
            'storage',
          ),
        ],
      ),
    );
  }

  Widget _buildUsageItem(String label, String value, String iconName) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: iconName,
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 18,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            label,
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.lightTheme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
