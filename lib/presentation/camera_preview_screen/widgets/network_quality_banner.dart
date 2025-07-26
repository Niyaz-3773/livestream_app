import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NetworkQualityBanner extends StatelessWidget {
  final String networkQuality;
  final String recommendation;
  final bool isVisible;
  final VoidCallback? onDismiss;

  const NetworkQualityBanner({
    super.key,
    required this.networkQuality,
    required this.recommendation,
    this.isVisible = true,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible ||
        networkQuality == 'good' ||
        networkQuality == 'excellent') {
      return const SizedBox.shrink();
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bannerColor =
        AppTheme.getConnectionStatusColor(networkQuality, isDark: isDark);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: bannerColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          CustomIconWidget(
            iconName: networkQuality == 'poor'
                ? 'signal_wifi_2_bar'
                : 'signal_wifi_off',
            size: 5.w,
            color: bannerColor,
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  networkQuality == 'poor'
                      ? 'Poor Connection'
                      : 'Connection Issues',
                  style: AppTheme.lightTheme.textTheme.labelMedium?.copyWith(
                    color: bannerColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (recommendation.isNotEmpty) ...[
                  SizedBox(height: 0.5.h),
                  Text(
                    recommendation,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.lightTheme.colorScheme.onSurface
                          .withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Container(
                padding: EdgeInsets.all(1.w),
                child: CustomIconWidget(
                  iconName: 'close',
                  size: 4.w,
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.6),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
