import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// A countdown timer widget that shows remaining time until a [targetTime].
///
/// Features:
/// - Displays remaining time as "HH:MM" (>60 min) or "MM:SS" (<60 min)
/// - Updates every second with a [Timer]
/// - Animated number transitions when digits change
/// - Optional label text (e.g. "Starts in")
/// - Automatically stops when countdown reaches zero
/// - Gracefully handles past target times
///
/// Usage:
/// ```dart
/// CountdownTimer(targetTime: match.startTime)
/// CountdownTimer(targetTime: match.startTime, label: 'Kick-off in')
/// ```
class CountdownTimer extends StatefulWidget {
  const CountdownTimer({
    super.key,
    required this.targetTime,
    this.label,
    this.style,
    this.onFinished,
  });

  /// The future [DateTime] to count down towards.
  final DateTime targetTime;

  /// Optional label displayed above the timer (e.g. "Starts in").
  final String? label;

  /// Optional text style override for the timer digits.
  final TextStyle? style;

  /// Callback invoked when the countdown reaches zero.
  final VoidCallback? onFinished;

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Timer _timer;
  bool _finished = false;

  String _displayHours = '00';
  String _displayMinutes = '00';
  String _displaySeconds = '00';
  bool _showHours = false;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) _updateRemaining();
    });
  }

  @override
  void didUpdateWidget(CountdownTimer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.targetTime != widget.targetTime) {
      _updateRemaining();
    }
  }

  void _updateRemaining() {
    final now = DateTime.now().toUtc();
    final targetUtc = widget.targetTime.toUtc();
    final diff = targetUtc.difference(now);

    if (diff.isNegative) {
      if (!_finished) {
        _finished = true;
        Duration.zero;
        _timer.cancel();
        widget.onFinished?.call();
      }
      return;
    }

    setState(() {
      final remaining = diff;
      _showHours = remaining.inHours > 0;

      if (_showHours) {
        _displayHours = (diff.inHours).toString().padLeft(2, '0');
        _displayMinutes = (diff.inMinutes % 60).toString().padLeft(2, '0');
      } else {
        _displayMinutes = (diff.inMinutes).toString().padLeft(2, '0');
        _displaySeconds = (diff.inSeconds % 60).toString().padLeft(2, '0');
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timerStyle = widget.style ??
        AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
          letterSpacing: 1.0,
        );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: AppTextStyles.labelSmall,
          ),
          const SizedBox(height: 4),
        ],
        if (_finished)
          Text(
            'NOW',
            style: timerStyle.copyWith(
              color: AppColors.liveRed,
              fontWeight: FontWeight.w800,
            ),
          ).animate(onPlay: (c) => c.repeat()).fade(
                duration: 600.ms,
                begin: 0.4,
              )
        else
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_showHours) ...[
                _AnimatedDigit(text: _displayHours, style: timerStyle),
                Text(':', style: timerStyle),
                const SizedBox(width: 1),
              ],
              _AnimatedDigit(text: _displayMinutes, style: timerStyle),
              if (!_showHours) ...[
                Text(':', style: timerStyle),
                const SizedBox(width: 1),
                _AnimatedDigit(text: _displaySeconds, style: timerStyle),
              ],
            ],
          ),
      ],
    );
  }
}

/// A single digit pair with a subtle vertical slide animation on change.
class _AnimatedDigit extends StatelessWidget {
  const _AnimatedDigit({required this.text, required this.style});

  final String text;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: ValueKey(text),
      child: Text(
        text,
        style: style,
      ),
    )
        .animate(key: ValueKey(text))
        .slideY(
          begin: -0.3,
          end: 0,
          duration: 300.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(duration: 200.ms);
  }
}
