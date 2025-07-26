import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class NetworkSettingsWidget extends StatefulWidget {
  final Map<String, dynamic> networkSettings;
  final Function(String, dynamic) onSettingChanged;

  const NetworkSettingsWidget({
    Key? key,
    required this.networkSettings,
    required this.onSettingChanged,
  }) : super(key: key);

  @override
  State<NetworkSettingsWidget> createState() => _NetworkSettingsWidgetState();
}

class _NetworkSettingsWidgetState extends State<NetworkSettingsWidget> {
  double _bandwidthLimit = 5.0;

  @override
  void initState() {
    super.initState();
    _bandwidthLimit =
        (widget.networkSettings['bandwidthLimit'] as double?) ?? 5.0;
  }

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
            'Network Settings',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildBandwidthLimitOption(),
          SizedBox(height: 2.h),
          _buildCellularDataOption(),
          SizedBox(height: 2.h),
          _buildAutoQualityOption(),
        ],
      ),
    );
  }

  Widget _buildBandwidthLimitOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'speed',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Bandwidth Limit',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Slider(
          value: _bandwidthLimit,
          min: 1.0,
          max: 10.0,
          divisions: 9,
          label: '${_bandwidthLimit.toStringAsFixed(1)} Mbps',
          onChanged: (double value) {
            setState(() {
              _bandwidthLimit = value;
            });
            widget.onSettingChanged('bandwidthLimit', value);
          },
        ),
        Text(
          'Current: ${_bandwidthLimit.toStringAsFixed(1)} Mbps',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildCellularDataOption() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'signal_cellular_alt',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Use Cellular Data',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Allow streaming over cellular network',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: widget.networkSettings['useCellularData'] as bool? ?? true,
          onChanged: (bool value) {
            widget.onSettingChanged('useCellularData', value);
          },
        ),
      ],
    );
  }

  Widget _buildAutoQualityOption() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'auto_awesome',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Automatic Quality Adjustment',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              Text(
                'Adjust video quality based on connection',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value:
              widget.networkSettings['autoQualityAdjustment'] as bool? ?? true,
          onChanged: (bool value) {
            widget.onSettingChanged('autoQualityAdjustment', value);
          },
        ),
      ],
    );
  }
}
