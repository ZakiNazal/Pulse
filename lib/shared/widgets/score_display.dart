import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/models/match.dart';
import '../../core/models/sport_type.dart';
import '../../core/constants/sport_config.dart';

/// Premium score display widget for match cards and detail views.
///
/// Features:
/// - Large score numbers with sport accent color tint
/// - Animated separator between scores
/// - Score change flash/pulse animation
/// - Tennis: optional sets breakdown display
/// - Basketball: period score tooltip on long press
/// - Handles null scores gracefully (shows "-")
class ScoreDisplay extends StatefulWidget {
  const ScoreDisplay({
    super.key,
    required this.match,
    this.style = ScoreDisplayStyle.large,
    this.animate = true,
    this.previousHomeScore,
    this.previousAwayScore,
  });

  /// The [Match] whose scores are displayed.
  final Match match;

  /// Display style variant.
  final ScoreDisplayStyle style;

  /// Whether entrance/change animations should play.
  final bool animate;

  /// Previous home score (for change detection & flash animation).
  final int? previousHomeScore;

  /// Previous away score (for change detection & flash animation).
  final int? previousAwayScore;

  @override
  State<ScoreDisplay> createState() => _ScoreDisplayState();
}

class _ScoreDisplayState extends State<ScoreDisplay> {
  bool _homeScoreChanged = false;
  bool _awayScoreChanged = false;

  @override
  void didUpdateWidget(ScoreDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.previousHomeScore != null &&
        widget.previousHomeScore != widget.match.homeScore) {
      _triggerHomeFlash();
    }
    if (widget.previousAwayScore != null &&
        widget.previousAwayScore != widget.match.awayScore) {
      _triggerAwayFlash();
    }
  }

  void _triggerHomeFlash() {
    setState(() => _homeScoreChanged = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _homeScoreChanged = false);
    });
  }

  void _triggerAwayFlash() {
    setState(() => _awayScoreChanged = true);
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) setState(() => _awayScoreChanged = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isUpcoming = widget.match.isUpcoming;
    final accentColor = SportConfig.accentColor(widget.match.sportType);
    final isLarge = widget.style == ScoreDisplayStyle.large;

    final homeText = widget.match.homeScore?.toString() ?? '-';
    final awayText = widget.match.awayScore?.toString() ?? '-';

    Widget scoreWidget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Home score
        _ScoreNumber(
          text: homeText,
          accentColor: isUpcoming ? AppColors.textTertiary : accentColor,
          isLarge: isLarge,
          flash: _homeScoreChanged,
        ),
        // Separator
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isLarge ? 12 : 8),
          child: Text(
            isUpcoming ? 'vs' : '-',
            style: isLarge
                ? AppTextStyles.scoreStyle.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 20,
                  )
                : AppTextStyles.scoreStyleSmall.copyWith(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                  ),
          ),
        ),
        // Away score
        _ScoreNumber(
          text: awayText,
          accentColor: isUpcoming ? AppColors.textTertiary : accentColor,
          isLarge: isLarge,
          flash: _awayScoreChanged,
        ),
      ],
    );

    // Wrap with basketball period tooltip
    if (widget.match.sportType == SportType.basketball &&
        widget.match.homeScoreDetails != null &&
        widget.match.homeScoreDetails!.isNotEmpty) {
      scoreWidget = GestureDetector(
        onLongPress: () => _showPeriodTooltip(context),
        child: scoreWidget,
      );
    }

    if (widget.animate) {
      scoreWidget = scoreWidget.animate().fade(
            duration: 300.ms,
            curve: Curves.easeOut,
          );
    }

    return scoreWidget;
  }

  void _showPeriodTooltip(BuildContext context) {
    final homeDetails = widget.match.homeScoreDetails!;
    final awayDetails = widget.match.awayScoreDetails ?? {};
    final keys = homeDetails.keys.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.divider,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Period Scores',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 16),
              Table(
                columnWidths: const {
                  0: FlexColumnWidth(3),
                  1: FlexColumnWidth(1),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                  4: FlexColumnWidth(1),
                  5: FlexColumnWidth(1),
                },
                children: [
                  // Header row
                  TableRow(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: AppColors.divider),
                      ),
                    ),
                    children: [
                      _headerCell('Team'),
                      ...keys.map((k) => _headerCell(k)),
                    ],
                  ),
                  // Home team row
                  TableRow(
                    children: [
                      _dataCell(widget.match.homeTeam.displayName),
                      ...keys.map((k) => _dataCell(
                            homeDetails[k]?.toString() ?? '-',
                            bold: true,
                          )),
                    ],
                  ),
                  // Away team row
                  TableRow(
                    children: [
                      _dataCell(widget.match.awayTeam.displayName),
                      ...keys.map((k) => _dataCell(
                            awayDetails[k]?.toString() ?? '-',
                            bold: true,
                          )),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _headerCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: AppTextStyles.labelSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _dataCell(String text, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

/// Individual score number with optional flash animation.
class _ScoreNumber extends StatelessWidget {
  const _ScoreNumber({
    required this.text,
    required this.accentColor,
    required this.isLarge,
    this.flash = false,
  });

  final String text;
  final Color accentColor;
  final bool isLarge;
  final bool flash;

  @override
  Widget build(BuildContext context) {
    final style = isLarge ? AppTextStyles.scoreStyle : AppTextStyles.scoreStyleSmall;
    final textStyle = style.copyWith(color: accentColor);

    Widget child = Text(
      text,
      style: textStyle,
    );

    if (flash) {
      child = child
          .animate(onPlay: (c) => c.forward())
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.3, 1.3),
            duration: 200.ms,
            curve: Curves.easeOut,
          )
          .then()
          .scale(
            begin: const Offset(1.3, 1.3),
            end: const Offset(1.0, 1.0),
            duration: 300.ms,
            curve: Curves.elasticOut,
          );
    }

    return SizedBox(
      width: isLarge ? 48 : 32,
      child: Center(child: child),
    );
  }
}

/// Display style variants for the score widget.
enum ScoreDisplayStyle {
  /// Full-size score for match cards and detail headers.
  large,

  /// Compact score for list items and previews.
  small,
}
