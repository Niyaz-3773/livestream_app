import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BroadcastPreferencesWidget extends StatefulWidget {
  final Map<String, dynamic> preferences;
  final Function(String, dynamic) onPreferenceChanged;

  const BroadcastPreferencesWidget({
    Key? key,
    required this.preferences,
    required this.onPreferenceChanged,
  }) : super(key: key);

  @override
  State<BroadcastPreferencesWidget> createState() =>
      _BroadcastPreferencesWidgetState();
}

class _BroadcastPreferencesWidgetState
    extends State<BroadcastPreferencesWidget> {
  double _microphoneSensitivity = 0.7;
  double _currentLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _microphoneSensitivity =
        (widget.preferences['microphoneSensitivity'] as double?) ?? 0.7;
    _simulateMicrophoneLevel();
  }

  void _simulateMicrophoneLevel() {
    // Simulate real-time microphone level indicator
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _currentLevel = (_currentLevel + 0.1) % 1.0;
        });
        _simulateMicrophoneLevel();
      }
    });
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
            'Broadcast Preferences',
            style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 2.h),
          _buildVideoQualityOption(),
          SizedBox(height: 2.h),
          _buildAutoJoinAudioOption(),
          SizedBox(height: 2.h),
          _buildCameraSelectionOption(),
          SizedBox(height: 2.h),
          _buildMicrophoneSensitivityOption(),
        ],
      ),
    );
  }

  Widget _buildVideoQualityOption() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'video_settings',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Default Video Quality',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              DropdownButton<String>(
                value: widget.preferences['videoQuality'] as String? ?? 'HD',
                items: ['HD', '720p', '480p', 'Auto'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.onPreferenceChanged('videoQuality', newValue);
                  }
                },
                underline: Container(),
                isDense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAutoJoinAudioOption() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'mic',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Text(
            'Auto-join Audio',
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: AppTheme.lightTheme.colorScheme.onSurface,
            ),
          ),
        ),
        Switch(
          value: widget.preferences['autoJoinAudio'] as bool? ?? true,
          onChanged: (bool value) {
            widget.onPreferenceChanged('autoJoinAudio', value);
          },
        ),
      ],
    );
  }

  Widget _buildCameraSelectionOption() {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'camera_alt',
          color: AppTheme.lightTheme.colorScheme.primary,
          size: 20,
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Camera Selection',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: AppTheme.lightTheme.colorScheme.onSurface,
                ),
              ),
              SizedBox(height: 0.5.h),
              DropdownButton<String>(
                value:
                    widget.preferences['cameraSelection'] as String? ?? 'Front',
                items: ['Front', 'Rear'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      value,
                      style: AppTheme.lightTheme.textTheme.bodyMedium,
                    ),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    widget.onPreferenceChanged('cameraSelection', newValue);
                  }
                },
                underline: Container(),
                isDense: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMicrophoneSensitivityOption() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CustomIconWidget(
              iconName: 'tune',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 20,
            ),
            SizedBox(width: 3.w),
            Text(
              'Microphone Sensitivity',
              style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 1.h),
        Slider(
          value: _microphoneSensitivity,
          min: 0.0,
          max: 1.0,
          divisions: 10,
          label: '${(_microphoneSensitivity * 100).round()}%',
          onChanged: (double value) {
            setState(() {
              _microphoneSensitivity = value;
            });
            widget.onPreferenceChanged('microphoneSensitivity', value);
          },
        ),
        SizedBox(height: 1.h),
        Container(
          height: 1.h,
          decoration: BoxDecoration(
            color:
                AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(4),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: _currentLevel,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.getLiveIndicatorColor(),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
        SizedBox(height: 0.5.h),
        Text(
          'Real-time level indicator',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
