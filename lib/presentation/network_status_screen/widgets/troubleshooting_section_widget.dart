import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class TroubleshootingSectionWidget extends StatefulWidget {
  const TroubleshootingSectionWidget({Key? key}) : super(key: key);

  @override
  State<TroubleshootingSectionWidget> createState() =>
      _TroubleshootingSectionWidgetState();
}

class _TroubleshootingSectionWidgetState
    extends State<TroubleshootingSectionWidget> {
  final List<Map<String, dynamic>> troubleshootingSteps = [
    {
      'title': 'Router Restart',
      'description': 'Restart your router to refresh the connection',
      'steps': [
        'Unplug your router for 30 seconds',
        'Plug it back in and wait 2-3 minutes',
        'Check if connection improves',
      ],
      'icon': 'router',
      'isExpanded': false,
    },
    {
      'title': 'Cellular Data Toggle',
      'description': 'Reset cellular connection',
      'steps': [
        'Go to Settings > Cellular/Mobile Data',
        'Turn off cellular data for 10 seconds',
        'Turn it back on and test connection',
      ],
      'icon': 'signal_cellular_4_bar',
      'isExpanded': false,
    },
    {
      'title': 'Airplane Mode Cycle',
      'description': 'Reset all network connections',
      'steps': [
        'Enable Airplane Mode for 30 seconds',
        'Disable Airplane Mode',
        'Wait for network to reconnect',
        'Test your connection',
      ],
      'icon': 'airplanemode_active',
      'isExpanded': false,
    },
    {
      'title': 'Network Settings Reset',
      'description': 'Reset network settings (advanced)',
      'steps': [
        'Go to Settings > General > Reset',
        'Select "Reset Network Settings"',
        'Enter your passcode if prompted',
        'Reconnect to your WiFi network',
      ],
      'icon': 'settings_backup_restore',
      'isExpanded': false,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(4.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Troubleshooting',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: troubleshootingSteps.length,
              separatorBuilder: (context, index) => SizedBox(height: 1.h),
              itemBuilder: (context, index) {
                final step = troubleshootingSteps[index];
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppTheme.lightTheme.dividerColor,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ExpansionTile(
                    leading: CustomIconWidget(
                      iconName: step['icon'] as String,
                      color: AppTheme.lightTheme.colorScheme.primary,
                      size: 24,
                    ),
                    title: Text(
                      step['title'] as String,
                      style: AppTheme.lightTheme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    subtitle: Text(
                      step['description'] as String,
                      style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
                        color: AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    children: [
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(4.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Steps:',
                              style: AppTheme.lightTheme.textTheme.labelMedium
                                  ?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(height: 1.h),
                            ...(step['steps'] as List<String>)
                                .asMap()
                                .entries
                                .map(
                                  (entry) => Padding(
                                    padding: EdgeInsets.only(bottom: 1.h),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 20,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            color: AppTheme
                                                .lightTheme.colorScheme.primary,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Center(
                                            child: Text(
                                              '${entry.key + 1}',
                                              style: AppTheme.lightTheme
                                                  .textTheme.labelSmall
                                                  ?.copyWith(
                                                color: AppTheme.lightTheme
                                                    .colorScheme.onPrimary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: Text(
                                            entry.value,
                                            style: AppTheme.lightTheme.textTheme
                                                .bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
