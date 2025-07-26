import 'package:flutter/material.dart';
import '../presentation/permission_request_screen/permission_request_screen.dart';
import '../presentation/broadcast_dashboard/broadcast_dashboard.dart';
import '../presentation/camera_preview_screen/camera_preview_screen.dart';
import '../presentation/network_status_screen/network_status_screen.dart';
import '../presentation/broadcast_viewer_screen/broadcast_viewer_screen.dart';
import '../presentation/settings_screen/settings_screen.dart';

class AppRoutes {
  // TODO: Add your routes here
  static const String initial = '/';
  static const String permissionRequestScreen = '/permission-request-screen';
  static const String broadcastDashboard = '/broadcast-dashboard';
  static const String cameraPreviewScreen = '/camera-preview-screen';
  static const String networkStatusScreen = '/network-status-screen';
  static const String broadcastViewerScreen = '/broadcast-viewer-screen';
  static const String settingsScreen = '/settings-screen';

  static Map<String, WidgetBuilder> routes = {
    initial: (context) => const PermissionRequestScreen(),
    permissionRequestScreen: (context) => const PermissionRequestScreen(),
    broadcastDashboard: (context) => const BroadcastDashboard(),
    cameraPreviewScreen: (context) => const CameraPreviewScreen(),
    networkStatusScreen: (context) => const NetworkStatusScreen(),
    broadcastViewerScreen: (context) => const BroadcastViewerScreen(),
    settingsScreen: (context) => const SettingsScreen(),
    // TODO: Add your other routes here
  };
}
