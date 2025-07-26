import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NetworkStatusOverlayWidget extends StatelessWidget {
  final bool isVisible;
  final String status;
  final String message;
  final bool isReconnecting;
  final VoidCallback? onRetry;

  const NetworkStatusOverlayWidget({
    super.key,
    required this.isVisible,
    required this.status,
    required this.message,
    required this.isReconnecting,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withValues(alpha: 0.8),
      child: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 8.w),
          padding: EdgeInsets.all(6.w),
          decoration: BoxDecoration(
            color: AppTheme.lightTheme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusIcon(),
              SizedBox(height: 3.h),
              Text(
                _getStatusTitle(),
                style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 1.h),
              Text(
                message,
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 3.h),
              if (isReconnecting)
                _buildReconnectingIndicator()
              else if (onRetry != null)
                _buildRetryButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusIcon() {
    String iconName;
    Color iconColor;

    switch (status.toLowerCase()) {
      case 'reconnecting':
        iconName = 'wifi';
        iconColor = AppTheme.connectionPoorLight;
        break;
      case 'disconnected':
        iconName = 'wifi_off';
        iconColor = AppTheme.connectionBadLight;
        break;
      case 'poor_connection':
        iconName = 'signal_wifi_1_bar';
        iconColor = AppTheme.connectionPoorLight;
        break;
      default:
        iconName = 'error_outline';
        iconColor = AppTheme.errorLight;
    }

    return Container(
      width: 20.w,
      height: 20.w,
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: CustomIconWidget(
          iconName: iconName,
          color: iconColor,
          size: 40,
        ),
      ),
    );
  }

  String _getStatusTitle() {
    switch (status.toLowerCase()) {
      case 'reconnecting':
        return 'Reconnecting...';
      case 'disconnected':
        return 'Connection Lost';
      case 'poor_connection':
        return 'Poor Connection';
      default:
        return 'Network Issue';
    }
  }

  Widget _buildReconnectingIndicator() {
    return Column(
      children: [
        SizedBox(
          width: 8.w,
          height: 8.w,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.primary,
            ),
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          'Attempting to reconnect...',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRetryButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onRetry,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 2.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Retry Connection',
          style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
