import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class ConnectionHistoryWidget extends StatelessWidget {
  final List<Map<String, dynamic>> historyEvents;

  const ConnectionHistoryWidget({
    Key? key,
    required this.historyEvents,
  }) : super(key: key);

  Color _getEventColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'connected':
      case 'reconnected':
        return AppTheme.connectionGoodLight;
      case 'disconnected':
      case 'connection_lost':
        return AppTheme.connectionBadLight;
      case 'quality_changed':
        return AppTheme.connectionPoorLight;
      default:
        return AppTheme.lightTheme.colorScheme.onSurfaceVariant;
    }
  }

  IconData _getEventIcon(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'connected':
      case 'reconnected':
        return Icons.check_circle;
      case 'disconnected':
      case 'connection_lost':
        return Icons.error;
      case 'quality_changed':
        return Icons.warning;
      default:
        return Icons.info;
    }
  }

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
              'Connection History',
              style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 2.h),
            historyEvents.isEmpty
                ? Container(
                    padding: EdgeInsets.all(4.w),
                    child: Center(
                      child: Text(
                        'No connection events recorded',
                        style:
                            AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                          color:
                              AppTheme.lightTheme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount:
                        historyEvents.length > 5 ? 5 : historyEvents.length,
                    separatorBuilder: (context, index) => SizedBox(height: 1.h),
                    itemBuilder: (context, index) {
                      final event = historyEvents[index];
                      final eventType = event['type'] as String;
                      final timestamp = event['timestamp'] as DateTime;
                      final description = event['description'] as String;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: EdgeInsets.all(1.w),
                            decoration: BoxDecoration(
                              color: _getEventColor(eventType)
                                  .withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: CustomIconWidget(
                              iconName:
                                  _getEventIcon(eventType).codePoint.toString(),
                              color: _getEventColor(eventType),
                              size: 16,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  description,
                                  style: AppTheme
                                      .lightTheme.textTheme.bodyMedium
                                      ?.copyWith(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text(
                                  '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}',
                                  style: AppTheme.lightTheme.textTheme.bodySmall
                                      ?.copyWith(
                                    color: AppTheme.lightTheme.colorScheme
                                        .onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
