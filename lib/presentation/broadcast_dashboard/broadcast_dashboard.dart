import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import './widgets/broadcast_card_widget.dart';
import './widgets/connection_status_banner_widget.dart';
import './widgets/empty_state_widget.dart';
import './widgets/network_status_header_widget.dart';
import './widgets/quick_actions_widget.dart';

class BroadcastDashboard extends StatefulWidget {
  const BroadcastDashboard({Key? key}) : super(key: key);

  @override
  State<BroadcastDashboard> createState() => _BroadcastDashboardState();
}

class _BroadcastDashboardState extends State<BroadcastDashboard>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isRefreshing = false;
  bool _isConnectionBannerExpanded = false;
  int _selectedBroadcastIndex = -1;
  OverlayEntry? _quickActionsOverlay;

  // Mock user data
  final Map<String, dynamic> _currentUser = {
    "id": 1,
    "name": "Sarah Johnson",
    "avatar":
        "https://images.pexels.com/photos/774909/pexels-photo-774909.jpeg?auto=compress&cs=tinysrgb&w=400",
    "networkType": "WiFi",
    "connectionStatus": "Good",
    "bandwidth": 45.2,
    "notificationCount": 3,
  };

  // Mock broadcast data
  final List<Map<String, dynamic>> _broadcasts = [
    {
      "id": 1,
      "title": "Tech Conference 2025 - AI & Machine Learning",
      "description":
          "Join industry experts discussing the latest trends in artificial intelligence and machine learning technologies.",
      "hostName": "Dr. Michael Chen",
      "hostAvatar":
          "https://images.pexels.com/photos/2182970/pexels-photo-2182970.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Live",
      "participantCount": 1247,
      "requiresAccess": false,
      "isFavorite": true,
      "startTime": DateTime.now().subtract(const Duration(hours: 1)),
    },
    {
      "id": 2,
      "title": "Product Launch Event - Revolutionary Streaming Platform",
      "description":
          "Witness the unveiling of our next-generation streaming technology that will change how we connect.",
      "hostName": "Emma Rodriguez",
      "hostAvatar":
          "https://images.pexels.com/photos/1239291/pexels-photo-1239291.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Starting Soon",
      "participantCount": 892,
      "requiresAccess": true,
      "isFavorite": false,
      "startTime": DateTime.now().add(const Duration(minutes: 15)),
    },
    {
      "id": 3,
      "title": "Weekly Team Standup - Engineering Division",
      "description":
          "Internal team meeting for project updates and sprint planning discussions.",
      "hostName": "James Wilson",
      "hostAvatar":
          "https://images.pexels.com/photos/1222271/pexels-photo-1222271.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Live",
      "participantCount": 23,
      "requiresAccess": false,
      "isFavorite": false,
      "startTime": DateTime.now().subtract(const Duration(minutes: 30)),
    },
    {
      "id": 4,
      "title": "Customer Success Webinar - Best Practices",
      "description":
          "Learn proven strategies for improving customer satisfaction and retention rates.",
      "hostName": "Lisa Thompson",
      "hostAvatar":
          "https://images.pexels.com/photos/1181686/pexels-photo-1181686.jpeg?auto=compress&cs=tinysrgb&w=400",
      "status": "Ended",
      "participantCount": 456,
      "requiresAccess": false,
      "isFavorite": true,
      "startTime": DateTime.now().subtract(const Duration(hours: 3)),
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _quickActionsOverlay?.remove();
    super.dispose();
  }

  void _startAutoRefresh() {
    Future.delayed(const Duration(seconds: 30), () {
      if (mounted) {
        _refreshBroadcasts();
        _startAutoRefresh();
      }
    });
  }

  Future<void> _refreshBroadcasts() async {
    if (_isRefreshing) return;

    setState(() {
      _isRefreshing = true;
    });

    // Simulate network delay
    await Future.delayed(const Duration(seconds: 2));

    if (mounted) {
      setState(() {
        _isRefreshing = false;
        // Update connection status randomly for demo
        final statuses = ['Good', 'Fair', 'Poor'];
        _currentUser['connectionStatus'] =
            statuses[DateTime.now().millisecond % 3];
        _currentUser['bandwidth'] = 20.0 + (DateTime.now().millisecond % 50);
      });
    }
  }

  void _toggleConnectionBanner() {
    setState(() {
      _isConnectionBannerExpanded = !_isConnectionBannerExpanded;
    });
  }

  void _showQuickActions(int index, Offset position) {
    _hideQuickActions();

    _quickActionsOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx - 30.w,
        top: position.dy,
        child: Material(
          color: Colors.transparent,
          child: QuickActionsWidget(
            onFavoritePressed: () => _toggleFavorite(index),
            onSharePressed: () => _shareBroadcast(index),
            onReminderPressed: () => _setReminder(index),
            onDismiss: _hideQuickActions,
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_quickActionsOverlay!);
  }

  void _hideQuickActions() {
    _quickActionsOverlay?.remove();
    _quickActionsOverlay = null;
  }

  void _toggleFavorite(int index) {
    setState(() {
      _broadcasts[index]['isFavorite'] =
          !(_broadcasts[index]['isFavorite'] ?? false);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _broadcasts[index]['isFavorite']
              ? 'Added to favorites'
              : 'Removed from favorites',
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _shareBroadcast(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing "${_broadcasts[index]['title']}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _setReminder(int index) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Reminder set for "${_broadcasts[index]['title']}"'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _joinBroadcast(int index) {
    final broadcast = _broadcasts[index];
    if (broadcast['requiresAccess'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Access requested for "${broadcast['title']}"'),
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      Navigator.pushNamed(context, '/broadcast-viewer-screen');
    }
  }

  void _startNewBroadcast() {
    Navigator.pushNamed(context, '/camera-preview-screen');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.lightTheme.scaffoldBackgroundColor,
      body: Column(
        children: [
          NetworkStatusHeaderWidget(
            userAvatar: _currentUser['avatar'],
            userName: _currentUser['name'],
            networkType: _currentUser['networkType'],
            connectionStatus: _currentUser['connectionStatus'],
            bandwidth: _currentUser['bandwidth'],
            notificationCount: _currentUser['notificationCount'],
            onProfileTap: () =>
                Navigator.pushNamed(context, '/settings-screen'),
            onNotificationTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notifications opened'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          ConnectionStatusBannerWidget(
            connectionStatus: _currentUser['connectionStatus'],
            networkType: _currentUser['networkType'],
            bandwidth: _currentUser['bandwidth'],
            isExpanded: _isConnectionBannerExpanded,
            onTap: _toggleConnectionBanner,
          ),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildDashboardTab(),
                _buildMyBroadcastsTab(),
                _buildSettingsTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton:
          _tabController.index == 0 ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.lightTheme.colorScheme.surface,
      child: TabBar(
        controller: _tabController,
        tabs: const [
          Tab(text: 'Dashboard'),
          Tab(text: 'My Broadcasts'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  Widget _buildDashboardTab() {
    final activeBroadcasts = _broadcasts
        .where((b) =>
            b['status'].toLowerCase() == 'live' ||
            b['status'].toLowerCase() == 'starting soon')
        .toList();

    return RefreshIndicator(
      onRefresh: _refreshBroadcasts,
      child: activeBroadcasts.isEmpty
          ? SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: 60.h,
                child: EmptyStateWidget(onRefresh: _refreshBroadcasts),
              ),
            )
          : ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: activeBroadcasts.length,
              itemBuilder: (context, index) {
                final broadcast = activeBroadcasts[index];
                return GestureDetector(
                  onLongPressStart: (details) {
                    _showQuickActions(index, details.globalPosition);
                  },
                  child: Dismissible(
                    key: Key('broadcast_${broadcast['id']}'),
                    direction: DismissDirection.startToEnd,
                    background: Container(
                      alignment: Alignment.centerLeft,
                      padding: EdgeInsets.only(left: 8.w),
                      color: AppTheme.lightTheme.colorScheme.primary
                          .withValues(alpha: 0.1),
                      child: CustomIconWidget(
                        iconName: 'star',
                        color: AppTheme.lightTheme.colorScheme.primary,
                        size: 8.w,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      _toggleFavorite(index);
                      return false;
                    },
                    child: BroadcastCardWidget(
                      broadcast: broadcast,
                      onJoinPressed: () => _joinBroadcast(index),
                      onFavoritePressed: () => _toggleFavorite(index),
                      onSharePressed: () => _shareBroadcast(index),
                      onReminderPressed: () => _setReminder(index),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Widget _buildMyBroadcastsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'videocam',
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.6),
              size: 20.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'My Broadcasts',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'View and manage your broadcast history',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomIconWidget(
              iconName: 'settings',
              color: AppTheme.lightTheme.colorScheme.primary
                  .withValues(alpha: 0.6),
              size: 20.w,
            ),
            SizedBox(height: 4.h),
            Text(
              'Settings',
              style: AppTheme.lightTheme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Configure your broadcast preferences',
              style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.7),
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 4.h),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/settings-screen'),
              child: const Text('Open Settings'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingActionButton() {
    return FloatingActionButton.extended(
      onPressed: _startNewBroadcast,
      icon: CustomIconWidget(
        iconName: 'videocam',
        color: Colors.white,
        size: 6.w,
      ),
      label: Text(
        'Start Broadcast',
        style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
    );
  }
}
