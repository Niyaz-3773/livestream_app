import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class BandwidthMeterWidget extends StatelessWidget {
  final double uploadSpeed;
  final double downloadSpeed;
  final String quality;

  const BandwidthMeterWidget({
    Key? key,
    required this.uploadSpeed,
    required this.downloadSpeed,
    required this.quality,
  }) : super(key: key);

  Color _getQualityColor() {
    switch (quality.toLowerCase()) {
      case 'excellent':
        return AppTheme.connectionGoodLight;
      case 'good':
        return AppTheme.connectionGoodLight;
      case 'fair':
        return AppTheme.connectionPoorLight;
      case 'poor':
        return AppTheme.connectionBadLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  @override
  Widget build(BuildContext context) {
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Bandwidth Monitor',
                  style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.h),
                  decoration: BoxDecoration(
                    color: _getQualityColor().withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    quality,
                    style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                      color: _getQualityColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 3.h),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'upload',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 28,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '${uploadSpeed.toStringAsFixed(1)} Mbps',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Upload',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 8.h,
                  color: AppTheme.lightTheme.dividerColor,
                ),
                Expanded(
                  child: Column(
                    children: [
                      CustomIconWidget(
                        iconName: 'download',
                        color: AppTheme.lightTheme.colorScheme.secondary,
                        size: 28,
                      ),
                      SizedBox(height: 1.h),
                      Text(
                        '${downloadSpeed.toStringAsFixed(1)} Mbps',
                        style:
                            AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Download',
                        style:
                            AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
