import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:record/record.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class AudioTestWidget extends StatefulWidget {
  final bool hasPermission;

  const AudioTestWidget({
    super.key,
    required this.hasPermission,
  });

  @override
  State<AudioTestWidget> createState() => _AudioTestWidgetState();
}

class _AudioTestWidgetState extends State<AudioTestWidget>
    with TickerProviderStateMixin {
  final AudioRecorder _audioRecorder = AudioRecorder();
  bool _isRecording = false;
  bool _isInitializing = false;
  double _audioLevel = 0.0;
  String? _errorMessage;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stopRecording();
    super.dispose();
  }

  Future<void> _startRecording() async {
    if (!widget.hasPermission) return;

    setState(() {
      _isInitializing = true;
      _errorMessage = null;
    });

    try {
      if (await _audioRecorder.hasPermission()) {
        const config = RecordConfig(
          encoder: AudioEncoder.wav,
          sampleRate: 44100,
          bitRate: 128000,
        );

        if (kIsWeb) {
          await _audioRecorder.start(config, path: 'test_recording.wav');
        } else {
          await _audioRecorder.start(config, path: 'test_recording.wav');
        }

        setState(() {
          _isRecording = true;
          _isInitializing = false;
        });

        _pulseController.repeat(reverse: true);
        _simulateAudioLevel();
      } else {
        setState(() {
          _errorMessage = 'Microphone permission not granted';
          _isInitializing = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to start audio recording';
        _isInitializing = false;
      });
    }
  }

  Future<void> _stopRecording() async {
    try {
      if (_isRecording) {
        await _audioRecorder.stop();
        setState(() {
          _isRecording = false;
          _audioLevel = 0.0;
        });
        _pulseController.stop();
      }
    } catch (e) {
      // Handle error silently
    }
  }

  void _simulateAudioLevel() {
    if (!_isRecording) return;

    // Simulate audio level changes for visual feedback
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_isRecording && mounted) {
        setState(() {
          _audioLevel = (0.2 +
              (0.8 * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000));
        });
        _simulateAudioLevel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.3),
          width: 1.0,
        ),
      ),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              CustomIconWidget(
                iconName: 'mic',
                size: 6.w,
                color: widget.hasPermission
                    ? AppTheme.lightTheme.colorScheme.secondary
                    : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Audio Test',
                      style:
                          AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Test your microphone quality',
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 3.h),

          // Audio level indicator
          Container(
            width: double.infinity,
            height: 8.h,
            decoration: BoxDecoration(
              color: AppTheme.lightTheme.colorScheme.surface,
              borderRadius: BorderRadius.circular(8.0),
              border: Border.all(
                color: AppTheme.lightTheme.colorScheme.outline
                    .withValues(alpha: 0.2),
              ),
            ),
            child: _buildAudioLevelIndicator(),
          ),
          SizedBox(height: 2.h),

          // Control button
          SizedBox(
            width: double.infinity,
            child: _buildControlButton(),
          ),

          if (_errorMessage != null) ...[
            SizedBox(height: 2.h),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(3.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.error
                    .withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Row(
                children: [
                  CustomIconWidget(
                    iconName: 'error_outline',
                    size: 4.w,
                    color: AppTheme.lightTheme.colorScheme.error,
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAudioLevelIndicator() {
    if (!widget.hasPermission) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'mic_off',
              size: 8.w,
              color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
            ),
            SizedBox(height: 1.h),
            Text(
              'Microphone access required',
              style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.all(2.w),
      child: Row(
        children: [
          // Microphone icon with animation
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isRecording ? _pulseAnimation.value : 1.0,
                child: Container(
                  width: 12.w,
                  height: 12.w,
                  decoration: BoxDecoration(
                    color: _isRecording
                        ? AppTheme.lightTheme.colorScheme.secondary
                            .withValues(alpha: 0.2)
                        : AppTheme.lightTheme.colorScheme.surface,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isRecording
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.3),
                      width: 2.0,
                    ),
                  ),
                  child: Center(
                    child: CustomIconWidget(
                      iconName: _isRecording ? 'mic' : 'mic_none',
                      size: 6.w,
                      color: _isRecording
                          ? AppTheme.lightTheme.colorScheme.secondary
                          : AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(width: 3.w),

          // Audio level bars
          Expanded(
            child: Row(
              children: List.generate(20, (index) {
                final barHeight = (index + 1) * 0.05;
                final isActive = _audioLevel >= barHeight;

                return Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 0.2.w),
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: isActive
                          ? _getBarColor(barHeight)
                          : AppTheme.lightTheme.colorScheme.outline
                              .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(1.0),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Color _getBarColor(double level) {
    if (level < 0.3) {
      return AppTheme.lightTheme.colorScheme.secondary;
    } else if (level < 0.7) {
      return Colors.orange;
    } else {
      return AppTheme.lightTheme.colorScheme.error;
    }
  }

  Widget _buildControlButton() {
    if (!widget.hasPermission) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              AppTheme.lightTheme.colorScheme.outline.withValues(alpha: 0.1),
          foregroundColor: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
        ),
        child: Text('Microphone Permission Required'),
      );
    }

    if (_isInitializing) {
      return ElevatedButton(
        onPressed: null,
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 1.5.h),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 4.w,
              height: 4.w,
              child: CircularProgressIndicator(
                strokeWidth: 2.0,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            SizedBox(width: 2.w),
            Text('Initializing...'),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: _isRecording ? _stopRecording : _startRecording,
      style: ElevatedButton.styleFrom(
        backgroundColor: _isRecording
            ? AppTheme.lightTheme.colorScheme.error
            : AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 1.5.h),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CustomIconWidget(
            iconName: _isRecording ? 'stop' : 'play_arrow',
            size: 4.w,
            color: Colors.white,
          ),
          SizedBox(width: 2.w),
          Text(_isRecording ? 'Stop Test' : 'Start Audio Test'),
        ],
      ),
    );
  }
}
