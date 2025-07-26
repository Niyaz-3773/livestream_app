import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/audio_test_widget.dart';
import './widgets/camera_preview_widget.dart';
import './widgets/permission_card_widget.dart';
import './widgets/progress_indicator_widget.dart';

class PermissionRequestScreen extends StatefulWidget {
  const PermissionRequestScreen({super.key});

  @override
  State<PermissionRequestScreen> createState() =>
      _PermissionRequestScreenState();
}

class _PermissionRequestScreenState extends State<PermissionRequestScreen> {
  bool _cameraPermissionGranted = false;
  bool _microphonePermissionGranted = false;
  bool _isCameraLoading = false;
  bool _isMicrophoneLoading = false;
  int _currentStep = 0;

  final List<String> _stepLabels = [
    'Camera\nAccess',
    'Microphone\nAccess',
    'Setup\nComplete'
  ];

  @override
  void initState() {
    super.initState();
    _checkExistingPermissions();
  }

  Future<void> _checkExistingPermissions() async {
    if (kIsWeb) {
      // Web permissions are handled by browser
      return;
    }

    final cameraStatus = await Permission.camera.status;
    final microphoneStatus = await Permission.microphone.status;

    setState(() {
      _cameraPermissionGranted = cameraStatus.isGranted;
      _microphonePermissionGranted = microphoneStatus.isGranted;
      _updateCurrentStep();
    });
  }

  void _updateCurrentStep() {
    if (!_cameraPermissionGranted) {
      _currentStep = 0;
    } else if (!_microphonePermissionGranted) {
      _currentStep = 1;
    } else {
      _currentStep = 2;
    }
  }

  Future<void> _requestCameraPermission() async {
    setState(() {
      _isCameraLoading = true;
    });

    try {
      if (kIsWeb) {
        // Web permissions are handled by browser when camera is accessed
        setState(() {
          _cameraPermissionGranted = true;
        });
      } else {
        final status = await Permission.camera.request();
        setState(() {
          _cameraPermissionGranted = status.isGranted;
        });

        if (status.isPermanentlyDenied) {
          _showSettingsDialog('Camera');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to request camera permission');
    } finally {
      setState(() {
        _isCameraLoading = false;
        _updateCurrentStep();
      });
    }
  }

  Future<void> _requestMicrophonePermission() async {
    setState(() {
      _isMicrophoneLoading = true;
    });

    try {
      if (kIsWeb) {
        // Web permissions are handled by browser when microphone is accessed
        setState(() {
          _microphonePermissionGranted = true;
        });
      } else {
        final status = await Permission.microphone.request();
        setState(() {
          _microphonePermissionGranted = status.isGranted;
        });

        if (status.isPermanentlyDenied) {
          _showSettingsDialog('Microphone');
        }
      }
    } catch (e) {
      _showErrorSnackBar('Failed to request microphone permission');
    } finally {
      setState(() {
        _isMicrophoneLoading = false;
        _updateCurrentStep();
      });
    }
  }

  void _showSettingsDialog(String permissionType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '$permissionType Permission Required',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'LiveStream Connect needs $permissionType access for broadcasting. Please enable it in your device settings.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                openAppSettings();
              },
              child: Text('Open Settings'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.lightTheme.colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _continueToApp() {
    if (_cameraPermissionGranted && _microphonePermissionGranted) {
      Navigator.pushReplacementNamed(context, '/broadcast-dashboard');
    } else {
      _showIncompletePermissionsDialog();
    }
  }

  void _showIncompletePermissionsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Incomplete Setup',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Text(
            'For the best broadcasting experience, please grant both camera and microphone permissions.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/broadcast-dashboard');
              },
              child: Text('Continue Anyway'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Grant Permissions'),
            ),
          ],
        );
      },
    );
  }

  void _skipSetup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Skip Permission Setup?',
            style: AppTheme.lightTheme.textTheme.titleLarge,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Without proper permissions, you will have limited functionality:',
                style: AppTheme.lightTheme.textTheme.bodyMedium,
              ),
              SizedBox(height: 2.h),
              _buildLimitationItem('• No video broadcasting capability'),
              _buildLimitationItem('• No audio streaming features'),
              _buildLimitationItem('• View-only mode for broadcasts'),
              SizedBox(height: 2.h),
              Text(
                'You can enable permissions later in Settings.',
                style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacementNamed(context, '/broadcast-dashboard');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.error,
              ),
              child: Text('Skip Setup'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLimitationItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.h),
      child: Text(
        text,
        style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
          color: AppTheme.lightTheme.colorScheme.error,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Setup Permissions',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 6.w,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            ProgressIndicatorWidget(
              currentStep: _currentStep,
              totalSteps: 3,
              stepLabels: _stepLabels,
            ),

            // Main content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 2.h),

                    // Header section
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4.w),
                      child: Column(
                        children: [
                          CustomIconWidget(
                            iconName: 'broadcast_on_personal',
                            size: 20.w,
                            color: AppTheme.lightTheme.colorScheme.primary,
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'LiveStream Connect',
                            style: AppTheme.lightTheme.textTheme.headlineMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: AppTheme.lightTheme.colorScheme.primary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 1.h),
                          Text(
                            'To provide the best broadcasting experience, we need access to your camera and microphone.',
                            style: AppTheme.lightTheme.textTheme.bodyLarge
                                ?.copyWith(
                              color: AppTheme
                                  .lightTheme.colorScheme.onSurfaceVariant,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 3.h),

                    // Permission cards
                    PermissionCardWidget(
                      iconName: 'videocam',
                      title: 'Camera Access',
                      description:
                          'Required for video broadcasting and live streaming to share your video feed with viewers.',
                      isGranted: _cameraPermissionGranted,
                      onTap: _requestCameraPermission,
                      isLoading: _isCameraLoading,
                    ),

                    PermissionCardWidget(
                      iconName: 'mic',
                      title: 'Microphone Access',
                      description:
                          'Required for audio broadcasting and live streaming to share your voice with viewers.',
                      isGranted: _microphonePermissionGranted,
                      onTap: _requestMicrophonePermission,
                      isLoading: _isMicrophoneLoading,
                    ),

                    SizedBox(height: 2.h),

                    // Camera preview section
                    if (_cameraPermissionGranted || _currentStep >= 1) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Camera Preview',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      CameraPreviewWidget(
                        hasPermission: _cameraPermissionGranted,
                        onRetry: _requestCameraPermission,
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Audio test section
                    if (_microphonePermissionGranted || _currentStep >= 2) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Audio Test',
                            style: AppTheme.lightTheme.textTheme.titleMedium
                                ?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 1.h),
                      AudioTestWidget(
                        hasPermission: _microphonePermissionGranted,
                      ),
                      SizedBox(height: 2.h),
                    ],

                    // Setup complete message
                    if (_cameraPermissionGranted &&
                        _microphonePermissionGranted) ...[
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.symmetric(horizontal: 4.w),
                        padding: EdgeInsets.all(4.w),
                        decoration: BoxDecoration(
                          color: AppTheme.lightTheme.colorScheme.secondary
                              .withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                            color: AppTheme.lightTheme.colorScheme.secondary
                                .withValues(alpha: 0.3),
                          ),
                        ),
                        child: Column(
                          children: [
                            CustomIconWidget(
                              iconName: 'check_circle',
                              size: 12.w,
                              color: AppTheme.lightTheme.colorScheme.secondary,
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'Setup Complete!',
                              style: AppTheme.lightTheme.textTheme.titleLarge
                                  ?.copyWith(
                                color:
                                    AppTheme.lightTheme.colorScheme.secondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            Text(
                              'You\'re all set to start broadcasting with full video and audio capabilities.',
                              style: AppTheme.lightTheme.textTheme.bodyMedium
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 3.h),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action buttons
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: AppTheme.lightTheme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.lightTheme.colorScheme.shadow,
                    blurRadius: 8.0,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Continue button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _continueToApp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: (_cameraPermissionGranted &&
                                _microphonePermissionGranted)
                            ? AppTheme.lightTheme.colorScheme.secondary
                            : AppTheme.lightTheme.colorScheme.primary,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            (_cameraPermissionGranted &&
                                    _microphonePermissionGranted)
                                ? 'Start Broadcasting'
                                : 'Continue',
                            style: AppTheme.lightTheme.textTheme.labelLarge
                                ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(width: 2.w),
                          CustomIconWidget(
                            iconName: (_cameraPermissionGranted &&
                                    _microphonePermissionGranted)
                                ? 'play_arrow'
                                : 'arrow_forward',
                            size: 4.w,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),

                  // Skip button
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: _skipSetup,
                      style: TextButton.styleFrom(
                        foregroundColor:
                            AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      ),
                      child: Text(
                        'Skip for Now (Limited Functionality)',
                        style:
                            AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
