import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sizer/sizer.dart';

class EnhancedCameraFlipButton extends StatefulWidget {
  final VoidCallback onFlip;
  final bool isFlipping;
  final bool isFrontCamera;
  final int totalCameras;

  const EnhancedCameraFlipButton({
    Key? key,
    required this.onFlip,
    this.isFlipping = false,
    this.isFrontCamera = false,
    this.totalCameras = 2,
  }) : super(key: key);

  @override
  State<EnhancedCameraFlipButton> createState() =>
      _EnhancedCameraFlipButtonState();
}

class _EnhancedCameraFlipButtonState extends State<EnhancedCameraFlipButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
    ));
  }

  @override
  void didUpdateWidget(EnhancedCameraFlipButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isFlipping && !oldWidget.isFlipping) {
      _controller.forward().then((_) {
        if (mounted) {
          _controller.reset();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleFlip() {
    if (!widget.isFlipping) {
      HapticFeedback.mediumImpact();
      widget.onFlip();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value * 3.14159, // 180 degrees
            child: GestureDetector(
              onTap: _handleFlip,
              child: Container(
                width: 12.w,
                height: 12.w,
                decoration: BoxDecoration(
                  color: Colors.black.withAlpha(179),
                  borderRadius: BorderRadius.circular(6.w),
                  border: Border.all(
                    color: Colors.white.withAlpha(77),
                    width: 1,
                  ),
                ),
                child: Stack(
                  children: [
                    // Background icon
                    Center(
                      child: Icon(
                        widget.isFrontCamera
                            ? Icons.camera_front
                            : Icons.camera_rear,
                        color: Colors.white,
                        size: 6.w,
                      ),
                    ),

                    // Flip indicator
                    Positioned(
                      top: 1.w,
                      right: 1.w,
                      child: Container(
                        width: 3.w,
                        height: 3.w,
                        decoration: BoxDecoration(
                          color: widget.isFrontCamera
                              ? Colors.blue
                              : Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),

                    // Loading overlay
                    if (widget.isFlipping)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black.withAlpha(128),
                          borderRadius: BorderRadius.circular(6.w),
                        ),
                        child: Center(
                          child: SizedBox(
                            width: 4.w,
                            height: 4.w,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
