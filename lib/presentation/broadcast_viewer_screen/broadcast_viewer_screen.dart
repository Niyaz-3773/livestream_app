import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/network_status_overlay_widget.dart';
import './widgets/participant_thumbnails_widget.dart';
import './widgets/side_panel_widget.dart';
import './widgets/video_overlay_controls_widget.dart';

class BroadcastViewerScreen extends StatefulWidget {
  const BroadcastViewerScreen({super.key});

  @override
  State<BroadcastViewerScreen> createState() => _BroadcastViewerScreenState();
}

class _BroadcastViewerScreenState extends State<BroadcastViewerScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  // Camera related
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _hasPermission = false;
  int _currentCameraIndex = 0;

  // UI State
  bool _isControlsVisible = true;
  bool _isFullScreen = false;
  bool _isSidePanelVisible = false;
  bool _isNetworkIssueVisible = false;

  // Broadcast State
  bool _isMuted = false;
  bool _isCameraOn = true;
  bool _isHandRaised = false;
  int? _handRaisePosition;
  String _connectionQuality = 'good';
  String _activeSpeakerId = '1';

  // Animation Controllers
  late AnimationController _controlsAnimationController;
  late AnimationController _handRaiseAnimationController;
  late Timer? _controlsHideTimer;

  // Mock Data
  final String _broadcastTitle = 'Weekly Team Standup - Q4 Planning';
  final int _participantCount = 12;

  final List<Map<String, dynamic>> _participants = [
    {
      'id': '1',
      'name': 'Sarah Johnson',
      'avatar':
          'https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': false,
      'isVideoOn': true,
      'isHost': true,
    },
    {
      'id': '2',
      'name': 'Michael Chen',
      'avatar':
          'https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': true,
      'isVideoOn': true,
      'isHost': false,
    },
    {
      'id': '3',
      'name': 'Emily Rodriguez',
      'avatar':
          'https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': false,
      'isVideoOn': false,
      'isHost': false,
    },
    {
      'id': '4',
      'name': 'David Kim',
      'avatar':
          'https://images.pexels.com/photos/1043471/pexels-photo-1043471.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': true,
      'isVideoOn': true,
      'isHost': false,
    },
    {
      'id': '5',
      'name': 'Lisa Thompson',
      'avatar':
          'https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400',
      'isMuted': false,
      'isVideoOn': true,
      'isHost': false,
    },
  ];

  final List<Map<String, dynamic>> _chatMessages = [
    {
      'sender': 'Sarah Johnson',
      'content':
          'Welcome everyone! Let\'s start with our Q4 planning discussion.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
      'isHost': true,
    },
    {
      'sender': 'Michael Chen',
      'content': 'Thanks for organizing this session, Sarah!',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 4)),
      'isHost': false,
    },
    {
      'sender': 'Emily Rodriguez',
      'content': 'I have the quarterly reports ready to share.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 3)),
      'isHost': false,
    },
    {
      'sender': 'David Kim',
      'content': 'Great! Looking forward to reviewing the metrics.',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 2)),
      'isHost': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAnimations();
    _initializeCamera();
    _startControlsHideTimer();
    _simulateNetworkChanges();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _controlsAnimationController.dispose();
    _handRaiseAnimationController.dispose();
    _controlsHideTimer?.cancel();
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

  void _showErrorToast(String message) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.error,
      textColor: AppTheme.lightTheme.colorScheme.onError,
    );
  }

  void _initializeAnimations() {
    _controlsAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _handRaiseAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
  }

  void _startControlsHideTimer() {
    _controlsHideTimer?.cancel();
    _controlsHideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _isControlsVisible && !_isFullScreen) {
        setState(() {
          _isControlsVisible = false;
        });
      }
    });
  }

  void _simulateNetworkChanges() {
    // Simulate network quality changes
    Timer.periodic(const Duration(seconds: 15), (timer) {
      if (mounted) {
        final qualities = ['excellent', 'good', 'fair', 'poor'];
        final randomQuality =
            qualities[DateTime.now().millisecond % qualities.length];

        setState(() {
          _connectionQuality = randomQuality;
        });

        // Simulate network interruption occasionally
        if (randomQuality == 'poor' && DateTime.now().second % 30 == 0) {
          _showNetworkIssue();
        }
      }
    });
  }

  void _showNetworkIssue() {
    setState(() {
      _isNetworkIssueVisible = true;
    });

    // Auto-hide after 5 seconds
    Timer(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() {
          _isNetworkIssueVisible = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: _handleScreenTap,
        onDoubleTap: _toggleFullScreen,
        onHorizontalDragEnd: _handleHorizontalSwipe,
        child: Stack(
          children: [
            // Main video feed with real camera
            _buildMainVideoFeed(),

            // Participant thumbnails (only visible when not in full screen)
            if (!_isFullScreen)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: ParticipantThumbnailsWidget(
                  participants: _participants,
                  activeSpeakerId: _activeSpeakerId,
                  onParticipantTap: _handleParticipantTap,
                ),
              ),

            // Video overlay controls
            VideoOverlayControlsWidget(
              broadcastTitle: _broadcastTitle,
              participantCount: _participantCount,
              connectionQuality: _connectionQuality,
              isMuted: _isMuted,
              isCameraOn: _isCameraOn,
              isHandRaised: _isHandRaised,
              handRaisePosition: _handRaisePosition,
              onMuteToggle: _toggleMute,
              onCameraToggle: _toggleCamera,
              onHandRaiseToggle: _toggleHandRaise,
              onLeaveBroadcast: _leaveBroadcast,
              isVisible: _isControlsVisible,
            ),

            // Network status overlay
            NetworkStatusOverlayWidget(
              isVisible: _isNetworkIssueVisible,
              status: 'poor_connection',
              message:
                  'Your connection is unstable. Video quality may be reduced.',
              isReconnecting: false,
              onRetry: _retryConnection,
            ),

            // Side panel
            SidePanelWidget(
              isVisible: _isSidePanelVisible,
              participants: _participants,
              chatMessages: _chatMessages,
              onSendMessage: _sendChatMessage,
              onClose: _closeSidePanel,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainVideoFeed() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: [
          // Real camera feed
          if (_isCameraInitialized && _cameraController != null && _isCameraOn)
            Positioned.fill(
              child: CameraPreview(_cameraController!),
            ),

          // Camera off state
          if (!_isCameraOn || !_isCameraInitialized)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'videocam_off',
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 80,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      _isCameraOn ? 'Initializing camera...' : 'Camera is off',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Loading indicator for camera initialization
          if (!_isCameraInitialized && _hasPermission && _isCameraOn)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),

          // Permission denied state
          if (!_hasPermission)
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'camera_alt',
                      color: Colors.white.withValues(alpha: 0.5),
                      size: 80,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Camera permission required',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: _initializeCamera,
                      child: Text('Grant Permission'),
                    ),
                  ],
                ),
              ),
            ),

          // Video quality overlay for poor connection
          if (_connectionQuality == 'poor' || _connectionQuality == 'bad')
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomIconWidget(
                      iconName: 'signal_wifi_1_bar',
                      color: Colors.white.withValues(alpha: 0.7),
                      size: 48,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Adjusting video quality...',
                      style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleScreenTap() {
    setState(() {
      _isControlsVisible = !_isControlsVisible;
    });

    if (_isControlsVisible) {
      _startControlsHideTimer();
    }
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      _isControlsVisible = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      _startControlsHideTimer();
    }
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity != null && details.primaryVelocity! < -500) {
      // Swipe left to open side panel
      setState(() {
        _isSidePanelVisible = true;
      });
    }
  }

  void _handleParticipantTap(String participantId) {
    setState(() {
      _activeSpeakerId = participantId;
    });

    // Show toast
    Fluttertoast.showToast(
      msg:
          'Switched to ${_participants.firstWhere((p) => p['id'] == participantId)['name']}',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _toggleMute() {
    setState(() {
      _isMuted = !_isMuted;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Show toast
    Fluttertoast.showToast(
      msg: _isMuted ? 'Microphone muted' : 'Microphone unmuted',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor:
          _isMuted ? AppTheme.errorLight : AppTheme.connectionGoodLight,
      textColor: Colors.white,
    );
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });

    // Haptic feedback
    HapticFeedback.lightImpact();

    // Show toast
    Fluttertoast.showToast(
      msg: _isCameraOn ? 'Camera turned on' : 'Camera turned off',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor:
          _isCameraOn ? AppTheme.connectionGoodLight : AppTheme.errorLight,
      textColor: Colors.white,
    );
  }

  void _toggleHandRaise() {
    setState(() {
      _isHandRaised = !_isHandRaised;
      _handRaisePosition = _isHandRaised ? 3 : null;
    });

    if (_isHandRaised) {
      _handRaiseAnimationController.repeat();
    } else {
      _handRaiseAnimationController.stop();
    }

    // Haptic feedback
    HapticFeedback.mediumImpact();

    // Show toast
    Fluttertoast.showToast(
      msg:
          _isHandRaised ? 'Hand raised - Position #3 in queue' : 'Hand lowered',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: _isHandRaised
          ? AppTheme.accentLight
          : AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _leaveBroadcast() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Leave Broadcast',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to leave this broadcast?',
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
              Navigator.pushReplacementNamed(context, '/broadcast-dashboard');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorLight,
            ),
            child: Text(
              'Leave',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _retryConnection() {
    setState(() {
      _isNetworkIssueVisible = false;
      _connectionQuality = 'good';
    });

    Fluttertoast.showToast(
      msg: 'Reconnecting...',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      textColor: Colors.white,
    );
  }

  void _sendChatMessage(String message) {
    setState(() {
      _chatMessages.add({
        'sender': 'You',
        'content': message,
        'timestamp': DateTime.now(),
        'isHost': false,
      });
    });
  }

  void _closeSidePanel() {
    setState(() {
      _isSidePanelVisible = false;
    });
  }
}
