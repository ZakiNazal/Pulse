import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/sport_config.dart';
import '../../../core/models/match.dart';
import '../../../core/models/sport_type.dart';

export 'hot_match_card.dart';

/// A compact horizontal match card for the "Hot Matches" section.
///
/// Features a gradient background based on the sport's accent color,
/// glassmorphism overlay, and live indicator pulsing animation.
class HotMatchCard extends StatelessWidget {
  const HotMatchCard({
    super.key,
    required this.match,
  });

  final Match match;

  @override
  Widget build(BuildContext context) {
    final gradient = SportConfig.gradient(match.sportType);
    final accentColor = SportConfig.accentColor(match.sportType);

    return GestureDetector(
      onTap: () => context.go('/match/${match.id}'),
      child: Container(
        width: 240,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: gradient,
          boxShadow: [
            BoxShadow(
              color: accentColor.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        // Glass overlay for depth
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Glassmorphism tint
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: Colors.white.withValues(alpha: 0.06),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                      width: 0.5,
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(2),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: Sport + League ─────────────────
                    Row(
                      children: [
                        Text(
                          match.sportType.emoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            match.league.name,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.85),
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        // Live dot
                        _buildLiveDot(),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // ── Teams & Score ──────────────────────────
                    Row(
                      children: [
                        // Home team
                        Expanded(
                          child: Text(
                            match.homeTeam.displayName,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                        // Score
                        if (match.homeScore != null && match.awayScore != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Text(
                                  '${match.homeScore}',
                                  style: AppTextStyles.scoreStyleSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                  ),
                                ),
                                Text(
                                  ' - ',
                                  style: AppTextStyles.scoreStyleSmall.copyWith(
                                    color: Colors.white.withValues(alpha: 0.5),
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '${match.awayScore}',
                                  style: AppTextStyles.scoreStyleSmall.copyWith(
                                    color: AppColors.textPrimary,
                                    fontSize: 20,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'vs',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                          ),
                        // Away team
                        Expanded(
                          child: Text(
                            match.awayTeam.displayName,
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),

                    const Spacer(),

                    // ── Footer: Elapsed / Time ─────────────────
                    Row(
                      children: [
                        if (match.isLive)
                          Text(
                            match.formattedElapsedTime,
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textPrimary.withValues(alpha: 0.9),
                              fontWeight: FontWeight.w700,
                            ),
                          )
                        else if (match.isUpcoming)
                          Text(
                            _formatTime(match.startTime),
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                            ),
                          )
                        else
                          Text(
                            'FT',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const Spacer(),
                        Text(
                          match.league.country,
                          style: AppTextStyles.caption.copyWith(
                            color: Colors.white.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms, delay: 100.ms)
        .slideX(begin: 0.15, end: 0, duration: 400.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildLiveDot() {
    return Container(
      width: 7,
      height: 7,
      decoration: const BoxDecoration(
        color: AppColors.liveRed,
        shape: BoxShape.circle,
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .scale(begin: const Offset(1.0, 1.0), end: const Offset(1.5, 1.5), duration: 900.ms)
        .fade(begin: 1.0, end: 0.2, duration: 900.ms);
  }

  String _formatTime(DateTime time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
