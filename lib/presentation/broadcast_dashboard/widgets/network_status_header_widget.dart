import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NetworkStatusHeaderWidget extends StatelessWidget {
  final String userAvatar;
  final String userName;
  final String networkType;
  final String connectionStatus;
  final double? bandwidth;
  final int notificationCount;
  final VoidCallback? onProfileTap;
  final VoidCallback? onNotificationTap;

  const NetworkStatusHeaderWidget({
    Key? key,
    required this.userAvatar,
    required this.userName,
    required this.networkType,
    required this.connectionStatus,
    this.bandwidth,
    this.notificationCount = 0,
    this.onProfileTap,
    this.onNotificationTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 2.h, 4.w, 2.h),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: AppTheme.lightTheme.colorScheme.shadow,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            _buildUserProfile(),
            SizedBox(width: 4.w),
            Expanded(child: _buildNetworkStatus()),
            SizedBox(width: 4.w),
            _buildNotificationButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUserProfile() {
    return GestureDetector(
      onTap: onProfileTap,
      child: Container(
        width: 12.w,
        height: 12.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppTheme.lightTheme.colorScheme.primary,
            width: 2,
          ),
        ),
        child: ClipOval(
          child: CustomImageWidget(
            imageUrl: userAvatar,
            width: 12.w,
            height: 12.w,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkStatus() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $userName',
          style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 0.5.h),
        Row(
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
              decoration: BoxDecoration(
                color: _getNetworkStatusColor().withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _getNetworkStatusColor().withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CustomIconWidget(
                    iconName: _getNetworkIcon(),
                    color: _getNetworkStatusColor(),
                    size: 4.w,
                  ),
                  SizedBox(width: 1.w),
                  Text(
                    networkType,
                    style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                      color: _getNetworkStatusColor(),
                      fontWeight: FontWeight.w600,
                      fontSize: 10.sp,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 2.w),
            if (bandwidth != null)
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.onSurface
                      .withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${bandwidth!.toStringAsFixed(1)} Mbps',
                  style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                    color: AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.7),
                    fontWeight: FontWeight.w500,
                    fontSize: 10.sp,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotificationButton() {
    return Stack(
      children: [
        IconButton(
          onPressed: onNotificationTap,
          icon: CustomIconWidget(
            iconName: 'notifications',
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.7),
            size: 6.w,
          ),
          style: IconButton.styleFrom(
            backgroundColor: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.05),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        if (notificationCount > 0)
          Positioned(
            right: 2.w,
            top: 2.w,
            child: Container(
              padding: EdgeInsets.all(1.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error,
                shape: BoxShape.circle,
              ),
              constraints: BoxConstraints(
                minWidth: 4.w,
                minHeight: 4.w,
              ),
              child: Text(
                notificationCount > 99 ? '99+' : notificationCount.toString(),
                style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 8.sp,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }

  Color _getNetworkStatusColor() {
    return AppTheme.getConnectionStatusColor(connectionStatus);
  }

  String _getNetworkIcon() {
    switch (networkType.toLowerCase()) {
      case 'wifi':
        return _getWifiIcon();
      case 'cellular':
      case '4g':
      case '5g':
        return 'signal_cellular_4_bar';
      case 'ethernet':
        return 'settings_ethernet';
      default:
        return 'signal_wifi_off';
    }
  }

  String _getWifiIcon() {
    switch (connectionStatus.toLowerCase()) {
      case 'excellent':
      case 'good':
        return 'wifi';
      case 'fair':
      case 'poor':
        return 'signal_wifi_2_bar';
      case 'bad':
      case 'disconnected':
        return 'signal_wifi_off';
      default:
        return 'wifi';
    }
  }
}
