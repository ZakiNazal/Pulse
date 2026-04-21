import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/match.dart';
import '../../core/models/sport_type.dart';
import 'live_indicator.dart';

/// A status badge widget that displays the current state of a match.
///
/// Supports sport-specific status display:
/// - **Football**: LIVE / HT / FT / 1H / 2H
/// - **Basketball**: LIVE / Q1-Q4 / HT / FT
/// - **American Football**: LIVE / Q1-Q4 / HT / FT
/// - **Esports**: LIVE / Map X / FT
///
/// Each status has a distinct color and optional pulse animation.
class MatchStatusBadge extends StatelessWidget {
  const MatchStatusBadge({
    super.key,
    required this.match,
    this.compact = false,
    this.showLiveIndicator = true,
  });

  /// The [Match] whose status is displayed.
  final Match match;

  /// When `true`, renders a compact pill without the live indicator.
  final bool compact;

  /// Whether to show the pulsing [LiveIndicator] for live matches.
  final bool showLiveIndicator;

  @override
  Widget build(BuildContext context) {
    return switch (match.status) {
      MatchStatus.live => _buildLive(context),
      MatchStatus.upcoming => _buildUpcoming(context),
      MatchStatus.finished => _buildFinished(context),
    };
  }

  Widget _buildLive(BuildContext context) {
    final sportLabel = _sportLiveLabel;

    if (compact && !showLiveIndicator) {
      return _BadgeContainer(
        color: AppColors.liveRed,
        child: Text(
          sportLabel,
          style: AppTextStyles.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 10,
          ),
        ),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLiveIndicator)
          const LiveIndicator(dotSize: 6)
        else
          _BadgeContainer(
            color: AppColors.liveRed,
            child: Text(
              'LIVE',
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        if (sportLabel != 'LIVE') ...[
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.liveRed.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: AppColors.liveRed.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              sportLabel,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.liveRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    ).animate().fade(duration: 200.ms).scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 300.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildUpcoming(BuildContext context) {
    final startTime = _formatStartTime(match.startTime);
    return _BadgeContainer(
      color: AppColors.textTertiary,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.schedule_rounded,
            size: 12,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 4),
          Text(
            startTime,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    ).animate().fade(duration: 300.ms);
  }

  Widget _buildFinished(BuildContext context) {
    final label = _sportFinishedLabel;

    return _BadgeContainer(
      color: AppColors.textTertiary.withValues(alpha: 0.6),
      child: Text(
        label,
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.textSecondary,
          fontWeight: FontWeight.w600,
        ),
      ),
    ).animate().fade(duration: 300.ms);
  }

  // ── Sport-specific labels ──────────────────────────────────────────

  /// Returns the live label considering sport-specific period info.
  String get _sportLiveLabel {
    // If there's a formatted elapsed time from the match model, use it.
    final formatted = match.formattedElapsedTime;
    if (formatted.isNotEmpty && formatted != 'LIVE') {
      return formatted;
    }

    // Fall back to generic period labels based on sport type.
    switch (match.sportType) {
      case SportType.basketball:
      case SportType.americanFootball:
        final quarter = match.extraInfo['currentQuarter'] as int?;
        if (quarter != null) return 'Q$quarter';
        return 'LIVE';

      case SportType.football:
        final half = match.extraInfo['half'] as int?;
        if (half == 1) return '1H';
        if (half == 2) return '2H';
        return 'LIVE';

      case SportType.f1:
        final lap = match.extraInfo['currentLap'] as int?;
        if (lap != null) return 'LAP $lap';
        return 'RACING';

      case SportType.mma:
        final round = match.extraInfo['currentRound'] as int?;
        if (round != null) return 'R$round';
        return 'FIGHTING';
      
      case SportType.tennis:
        final set = match.extraInfo['currentSet'] as int?;
        if (set != null) return 'SET $set';
        return 'PLAYING';
    }
  }

  /// Returns the finished label considering sport-specific endings.
  String get _sportFinishedLabel {
    switch (match.sportType) {
      case SportType.football:
        return 'FT';
      case SportType.basketball:
        return 'FT';
      case SportType.americanFootball:
        return match.extraInfo['result'] as String? ?? 'FT';
      case SportType.f1:
        return 'FINISHED';
      case SportType.mma:
        return match.extraInfo['result'] as String? ?? 'FINISHED';
      
      case SportType.tennis:
        return match.extraInfo['result'] as String? ?? 'COMPLETED';
    }
  }

  String _formatStartTime(DateTime time) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final matchDay = DateTime(time.year, time.month, time.day);
    final diff = matchDay.difference(today).inDays;

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    final timeStr = '$hour:$minute';

    if (diff == 0) return 'Today $timeStr';
    if (diff == 1) return 'Tomorrow $timeStr';
    if (diff == -1) return 'Yesterday $timeStr';
    return '${time.day}/${time.month} $timeStr';
  }
}

/// Internal pill-shaped container for badge content.
class _BadgeContainer extends StatelessWidget {
  const _BadgeContainer({
    required this.color,
    required this.child,
  });

  final Color color;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: child,
    );
  }
}
