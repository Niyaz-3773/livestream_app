import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class NetworkDiagnosticsWidget extends StatefulWidget {
  final VoidCallback onTestConnection;
  final bool isTestingConnection;
  final Map<String, dynamic>? testResults;

  const NetworkDiagnosticsWidget({
    Key? key,
    required this.onTestConnection,
    required this.isTestingConnection,
    this.testResults,
  }) : super(key: key);

  @override
  State<NetworkDiagnosticsWidget> createState() =>
      _NetworkDiagnosticsWidgetState();
}

class _NetworkDiagnosticsWidgetState extends State<NetworkDiagnosticsWidget> {
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
            Text(
              'Network Diagnostics',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ElevatedButton(
              onPressed:
                  widget.isTestingConnection ? null : widget.onTestConnection,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: widget.isTestingConnection
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.lightTheme.colorScheme.onPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Text('Testing Connection...'),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CustomIconWidget(
                          iconName: 'speed',
                          color: AppTheme.lightTheme.colorScheme.onPrimary,
                          size: 20,
                        ),
                        SizedBox(width: 3.w),
                        Text('Test Connection'),
                      ],
                    ),
            ),
            if (widget.testResults != null) ...[
              SizedBox(height: 3.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(3.w),
                decoration: BoxDecoration(
                  color: AppTheme.lightTheme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.lightTheme.dividerColor,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Test Results',
                      style: AppTheme.lightTheme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    _buildResultRow(
                      'Overall Quality',
                      widget.testResults!['quality'] as String,
                      _getQualityColor(
                          widget.testResults!['quality'] as String),
                    ),
                    SizedBox(height: 1.h),
                    _buildResultRow(
                      'Latency',
                      '${widget.testResults!['latency']} ms',
                      AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    SizedBox(height: 1.h),
                    _buildResultRow(
                      'Packet Loss',
                      '${widget.testResults!['packetLoss']}%',
                      AppTheme.lightTheme.colorScheme.onSurface,
                    ),
                    if (widget.testResults!['recommendation'] != null) ...[
                      SizedBox(height: 2.h),
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(3.w),
                        decoration: BoxDecoration(
                          color: AppTheme.connectionPoorLight
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CustomIconWidget(
                                  iconName: 'lightbulb',
                                  color: AppTheme.connectionPoorLight,
                                  size: 16,
                                ),
                                SizedBox(width: 2.w),
                                Text(
                                  'Recommendation',
                                  style: AppTheme
                                      .lightTheme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: AppTheme.connectionPoorLight,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              widget.testResults!['recommendation'] as String,
                              style: AppTheme.lightTheme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTheme.lightTheme.textTheme.bodyMedium,
        ),
        Text(
          value,
          style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
            color: valueColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Color _getQualityColor(String quality) {
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
}
