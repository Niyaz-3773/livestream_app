import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../../core/app_export.dart';

class CameraFlipButton extends StatelessWidget {
  final VoidCallback onFlip;
  final bool isFlipping;

  const CameraFlipButton({
    super.key,
    required this.onFlip,
    this.isFlipping = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 12.w,
      height: 12.w,
      decoration: BoxDecoration(
        color: AppTheme.lightTheme.colorScheme.surface.withValues(alpha: 0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isFlipping ? null : onFlip,
          borderRadius: BorderRadius.circular(6.w),
          child: AnimatedRotation(
            turns: isFlipping ? 0.5 : 0,
            duration: const Duration(milliseconds: 300),
            child: Center(
              child: CustomIconWidget(
                iconName: 'flip_camera_ios',
                size: 6.w,
                color: isFlipping
                    ? AppTheme.lightTheme.colorScheme.onSurface
                        .withValues(alpha: 0.5)
                    : AppTheme.lightTheme.colorScheme.onSurface,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
