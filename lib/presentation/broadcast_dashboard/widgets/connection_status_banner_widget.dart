import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConnectionStatusBannerWidget extends StatelessWidget {
  final String connectionStatus;
  final String networkType;
  final double? bandwidth;
  final VoidCallback? onTap;
  final bool isExpanded;

  const ConnectionStatusBannerWidget({
    Key? key,
    required this.connectionStatus,
    required this.networkType,
    this.bandwidth,
    this.onTap,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool hasIssues = connectionStatus.toLowerCase() != 'good' &&
        connectionStatus.toLowerCase() != 'excellent';

    if (!hasIssues) return const SizedBox.shrink();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Material(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                _buildHeader(),
                if (isExpanded) ...[
                  SizedBox(height: 2.h),
                  _buildExpandedContent(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: _getIconBackgroundColor(),
            shape: BoxShape.circle,
          ),
          child: CustomIconWidget(
            iconName: _getStatusIcon(),
            color: _getIconColor(),
            size: 5.w,
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _getStatusTitle(),
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  color: _getTextColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 0.5.h),
              Text(
                _getStatusSubtitle(),
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: _getTextColor().withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        CustomIconWidget(
          iconName: isExpanded ? 'keyboard_arrow_up' : 'keyboard_arrow_down',
          color: _getTextColor().withValues(alpha: 0.7),
          size: 6.w,
        ),
      ],
    );
  }

  Widget _buildExpandedContent() {
    return Container(
      padding: EdgeInsets.all(3.w),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildDetailRow('Network Type', networkType),
          SizedBox(height: 1.h),
          _buildDetailRow(
              'Bandwidth',
              bandwidth != null
                  ? '${bandwidth!.toStringAsFixed(1)} Mbps'
                  : 'Unknown'),
          SizedBox(height: 1.h),
          _buildDetailRow('Status', connectionStatus),
          SizedBox(height: 2.h),
          _buildRecommendations(),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: _getTextColor().withValues(alpha: 0.8),
          ),
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: _getTextColor(),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendations() {
    List<String> recommendations = [];

    switch (connectionStatus.toLowerCase()) {
      case 'poor':
        recommendations = [
          'Move closer to WiFi router',
          'Close other apps using internet',
          'Switch to cellular if available',
        ];
        break;
      case 'bad':
      case 'disconnected':
        recommendations = [
          'Check your internet connection',
          'Try switching between WiFi and cellular',
          'Restart your network connection',
        ];
        break;
    }

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recommendations:',
          style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
            color: _getTextColor(),
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(height: 1.h),
        ...recommendations.map((recommendation) => Padding(
              padding: EdgeInsets.only(bottom: 0.5.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                      color: _getTextColor().withValues(alpha: 0.8),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      recommendation,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: _getTextColor().withValues(alpha: 0.8),
                      ),
                    ),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Color _getBackgroundColor() {
    switch (connectionStatus.toLowerCase()) {
      case 'poor':
      case 'fair':
        return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.1);
      case 'bad':
      case 'disconnected':
        return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.1);
      default:
        return AppTheme.lightTheme.colorScheme.surface;
    }
  }

  Color _getIconBackgroundColor() {
    switch (connectionStatus.toLowerCase()) {
      case 'poor':
      case 'fair':
        return AppTheme.lightTheme.colorScheme.tertiary.withValues(alpha: 0.2);
      case 'bad':
      case 'disconnected':
        return AppTheme.lightTheme.colorScheme.error.withValues(alpha: 0.2);
      default:
        return AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.2);
    }
  }

  Color _getIconColor() {
    return AppTheme.getConnectionStatusColor(connectionStatus);
  }

  Color _getTextColor() {
    return AppTheme.lightTheme.colorScheme.onSurface;
  }

  String _getStatusIcon() {
    switch (connectionStatus.toLowerCase()) {
      case 'poor':
      case 'fair':
        return 'signal_wifi_2_bar';
      case 'bad':
      case 'disconnected':
        return 'signal_wifi_off';
      default:
        return 'wifi';
    }
  }

  String _getStatusTitle() {
    switch (connectionStatus.toLowerCase()) {
      case 'poor':
        return 'Poor Connection';
      case 'fair':
        return 'Fair Connection';
      case 'bad':
        return 'Bad Connection';
      case 'disconnected':
        return 'Connection Lost';
      default:
        return 'Connection Issues';
    }
  }

  String _getStatusSubtitle() {
    switch (connectionStatus.toLowerCase()) {
      case 'poor':
        return 'Video quality may be reduced';
      case 'fair':
        return 'Some features may be limited';
      case 'bad':
        return 'Streaming may be interrupted';
      case 'disconnected':
        return 'Attempting to reconnect...';
      default:
        return 'Tap for more details';
    }
  }
}
