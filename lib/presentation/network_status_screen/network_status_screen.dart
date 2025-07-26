import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/bandwidth_meter_widget.dart';
import './widgets/connection_history_widget.dart';
import './widgets/connection_status_card.dart';
import './widgets/data_usage_widget.dart';
import './widgets/emergency_fallback_widget.dart';
import './widgets/network_diagnostics_widget.dart';
import './widgets/troubleshooting_section_widget.dart';

class NetworkStatusScreen extends StatefulWidget {
  const NetworkStatusScreen({Key? key}) : super(key: key);

  @override
  State<NetworkStatusScreen> createState() => _NetworkStatusScreenState();
}

class _NetworkStatusScreenState extends State<NetworkStatusScreen> {
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  Timer? _updateTimer;

  // Connection status
  String _connectionType = 'WiFi';
  String _signalStrength = 'Strong';
  String _connectionStatus = 'Connected';
  Color _statusColor = AppTheme.connectionGoodLight;

  // Bandwidth data
  double _uploadSpeed = 0.0;
  double _downloadSpeed = 0.0;
  String _quality = 'Good';

  // Network diagnostics
  bool _isTestingConnection = false;
  Map<String, dynamic>? _testResults;

  // Data usage
  double _currentSessionUsage = 0.0;
  double _totalUsage = 0.0;

  // Emergency options
  bool _showEmergencyOptions = false;

  // Auto quality adjustment
  bool _autoQualityAdjustment = true;

  // Connection history
  final List<Map<String, dynamic>> _connectionHistory = [
    {
      'type': 'connected',
      'description': 'Connected to WiFi network',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 5)),
    },
    {
      'type': 'quality_changed',
      'description': 'Connection quality improved to Good',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 12)),
    },
    {
      'type': 'reconnected',
      'description': 'Reconnected after brief disconnection',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 18)),
    },
    {
      'type': 'disconnected',
      'description': 'Connection lost - switching to cellular',
      'timestamp': DateTime.now().subtract(const Duration(minutes: 25)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _initializeNetworkMonitoring();
    _startPeriodicUpdates();
    _simulateDataUsage();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _updateTimer?.cancel();
    super.dispose();
  }

  void _initializeNetworkMonitoring() {
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _updateConnectionStatus([result]);
      },
    );

    // Initial connectivity check
    Connectivity().checkConnectivity().then((result) {
      _updateConnectionStatus([result]);
    });
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    if (results.isEmpty || results.contains(ConnectivityResult.none)) {
      setState(() {
        _connectionType = 'Disconnected';
        _signalStrength = 'None';
        _connectionStatus = 'Disconnected';
        _statusColor = AppTheme.connectionBadLight;
        _showEmergencyOptions = true;
      });
      _addConnectionEvent('disconnected', 'Connection lost');
    } else if (results.contains(ConnectivityResult.wifi)) {
      setState(() {
        _connectionType = 'WiFi';
        _signalStrength = 'Strong';
        _connectionStatus = 'Connected';
        _statusColor = AppTheme.connectionGoodLight;
        _showEmergencyOptions = false;
      });
      _addConnectionEvent('connected', 'Connected to WiFi network');
    } else if (results.contains(ConnectivityResult.mobile)) {
      setState(() {
        _connectionType = 'Cellular';
        _signalStrength = 'Good';
        _connectionStatus = 'Connected';
        _statusColor = AppTheme.connectionGoodLight;
        _showEmergencyOptions = false;
      });
      _addConnectionEvent('connected', 'Connected to cellular network');
    }
  }

  void _addConnectionEvent(String type, String description) {
    setState(() {
      _connectionHistory.insert(0, {
        'type': type,
        'description': description,
        'timestamp': DateTime.now(),
      });

      // Keep only last 10 events
      if (_connectionHistory.length > 10) {
        _connectionHistory.removeLast();
      }
    });
  }

  void _startPeriodicUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      _simulateBandwidthUpdate();
    });
  }

  void _simulateBandwidthUpdate() {
    final random = Random();
    setState(() {
      // Simulate realistic bandwidth values
      _uploadSpeed = 2.5 + random.nextDouble() * 7.5; // 2.5-10 Mbps
      _downloadSpeed = 15.0 + random.nextDouble() * 35.0; // 15-50 Mbps

      // Determine quality based on upload speed (critical for streaming)
      if (_uploadSpeed >= 8.0) {
        _quality = 'Excellent';
      } else if (_uploadSpeed >= 5.0) {
        _quality = 'Good';
      } else if (_uploadSpeed >= 2.0) {
        _quality = 'Fair';
      } else {
        _quality = 'Poor';
        _showEmergencyOptions = true;
      }
    });
  }

  void _simulateDataUsage() {
    setState(() {
      _currentSessionUsage = 45.6; // MB
      _totalUsage = 1250.8; // MB for this month
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isTestingConnection = true;
    });

    // Simulate connection test
    await Future.delayed(const Duration(seconds: 3));

    final random = Random();
    final latency = 20 + random.nextInt(80); // 20-100ms
    final packetLoss = random.nextDouble() * 2; // 0-2%

    String quality;
    String recommendation;

    if (latency < 50 && packetLoss < 0.5) {
      quality = 'Excellent';
      recommendation = 'Your connection is optimal for high-quality streaming.';
    } else if (latency < 80 && packetLoss < 1.0) {
      quality = 'Good';
      recommendation = 'Connection is suitable for standard quality streaming.';
    } else if (latency < 120 && packetLoss < 1.5) {
      quality = 'Fair';
      recommendation =
          'Consider reducing video quality for better performance.';
    } else {
      quality = 'Poor';
      recommendation = 'Switch to audio-only mode or find a better connection.';
    }

    setState(() {
      _isTestingConnection = false;
      _testResults = {
        'quality': quality,
        'latency': latency,
        'packetLoss': packetLoss.toStringAsFixed(1),
        'recommendation': recommendation,
      };
    });
  }

  void _refreshNetworkStatus() {
    Connectivity().checkConnectivity().then((result) {
      _updateConnectionStatus([result]);
    });
    _simulateBandwidthUpdate();
    _addConnectionEvent('quality_changed', 'Network status refreshed');
  }

  void _onAudioOnlyMode() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Switching to audio-only mode...'),
        backgroundColor: AppTheme.connectionPoorLight,
      ),
    );
  }

  void _onOfflineRecording() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Starting offline recording...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
      ),
    );
  }

  void _onContactSupport() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Opening support contact...'),
        backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Network Status'),
        backgroundColor: AppTheme.lightTheme.appBarTheme.backgroundColor,
        foregroundColor: AppTheme.lightTheme.appBarTheme.foregroundColor,
        elevation: AppTheme.lightTheme.appBarTheme.elevation,
        actions: [
          IconButton(
            onPressed: _refreshNetworkStatus,
            icon: CustomIconWidget(
              iconName: 'refresh',
              color: AppTheme.lightTheme.appBarTheme.foregroundColor!,
              size: 24,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(4.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Connection Status Card
              ConnectionStatusCard(
                connectionType: _connectionType,
                signalStrength: _signalStrength,
                status: _connectionStatus,
                statusColor: _statusColor,
              ),
              SizedBox(height: 2.h),

              // Bandwidth Meter
              BandwidthMeterWidget(
                uploadSpeed: _uploadSpeed,
                downloadSpeed: _downloadSpeed,
                quality: _quality,
              ),
              SizedBox(height: 2.h),

              // Auto Quality Adjustment Toggle
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(4.w),
                  child: Row(
                    children: [
                      CustomIconWidget(
                        iconName: 'auto_fix_high',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 24,
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Auto Quality Adjustment',
                              style: AppTheme.lightTheme.textTheme.bodyLarge
                                  ?.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              'Automatically adjust streaming quality based on connection',
                              style: AppTheme.lightTheme.textTheme.bodySmall
                                  ?.copyWith(
                                color: AppTheme
                                    .lightTheme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: _autoQualityAdjustment,
                        onChanged: (value) {
                          setState(() {
                            _autoQualityAdjustment = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 2.h),

              // Network Diagnostics
              NetworkDiagnosticsWidget(
                onTestConnection: _testConnection,
                isTestingConnection: _isTestingConnection,
                testResults: _testResults,
              ),
              SizedBox(height: 2.h),

              // Data Usage
              DataUsageWidget(
                currentSessionUsage: _currentSessionUsage,
                totalUsage: _totalUsage,
                period: 'This Month',
              ),
              SizedBox(height: 2.h),

              // Connection History
              ConnectionHistoryWidget(
                historyEvents: _connectionHistory,
              ),
              SizedBox(height: 2.h),

              // Troubleshooting Section
              const TroubleshootingSectionWidget(),
              SizedBox(height: 2.h),

              // Emergency Fallback Options
              EmergencyFallbackWidget(
                showEmergencyOptions: _showEmergencyOptions,
                onAudioOnlyMode: _onAudioOnlyMode,
                onOfflineRecording: _onOfflineRecording,
                onContactSupport: _onContactSupport,
              ),
              SizedBox(height: 4.h),
            ],
          ),
        ),
      ),
    );
  }
}
