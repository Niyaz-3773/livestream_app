import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/accessibility_settings_widget.dart';
import './widgets/account_section_widget.dart';
import './widgets/advanced_settings_widget.dart';
import './widgets/broadcast_preferences_widget.dart';
import './widgets/data_usage_widget.dart';
import './widgets/footer_section_widget.dart';
import './widgets/network_settings_widget.dart';
import './widgets/notification_settings_widget.dart';
import './widgets/privacy_settings_widget.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  // Mock user profile data
  final Map<String, dynamic> _userProfile = {
    "name": "Sarah Johnson",
    "email": "sarah.johnson@livestream.com",
    "avatar":
        "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
  };

  // Mock broadcast preferences
  Map<String, dynamic> _broadcastPreferences = {
    "videoQuality": "HD",
    "autoJoinAudio": true,
    "cameraSelection": "Front",
    "microphoneSensitivity": 0.7,
  };

  // Mock network settings
  Map<String, dynamic> _networkSettings = {
    "bandwidthLimit": 5.0,
    "useCellularData": true,
    "autoQualityAdjustment": true,
  };

  // Mock notification settings
  Map<String, dynamic> _notificationSettings = {
    "broadcastInvitations": true,
    "sessionAlerts": true,
    "networkWarnings": true,
  };

  // Mock privacy settings
  final Map<String, dynamic> _privacySettings = {
    "cameraPermission": "Granted",
    "microphonePermission": "Granted",
  };

  // Mock data usage
  final Map<String, dynamic> _dataUsage = {
    "currentSession": "45.2 MB",
    "today": "128.7 MB",
    "thisMonth": "2.3 GB",
    "total": "15.8 GB",
  };

  // Mock advanced settings
  Map<String, dynamic> _advancedSettings = {
    "betaFeatures": false,
  };

  // Mock accessibility settings
  Map<String, dynamic> _accessibilitySettings = {
    "reducedMotion": false,
    "highContrast": false,
  };

  final String _appVersion = "2.1.4";

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.lightTheme.colorScheme.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: CustomIconWidget(
            iconName: 'arrow_back',
            color: Colors.white,
            size: 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Settings'),
          ],
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withValues(alpha: 0.7),
          indicatorColor: Colors.white,
          indicatorWeight: 3,
        ),
      ),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [
            _buildSettingsTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          SizedBox(height: 2.h),
          AccountSectionWidget(
            userProfile: _userProfile,
            onEditProfile: _handleEditProfile,
          ),
          BroadcastPreferencesWidget(
            preferences: _broadcastPreferences,
            onPreferenceChanged: _handleBroadcastPreferenceChanged,
          ),
          NetworkSettingsWidget(
            networkSettings: _networkSettings,
            onSettingChanged: _handleNetworkSettingChanged,
          ),
          NotificationSettingsWidget(
            notificationSettings: _notificationSettings,
            onNotificationChanged: _handleNotificationChanged,
          ),
          PrivacySettingsWidget(
            privacySettings: _privacySettings,
            onOpenCameraSettings: _handleOpenCameraSettings,
            onOpenMicrophoneSettings: _handleOpenMicrophoneSettings,
          ),
          DataUsageWidget(
            dataUsage: _dataUsage,
            onResetUsage: _handleResetDataUsage,
          ),
          AdvancedSettingsWidget(
            advancedSettings: _advancedSettings,
            onAdvancedSettingChanged: _handleAdvancedSettingChanged,
            onExportLogs: _handleExportLogs,
            onRunDiagnostics: _handleRunDiagnostics,
          ),
          AccessibilitySettingsWidget(
            accessibilitySettings: _accessibilitySettings,
            onAccessibilityChanged: _handleAccessibilityChanged,
          ),
          FooterSectionWidget(
            appVersion: _appVersion,
            onTermsOfService: _handleTermsOfService,
            onPrivacyPolicy: _handlePrivacyPolicy,
            onLogout: _handleLogout,
          ),
        ],
      ),
    );
  }

  void _handleEditProfile() {
    Fluttertoast.showToast(
      msg: "Edit Profile feature coming soon",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleBroadcastPreferenceChanged(String key, dynamic value) {
    setState(() {
      _broadcastPreferences[key] = value;
    });

    Fluttertoast.showToast(
      msg: "Broadcast preference updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleNetworkSettingChanged(String key, dynamic value) {
    setState(() {
      _networkSettings[key] = value;
    });

    Fluttertoast.showToast(
      msg: "Network setting updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleNotificationChanged(String key, bool value) {
    setState(() {
      _notificationSettings[key] = value;
    });

    Fluttertoast.showToast(
      msg: value ? "Notifications enabled" : "Notifications disabled",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleOpenCameraSettings() {
    Fluttertoast.showToast(
      msg: "Opening camera settings...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleOpenMicrophoneSettings() {
    Fluttertoast.showToast(
      msg: "Opening microphone settings...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleResetDataUsage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Reset Data Usage',
            style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to reset all data usage statistics? This action cannot be undone.',
            style: AppTheme.lightTheme.textTheme.bodyMedium,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                Fluttertoast.showToast(
                  msg: "Data usage statistics reset",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightTheme.colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              child: Text(
                'Reset',
                style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _handleAdvancedSettingChanged(String key, dynamic value) {
    setState(() {
      _advancedSettings[key] = value;
    });

    Fluttertoast.showToast(
      msg: "Advanced setting updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleExportLogs() {
    Fluttertoast.showToast(
      msg: "Exporting diagnostic logs...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleRunDiagnostics() {
    Fluttertoast.showToast(
      msg: "Running connection diagnostics...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleAccessibilityChanged(String key, bool value) {
    setState(() {
      _accessibilitySettings[key] = value;
    });

    Fluttertoast.showToast(
      msg: "Accessibility setting updated",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleTermsOfService() {
    Fluttertoast.showToast(
      msg: "Opening Terms of Service...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handlePrivacyPolicy() {
    Fluttertoast.showToast(
      msg: "Opening Privacy Policy...",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }

  void _handleLogout() {
    // Navigate to permission request screen (login flow)
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/permission-request-screen',
      (route) => false,
    );

    Fluttertoast.showToast(
      msg: "Logged out successfully",
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
    );
  }
}
