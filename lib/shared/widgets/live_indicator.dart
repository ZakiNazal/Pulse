import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// A pulsing live indicator widget with animated red dot and "LIVE" label.
///
/// Features:
/// - Red dot that scales up/down with a smooth pulse animation
/// - Blinking glow effect behind the dot
/// - "LIVE" text rendered in the project's [AppTextStyles.liveBadge] style
/// - Configurable [dotSize], [showGlow], and [showText]
///
/// Usage:
/// ```dart
/// LiveIndicator()                          // default: dot + text + glow
/// LiveIndicator(showGlow: false)           // dot + text, no glow
/// LiveIndicator(dotSize: 10, showText: false) // custom dot only
/// ```
class LiveIndicator extends StatefulWidget {
  const LiveIndicator({
    super.key,
    this.dotSize = 8.0,
    this.showGlow = true,
    this.showText = true,
    this.animate = true,
  });

  /// Diameter of the pulsing red dot in logical pixels.
  final double dotSize;

  /// Whether to render the soft red glow behind the dot.
  final bool showGlow;

  /// Whether to render the "LIVE" text label.
  final bool showText;

  /// Whether the pulse animation should run. Set to `false` for static display.
  final bool animate;

  @override
  State<LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<LiveIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _glowController;

  late final Animation<double> _pulseAnimation;
  late final Animation<double> _glowOpacityAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse: scale from 0.8 -> 1.2 with easing
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Glow: opacity from 0.2 -> 0.7 -> 0.2 (blink)
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _glowOpacityAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.2, end: 0.7), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 0.7, end: 0.2), weight: 50),
    ]).animate(_glowController);

    if (widget.animate) {
      _pulseController.repeat(reverse: true);
      _glowController.repeat();
    }
  }

  @override
  void didUpdateWidget(LiveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animate != widget.animate) {
      if (widget.animate) {
        _pulseController.repeat(reverse: true);
        _glowController.repeat();
      } else {
        _pulseController.stop();
        _glowController.stop();
      }
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([
            _pulseController,
            _glowController,
          ]),
          builder: (context, child) {
            final scale = widget.animate
                ? _pulseAnimation.value
                : 1.0;
            final glowOpacity = widget.animate
                ? _glowOpacityAnimation.value
                : 0.5;

            return Container(
              width: widget.dotSize * 2.5,
              height: widget.dotSize * 2.5,
              alignment: Alignment.center,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Glow layer
                  if (widget.showGlow)
                    Container(
                      width: widget.dotSize * 2.4,
                      height: widget.dotSize * 2.4,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.liveRed.withValues(alpha: glowOpacity),
                      ),
                    ),
                  // Dot layer
                  Transform.scale(
                    scale: scale,
                    child: Container(
                      width: widget.dotSize,
                      height: widget.dotSize,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.liveRed,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.liveRed.withValues(alpha: 0.6),
                            blurRadius: widget.dotSize * 0.8,
                            spreadRadius: widget.dotSize * 0.3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
        if (widget.showText) ...[
          const SizedBox(width: 4),
          Text(
            'LIVE',
            style: AppTextStyles.liveBadge,
          ),
        ],
      ],
    );
  }
}
