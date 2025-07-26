import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class CameraRotationControls extends StatefulWidget {
  final double currentRotation;
  final Function(double) onRotationChanged;
  final bool isVisible;

  const CameraRotationControls({
    Key? key,
    required this.currentRotation,
    required this.onRotationChanged,
    this.isVisible = true,
  }) : super(key: key);

  @override
  State<CameraRotationControls> createState() => _CameraRotationControlsState();
}

class _CameraRotationControlsState extends State<CameraRotationControls>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.isVisible) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(CameraRotationControls oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _resetRotation() {
    widget.onRotationChanged(0.0);
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 4.w),
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: Colors.black.withAlpha(179),
              borderRadius: BorderRadius.circular(2.w),
              border: Border.all(
                color: Colors.white.withAlpha(77),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Camera Tilt',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    GestureDetector(
                      onTap: _resetRotation,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 2.w,
                          vertical: 1.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(51),
                          borderRadius: BorderRadius.circular(1.w),
                        ),
                        child: Text(
                          'Reset',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.h),

                // Rotation slider
                Row(
                  children: [
                    Icon(
                      Icons.rotate_left,
                      color: Colors.white.withAlpha(179),
                      size: 5.w,
                    ),
                    SizedBox(width: 2.w),
                    Expanded(
                      child: SliderTheme(
                        data: SliderThemeData(
                          activeTrackColor: Colors.white,
                          inactiveTrackColor: Colors.white.withAlpha(77),
                          thumbColor: Colors.white,
                          overlayColor: Colors.white.withAlpha(51),
                          thumbShape: RoundSliderThumbShape(
                            enabledThumbRadius: 2.w,
                          ),
                          trackHeight: 0.5.h,
                        ),
                        child: Slider(
                          value: widget.currentRotation,
                          min: -45.0,
                          max: 45.0,
                          divisions: 18,
                          onChanged: (value) {
                            widget.onRotationChanged(value);
                            HapticFeedback.selectionClick();
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    Icon(
                      Icons.rotate_right,
                      color: Colors.white.withAlpha(179),
                      size: 5.w,
                    ),
                  ],
                ),

                // Rotation value display
                Text(
                  '${widget.currentRotation.toStringAsFixed(1)}°',
                  style: TextStyle(
                    color: Colors.white.withAlpha(204),
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
