import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class BroadcastCardWidget extends StatelessWidget {
  final Map<String, dynamic> broadcast;
  final VoidCallback? onJoinPressed;
  final VoidCallback? onFavoritePressed;
  final VoidCallback? onSharePressed;
  final VoidCallback? onReminderPressed;

  const BroadcastCardWidget({
    Key? key,
    required this.broadcast,
    this.onJoinPressed,
    this.onFavoritePressed,
    this.onSharePressed,
    this.onReminderPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String status = broadcast['status'] ?? 'Ended';
    final bool isLive = status.toLowerCase() == 'live';
    final bool isStartingSoon = status.toLowerCase() == 'starting soon';
    final bool canJoin = isLive || isStartingSoon;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: canJoin ? onJoinPressed : null,
          child: Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                SizedBox(height: 2.h),
                _buildContent(),
                SizedBox(height: 2.h),
                _buildFooter(canJoin),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 12.w,
          height: 12.w,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.lightTheme.colorScheme.primary,
              width: 2,
            ),
          ),
          child: ClipOval(
            child: CustomImageWidget(
              imageUrl: broadcast['hostAvatar'] ?? '',
              width: 12.w,
              height: 12.w,
              fit: BoxFit.cover,
            ),
          ),
        ),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                broadcast['hostName'] ?? 'Unknown Host',
                style: AppTheme.lightTheme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 0.5.h),
              _buildStatusBadge(),
            ],
          ),
        ),
        IconButton(
          onPressed: onFavoritePressed,
          icon: CustomIconWidget(
            iconName: broadcast['isFavorite'] == true
                ? 'favorite'
                : 'favorite_border',
            color: broadcast['isFavorite'] == true
                ? AppTheme.lightTheme.colorScheme.error
                : AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.6),
            size: 6.w,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final String status = broadcast['status'] ?? 'Ended';
    Color statusColor;
    Color backgroundColor;

    switch (status.toLowerCase()) {
      case 'live':
        statusColor = Colors.white;
        backgroundColor = AppTheme.getLiveIndicatorColor();
        break;
      case 'starting soon':
        statusColor = Colors.white;
        backgroundColor = AppTheme.lightTheme.colorScheme.tertiary;
        break;
      default:
        statusColor =
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6);
        backgroundColor =
            AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.1);
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.h),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (status.toLowerCase() == 'live')
            Container(
              width: 2.w,
              height: 2.w,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
              ),
              margin: EdgeInsets.only(right: 1.w),
            ),
          Text(
            status.toUpperCase(),
            style: AppTheme.lightTheme.textTheme.labelSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.w600,
              fontSize: 10.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          broadcast['title'] ?? 'Untitled Broadcast',
          style: AppTheme.lightTheme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (broadcast['description'] != null) ...[
          SizedBox(height: 1.h),
          Text(
            broadcast['description'],
            style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
              color: AppTheme.lightTheme.colorScheme.onSurface
                  .withValues(alpha: 0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildFooter(bool canJoin) {
    return Row(
      children: [
        CustomIconWidget(
          iconName: 'people',
          color:
              AppTheme.lightTheme.colorScheme.onSurface.withValues(alpha: 0.6),
          size: 5.w,
        ),
        SizedBox(width: 1.w),
        Text(
          '${broadcast['participantCount'] ?? 0} participants',
          style: AppTheme.lightTheme.textTheme.bodySmall?.copyWith(
            color: AppTheme.lightTheme.colorScheme.onSurface
                .withValues(alpha: 0.6),
          ),
        ),
        const Spacer(),
        if (canJoin)
          ElevatedButton(
            onPressed: onJoinPressed,
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              broadcast['requiresAccess'] == true ? 'Request Access' : 'Join',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        else
          OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Ended',
              style: AppTheme.lightTheme.textTheme.labelLarge?.copyWith(
                color: AppTheme.lightTheme.colorScheme.onSurface
                    .withValues(alpha: 0.4),
              ),
            ),
          ),
      ],
    );
  }
}
