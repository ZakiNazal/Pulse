import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/sport_config.dart';
import '../../core/models/match.dart';
import '../../core/models/sport_type.dart';
import 'countdown_timer.dart';
import 'match_status_badge.dart';
import 'score_display.dart';

/// The premium match card — the visual centerpiece of the Pulse app.
///
/// Features:
/// - Sport-colored left accent bar
/// - League name with country context
/// - Team names with logo avatars (initials fallback)
/// - Large score display with sport accent color
/// - Status section: LIVE (elapsed minutes + pulse), UPCOMING (countdown or
///   start time), FINISHED (FT badge)
/// - 🔥 hot indicator for trending matches
/// - Glassmorphism card background (translucent + blur)
/// - Subtle glass border with gradient shimmer
/// - Press-down animation on tap
/// - Live glow effect using sport accent color
/// - `flutter_animate` entrance animation
/// - [onTap] callback for hero navigation
class MatchCard extends StatefulWidget {
  const MatchCard({
    super.key,
    required this.match,
    this.onTap,
    this.heroTag,
    this.showLeague = true,
    this.animateEntrance = true,
    this.index = 0,
  });

  /// The [Match] to display.
  final Match match;

  /// Callback fired when the card is tapped.
  final VoidCallback? onTap;

  /// Optional hero tag for shared element transitions.
  final String? heroTag;

  /// Whether to show the league header row.
  final bool showLeague;

  /// Whether to play the entrance animation.
  final bool animateEntrance;

  /// Index used to stagger entrance animations in a list.
  final int index;

  @override
  State<MatchCard> createState() => _MatchCardState();
}

class _MatchCardState extends State<MatchCard> {
  bool _isPressed = false;

  /// Returns a background color with slight transparency for the glass effect.
  Color get _glassBackground {
    if (widget.match.isLive) {
      final accent = SportConfig.accentColor(widget.match.sportType);
      return accent.withValues(alpha: 0.06);
    }
    return AppColors.surface;
  }

  /// Returns a glowing box shadow for live matches.
  List<BoxShadow> get _liveGlow {
    if (!widget.match.isLive) return [];
    final accent = SportConfig.accentColor(widget.match.sportType);
    return [
      BoxShadow(
        color: accent.withValues(alpha: 0.15),
        blurRadius: 20,
        spreadRadius: -2,
        offset: const Offset(0, 4),
      ),
      BoxShadow(
        color: accent.withValues(alpha: 0.08),
        blurRadius: 40,
        spreadRadius: 0,
        offset: const Offset(0, 8),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = SportConfig.accentColor(widget.match.sportType);
    final delay = widget.animateEntrance
        ? (widget.index * 60).ms
        : 0.ms;

    Widget card = GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: _glassBackground,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.glassBorder,
              width: 0.5,
            ),
            boxShadow: _liveGlow,
          ),
          clipBehavior: Clip.antiAlias,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                // ── Left sport accent bar ────────────────────────────
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: Container(
                    width: 4,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.4),
                        ],
                      ),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        bottomLeft: Radius.circular(2),
                      ),
                    ),
                  ),
                ),

                // ── Card content ─────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.only(left: 16, right: 16, top: 14, bottom: 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // League header
                      if (widget.showLeague) ...[
                        _buildLeagueHeader(accentColor),
                        const SizedBox(height: 12),
                      ],

                      // Main match content: teams + score
                      IntrinsicHeight(
                        child: Row(
                          children: [
                            // Home team
                            Expanded(child: _buildTeamColumn(widget.match.homeTeam, isHome: true)),
                            
                            // Score / status center
                            _buildCenterColumn(accentColor),
                            
                            // Away team
                            Expanded(child: _buildTeamColumn(widget.match.awayTeam, isHome: false)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // ── Hot indicator ────────────────────────────────────
                if (widget.match.isHot)
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _buildHotIndicator(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );

    if (widget.animateEntrance) {
      card = card.animate(delay: delay).fadeIn(
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          ).slideY(
            begin: 0.1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          );
    }

    return card;
  }

  // ── League Header ──────────────────────────────────────────────────

  Widget _buildLeagueHeader(Color accentColor) {
    return Row(
      children: [
        // Sport emoji
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6),
          ),
          alignment: Alignment.center,
          child: Text(
            widget.match.sportType.emoji,
            style: const TextStyle(fontSize: 13),
          ),
        ),
        const SizedBox(width: 8),
        // League name
        Expanded(
          child: Text(
            widget.match.league.name,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textSecondary,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        // Country flag indicator
        if (widget.match.league.flag != null)
          Container(
            width: 18,
            height: 13,
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: AppColors.divider,
                width: 0.5,
              ),
            ),
            // In production, load the actual flag image here.
            // For now, show country code initials.
            alignment: Alignment.center,
            child: Text(
              _countryInitials(widget.match.league.country),
              style: AppTextStyles.labelSmall.copyWith(fontSize: 7),
            ),
          ),
        const SizedBox(width: 4),
      ],
    );
  }

  String _countryInitials(String country) {
    final parts = country.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return country.substring(0, 2).toUpperCase();
  }

  // ── Team Column ────────────────────────────────────────────────────

  Widget _buildTeamColumn(dynamic teamData, {required bool isHome}) {
    final name = isHome ? widget.match.homeTeam.displayName : widget.match.awayTeam.displayName;
    final logo = isHome ? widget.match.homeTeam.logo : widget.match.awayTeam.logo;
    final fullName = isHome ? widget.match.homeTeam.name : widget.match.awayTeam.name;
    final isWinning = _isTeamWinning(isHome);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Team logo avatar
        _TeamAvatar(
          logo: logo,
          initials: _getInitials(fullName),
          accentColor: isWinning ? SportConfig.accentColor(widget.match.sportType) : null,
        ),
        const SizedBox(height: 8),
        // Team name
        Text(
          name,
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: isWinning ? FontWeight.w700 : FontWeight.w500,
            color: isWinning ? AppColors.textPrimary : AppColors.textSecondary,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  bool _isTeamWinning(bool isHome) {
    if (!widget.match.isLive && !widget.match.isFinished) return false;
    final home = widget.match.homeScore;
    final away = widget.match.awayScore;
    if (home == null || away == null) return false;
    return isHome ? home > away : away > home;
  }

  String _getInitials(String name) {
    final parts = name.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').split(' ').where((w) => w.isNotEmpty).toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }

  // ── Center Column (Score + Status) ─────────────────────────────────

  Widget _buildCenterColumn(Color accentColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Status badge
          MatchStatusBadge(
            match: widget.match,
            compact: true,
            showLiveIndicator: false,
          ),
          const SizedBox(height: 8),
          // Score display
          ScoreDisplay(
            match: widget.match,
            style: ScoreDisplayStyle.large,
          ),
          const SizedBox(height: 8),
          // Live elapsed time / upcoming countdown
          if (widget.match.isLive)
            Text(
              widget.match.formattedElapsedTime,
              style: AppTextStyles.labelSmall.copyWith(
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            )
          else if (widget.match.isUpcoming)
            CountdownTimer(
              targetTime: widget.match.startTime,
            )
          else
            const SizedBox.shrink(),
        ],
      ),
    );
  }

  // ── Hot Indicator ──────────────────────────────────────────────────

  Widget _buildHotIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.orange.withValues(alpha: 0.2),
            Colors.red.withValues(alpha: 0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('🔥', style: TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            'HOT',
            style: AppTextStyles.labelSmall.copyWith(
              color: Colors.orange,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ],
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true)).scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.05, 1.05),
          duration: 1500.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Team avatar — loads from URL (CachedNetworkImage) or falls back to initials.
class _TeamAvatar extends StatelessWidget {
  const _TeamAvatar({
    this.logo,
    required this.initials,
    this.accentColor,
  });

  final String? logo;
  final String initials;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final hasAccent = accentColor != null;
    final bg = hasAccent
        ? accentColor!.withValues(alpha: 0.15)
        : AppColors.surfaceLight;

    Widget avatar;

    if (logo != null && logo!.startsWith('http')) {
      avatar = CircleAvatar(
        radius: 20,
        backgroundColor: bg,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: logo!,
            width: 36,
            height: 36,
            fit: BoxFit.contain,
            placeholder: (_, __) => Text(
              initials,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: hasAccent ? accentColor : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
            errorWidget: (_, __, ___) => Text(
              initials,
              style: AppTextStyles.labelMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: hasAccent ? accentColor : AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    } else {
      avatar = CircleAvatar(
        radius: 20,
        backgroundColor: bg,
        child: Text(
          initials,
          style: AppTextStyles.labelMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: hasAccent ? accentColor : AppColors.textSecondary,
            fontSize: 13,
          ),
        ),
      );
    }

    return avatar;
  }
}
