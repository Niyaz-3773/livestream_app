import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../theme/app_theme.dart';
import './widgets/camera_rotation_controls.dart';
import './widgets/enhanced_camera_flip_button.dart';
import './widgets/framing_guides.dart';
import './widgets/network_bandwidth_indicator.dart';
import './widgets/network_quality_banner.dart';
import './widgets/permission_status_overlay.dart';
import './widgets/streaming_controls.dart';
import './widgets/video_quality_selector.dart';

class CameraPreviewScreen extends StatefulWidget {
  const CameraPreviewScreen({super.key});

  @override
  State<CameraPreviewScreen> createState() => _CameraPreviewScreenState();
}

class _CameraPreviewScreenState extends State<CameraPreviewScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Camera related
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlipping = false;
  bool _hasPermission = false;
  int _currentCameraIndex = 0;
  double _cameraRotation = 0.0;
  bool _showRotationControls = false;

  // Network monitoring
  String _connectionQuality = 'good';
  double _bandwidthKbps = 1500.0;
  String _estimatedQuality = 'HD';
  String _recommendedQuality = 'HD';

  // UI state
  String _selectedQuality = 'HD';
  bool _isLoading = false;
  bool _showFramingGuides = true;
  bool _showQualityBanner = false;
  String _bannerRecommendation = '';

  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _rotationToggleController;

  // Mock streaming data
  final List<Map<String, dynamic>> _networkSimulation = [
    {
      "timestamp": "2025-07-18T06:18:07.298159",
      "quality": "excellent",
      "bandwidth": 2500.0,
      "estimated": "HD",
      "recommended": "HD",
      "latency": 45,
    },
    {
      "timestamp": "2025-07-18T06:18:12.298159",
      "quality": "good",
      "bandwidth": 1800.0,
      "estimated": "HD",
      "recommended": "HD",
      "latency": 65,
    },
    {
      "timestamp": "2025-07-18T06:18:17.298159",
      "quality": "poor",
      "bandwidth": 800.0,
      "estimated": "SD",
      "recommended": "SD",
      "latency": 120,
    },
    {
      "timestamp": "2025-07-18T06:18:22.298159",
      "quality": "bad",
      "bandwidth": 200.0,
      "estimated": "Audio-only",
      "recommended": "Audio-only",
      "latency": 300,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _rotationToggleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _initializeCamera();
    _startNetworkMonitoring();
    _fadeController.forward();
    _slideController.forward();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _fadeController.dispose();
    _slideController.dispose();
    _rotationToggleController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      _cameraController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<void> _initializeCamera() async {
    try {
      // Request camera permission
      final hasPermission = await _requestCameraPermission();
      setState(() {
        _hasPermission = hasPermission;
      });

      if (!hasPermission) return;

      // Get available cameras
      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      // Select appropriate camera based on platform
      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _currentCameraIndex = _cameras.indexOf(camera);

      // Initialize camera controller
      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();

      // Apply platform-specific settings
      await _applySettings();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        _showErrorToast('Failed to initialize camera');
      }
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true; // Browser handles permissions

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _applySettings() async {
    if (_cameraController == null) return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        try {
          await _cameraController!.setFlashMode(FlashMode.auto);
        } catch (e) {
          debugPrint('Flash mode not supported: $e');
        }
      }
    } catch (e) {
      debugPrint('Settings application error: $e');
    }
  }

  void _startNetworkMonitoring() {
    int simulationIndex = 0;

    // Simulate network quality changes every 5 seconds
    Future.delayed(Duration.zero, () {
      _updateNetworkQuality(simulationIndex);
    });

    // Continue simulation
    Stream.periodic(const Duration(seconds: 5)).listen((_) {
      simulationIndex = (simulationIndex + 1) % _networkSimulation.length;
      _updateNetworkQuality(simulationIndex);
    });
  }

  void _updateNetworkQuality(int index) {
    if (!mounted) return;

    final data = _networkSimulation[index];
    final quality = data["quality"] as String;
    final bandwidth = data["bandwidth"] as double;
    final estimated = data["estimated"] as String;
    final recommended = data["recommended"] as String;

    setState(() {
      _connectionQuality = quality;
      _bandwidthKbps = bandwidth;
      _estimatedQuality = estimated;
      _recommendedQuality = recommended;

      // Show banner for poor/bad connections
      _showQualityBanner = quality == 'poor' || quality == 'bad';
      _bannerRecommendation = quality == 'poor'
          ? 'Consider switching to SD quality for better performance'
          : quality == 'bad'
              ? 'Audio-only mode recommended for stable connection'
              : '';
    });
  }

  Future<void> _flipCamera() async {
    if (_cameras.length < 2 || _isFlipping) return;

    setState(() {
      _isFlipping = true;
    });

    try {
      await _cameraController?.dispose();

      _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
      final newCamera = _cameras[_currentCameraIndex];

      _cameraController = CameraController(
        newCamera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: true,
      );

      await _cameraController!.initialize();
      await _applySettings();

      if (mounted) {
        setState(() {
          _isFlipping = false;
        });
      }
    } catch (e) {
      debugPrint('Camera flip error: $e');
      setState(() {
        _isFlipping = false;
      });
      _showErrorToast('Failed to flip camera');
    }
  }

  void _onRotationChanged(double rotation) {
    setState(() {
      _cameraRotation = rotation;
    });
  }

  void _toggleRotationControls() {
    setState(() {
      _showRotationControls = !_showRotationControls;
    });

    if (_showRotationControls) {
      _rotationToggleController.forward();
    } else {
      _rotationToggleController.reverse();
    }

    HapticFeedback.lightImpact();
  }

  bool get _isFrontCamera {
    if (_cameras.isEmpty || _currentCameraIndex >= _cameras.length)
      return false;
    return _cameras[_currentCameraIndex].lensDirection ==
        CameraLensDirection.front;
  }

  Future<void> _startVideoStreaming() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate streaming initialization
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) {
        _showSuccessToast('Video streaming started');
        Navigator.pushNamed(context, '/broadcast-viewer-screen');
      }
    } catch (e) {
      _showErrorToast('Failed to start video streaming');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _startAudioOnlyStreaming() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Simulate audio streaming initialization
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _showSuccessToast('Audio streaming started');
        Navigator.pushNamed(context, '/broadcast-viewer-screen');
      }
    } catch (e) {
      _showErrorToast('Failed to start audio streaming');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _cancelPreview() {
    Navigator.pop(context);
  }

  void _onQualityChanged(String quality) {
    setState(() {
      _selectedQuality = quality;
    });

    HapticFeedback.selectionClick();
    _showInfoToast('Quality set to $quality');
  }

  void _onTapToFocus(TapDownDetails details) async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final RenderBox renderBox = context.findRenderObject() as RenderBox;
      final localPosition = renderBox.globalToLocal(details.globalPosition);
      final double x = localPosition.dx / renderBox.size.width;
      final double y = localPosition.dy / renderBox.size.height;

      await _cameraController!.setFocusPoint(Offset(x, y));
      await _cameraController!.setExposurePoint(Offset(x, y));

      HapticFeedback.lightImpact();
      _showInfoToast('Focus adjusted');
    } catch (e) {
      debugPrint('Focus adjustment error: $e');
    }
  }

  void _openSettings() async {
    await openAppSettings();
  }

  void _dismissBanner() {
    setState(() {
      _showQualityBanner = false;
    });
  }

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: AppTheme.lightTheme.colorScheme.onError,
    );
  }

  void _showSuccessToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      textColor: AppTheme.lightTheme.colorScheme.onSecondary,
    );
  }

  void _showInfoToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      textColor: AppTheme.lightTheme.colorScheme.onSurface,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera preview with rotation
          if (_isCameraInitialized && _cameraController != null)
            Positioned.fill(
              child: GestureDetector(
                onTapDown: _onTapToFocus,
                child: FadeTransition(
                  opacity: _fadeController,
                  child: Transform.rotate(
                    angle: _cameraRotation * 3.14159 / 180,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),
            ),

          // Loading indicator for camera initialization
          if (!_isCameraInitialized && _hasPermission)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),

          // Framing guides overlay
          if (_isCameraInitialized)
            FramingGuides(isVisible: _showFramingGuides),

          // Top section with network indicator and camera controls
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -1),
                  end: Offset.zero,
                ).animate(CurvedAnimation(
                  parent: _slideController,
                  curve: Curves.easeOutCubic,
                )),
                child: Container(
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      NetworkBandwidthIndicator(
                        connectionQuality: _connectionQuality,
                        estimatedQuality: _estimatedQuality,
                        bandwidthKbps: _bandwidthKbps,
                      ),
                      Row(
                        children: [
                          // Rotation toggle button
                          GestureDetector(
                            onTap: _toggleRotationControls,
                            child: Container(
                              width: 12.w,
                              height: 12.w,
                              margin: EdgeInsets.only(right: 2.w),
                              decoration: BoxDecoration(
                                color: _showRotationControls
                                    ? Colors.blue.withAlpha(204)
                                    : Colors.black.withAlpha(179),
                                borderRadius: BorderRadius.circular(6.w),
                                border: Border.all(
                                  color: Colors.white.withAlpha(77),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.screen_rotation,
                                color: Colors.white,
                                size: 6.w,
                              ),
                            ),
                          ),
                          // Enhanced camera flip button
                          if (_cameras.length > 1)
                            EnhancedCameraFlipButton(
                              onFlip: _flipCamera,
                              isFlipping: _isFlipping,
                              isFrontCamera: _isFrontCamera,
                              totalCameras: _cameras.length,
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Camera rotation controls
          Positioned(
            top: 18.h,
            left: 0,
            right: 0,
            child: CameraRotationControls(
              currentRotation: _cameraRotation,
              onRotationChanged: _onRotationChanged,
              isVisible: _showRotationControls,
            ),
          ),

          // Network quality warning banner
          Positioned(
            top: 15.h,
            left: 0,
            right: 0,
            child: NetworkQualityBanner(
              networkQuality: _connectionQuality,
              recommendation: _bannerRecommendation,
              isVisible: _showQualityBanner,
              onDismiss: _dismissBanner,
            ),
          ),

          // Video quality selector
          Positioned(
            bottom: 25.h,
            left: 0,
            right: 0,
            child: VideoQualitySelector(
              selectedQuality: _selectedQuality,
              onQualityChanged: _onQualityChanged,
              recommendedQuality: _recommendedQuality,
              isVisible: _isCameraInitialized,
            ),
          ),

          // Bottom streaming controls
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: _slideController,
                curve: Curves.easeOutCubic,
              )),
              child: StreamingControls(
                onStartVideo: _startVideoStreaming,
                onAudioOnly: _startAudioOnlyStreaming,
                onCancel: _cancelPreview,
                isLoading: _isLoading,
                networkQuality: _connectionQuality,
              ),
            ),
          ),

          // Permission status overlay
          PermissionStatusOverlay(
            hasPermission: _hasPermission,
            onRequestPermission: _initializeCamera,
            onOpenSettings: _openSettings,
          ),
        ],
      ),
    );
  }
}
