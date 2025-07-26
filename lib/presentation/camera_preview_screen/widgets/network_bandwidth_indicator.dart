import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';
import '../../../theme/app_theme.dart';

class NetworkBandwidthIndicator extends StatelessWidget {
  final String connectionQuality;
  final String estimatedQuality;
  final double bandwidthKbps;

  const NetworkBandwidthIndicator({
    super.key,
    required this.connectionQuality,
    required this.estimatedQuality,
    required this.bandwidthKbps,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final connectionColor =
        AppTheme.getConnectionStatusColor(connectionQuality, isDark: isDark);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: connectionColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.w,
            height: 2.w,
            decoration: BoxDecoration(
              color: connectionColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Network: $connectionQuality',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: connectionColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Quality: $estimatedQuality',
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
          SizedBox(width: 3.w),
          Text(
            '${bandwidthKbps.toStringAsFixed(0)} kbps',
            style: AppTheme.getDataTextStyle(
              isLight: !isDark,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
