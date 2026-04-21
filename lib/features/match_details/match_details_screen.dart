import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/sport_config.dart';
import '../../core/models/match.dart';
import '../../core/models/sport_type.dart';
import '../../shared/providers/match_provider.dart';

/// The match details screen with Hero animation support, tabbed content
/// (Overview / Events / Stats), and premium animated UI.
class MatchDetailsScreen extends ConsumerStatefulWidget {
  const MatchDetailsScreen({
    super.key,
    required this.matchId,
  });

  /// The id of the match to display.
  final String matchId;

  @override
  ConsumerState<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends ConsumerState<MatchDetailsScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchNotifierProvider);
    final match = state.getMatchById(widget.matchId);

    if (match == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary),
            onPressed: () => context.go('/'),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.sports, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text(
                'Match not found',
                style: AppTextStyles.headingMedium,
              ),
            ],
          ),
        ),
      );
    }

    final accentColor = SportConfig.accentColor(match.sportType);
    final gradient = SportConfig.gradient(match.sportType);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar ────────────────────────────────────────
            SliverAppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              pinned: true,
              stretch: true,
              leading: GestureDetector(
                onTap: () => context.go('/'),
                child: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.glassBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder, width: 0.5),
                  ),
                  child: const Icon(
                    Icons.arrow_back_ios_new,
                    color: AppColors.textPrimary,
                    size: 18,
                  ),
                ),
              ),
              actions: [
                Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.glassBackground,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.glassBorder, width: 0.5),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.share, color: AppColors.textSecondary, size: 18),
                    onPressed: () {
                      // TODO: Share functionality
                    },
                  ),
                ),
              ],
              expandedHeight: 280,
              flexibleSpace: FlexibleSpaceBar(
                background: _buildHeroHeader(match, accentColor, gradient),
              ),
            ),

            // ── Status Badge + League ──────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: _buildStatusAndLeague(match, accentColor),
              ),
            ),

            // ── Tab Bar ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildDetailTabBar(accentColor),
            ),

            // ── Tab Content ────────────────────────────────────
            SliverFillRemaining(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _OverviewTab(match: match),
                  _EventsTab(match: match),
                  _StatsTab(match: match),
                ],
              ),
            ),

            // ── Watch Together + Prediction ────────────────────
            SliverToBoxAdapter(
              child: _buildBottomActions(match, accentColor),
            ),
          ],
        ),
      ),
    );
  }

  // ── Hero Header ────────────────────────────────────────────────────

  Widget _buildHeroHeader(Match match, Color accentColor, LinearGradient gradient) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            accentColor.withValues(alpha: 0.15),
            AppColors.background.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              // ── Teams Row ───────────────────────────────────
              Row(
                children: [
                  // Home team
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamShield(match.homeTeam, accentColor),
                        const SizedBox(height: 10),
                        Text(
                          match.homeTeam.displayName,
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),

                  // Score / VS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildScoreDisplay(match, accentColor),
                  ),

                  // Away team
                  Expanded(
                    child: Column(
                      children: [
                        _buildTeamShield(match.awayTeam, accentColor),
                        const SizedBox(height: 10),
                        Text(
                          match.awayTeam.displayName,
                          style: AppTextStyles.headingMedium.copyWith(
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 2,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .slideY(begin: -0.1, end: 0, duration: 500.ms, curve: Curves.easeOutCubic);
  }

  Widget _buildTeamShield(dynamic team, Color accentColor) {
    // Show a styled placeholder when no logo is available
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        shape: BoxShape.circle,
        border: Border.all(color: accentColor.withValues(alpha: 0.3), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: accentColor.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Center(
        child: Text(
          team.shortName?.isNotEmpty == true
              ? team.shortName!.substring(0, 2)
              : team.name.substring(0, 2),
          style: AppTextStyles.headingMedium.copyWith(
            color: accentColor,
            fontSize: 18,
          ),
        ),
      ),
    )
        .animate()
        .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 500.ms, delay: 200.ms, curve: Curves.elasticOut);
  }

  Widget _buildScoreDisplay(Match match, Color accentColor) {
    if (match.homeScore != null && match.awayScore != null) {
      return Column(
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${match.homeScore}',
                style: AppTextStyles.scoreStyle.copyWith(
                  fontSize: 48,
                  color: match.isLive ? accentColor : AppColors.textPrimary,
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms, delay: 300.ms),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  '-',
                  style: AppTextStyles.scoreStyle.copyWith(
                    fontSize: 36,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              Text(
                '${match.awayScore}',
                style: AppTextStyles.scoreStyle.copyWith(
                  fontSize: 48,
                  color: match.isLive ? accentColor : AppColors.textPrimary,
                ),
              )
                  .animate()
                  .scale(begin: const Offset(0.8, 0.8), end: const Offset(1, 1), duration: 400.ms, delay: 300.ms),
            ],
          ),
          if (match.isLive) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.liveRed.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: AppColors.liveRed,
                      shape: BoxShape.circle,
                    ),
                  ).animate(onPlay: (c) => c.repeat()).scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.5, 1.5),
                        duration: 800.ms,
                      ).fade(begin: 1.0, end: 0.2, duration: 800.ms),
                  const SizedBox(width: 6),
                  Text(
                    match.formattedElapsedTime,
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.liveRed,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      );
    }

    // Upcoming match
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          const Icon(Icons.schedule, size: 24, color: AppColors.textTertiary),
          const SizedBox(height: 4),
          Text(
            '${match.startTime.hour.toString().padLeft(2, '0')}:${match.startTime.minute.toString().padLeft(2, '0')}',
            style: AppTextStyles.headingMedium,
          ),
        ],
      ),
    );
  }

  // ── Status + League Row ────────────────────────────────────────────

  Widget _buildStatusAndLeague(Match match, Color accentColor) {
    return Row(
      children: [
        // Status badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: match.isLive
                ? AppColors.liveRed.withValues(alpha: 0.12)
                : AppColors.surfaceLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: match.isLive
                  ? AppColors.liveRed.withValues(alpha: 0.3)
                  : AppColors.divider,
            ),
          ),
          child: Text(
            match.status.displayName,
            style: AppTextStyles.labelSmall.copyWith(
              color: match.isLive ? AppColors.liveRed : AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        // League
        Text(
          match.league.name,
          style: AppTextStyles.labelMedium,
        ),
        const Spacer(),
        // Country flag emoji placeholder
        Text(
          match.league.country,
          style: AppTextStyles.caption,
        ),
      ],
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
  }

  // ── Detail Tab Bar ─────────────────────────────────────────────────

  Widget _buildDetailTabBar(Color accentColor) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.surfaceLighter,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow.withValues(alpha: 0.2),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        tabs: const [
          Tab(height: 36, child: Text('Overview')),
          Tab(height: 36, child: Text('Events')),
          Tab(height: 36, child: Text('Stats')),
        ],
      ),
    );
  }

  // ── Bottom Actions (Watch Together + Prediction) ───────────────────

  Widget _buildBottomActions(Match match, Color accentColor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        children: [
          // ── Watch Together ───────────────────────────────────
          _WatchTogetherWidget(accentColor: accentColor),

          const SizedBox(height: 12),

          // ── Quick Prediction ─────────────────────────────────
          _QuickPredictionWidget(match: match, accentColor: accentColor),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// OVERVIEW TAB
// ══════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        // ── Match Info ───────────────────────────────────────
        const _SectionTitle(title: 'Match Info'),
        const SizedBox(height: 10),
        _InfoRow(icon: Icons.location_on_outlined, label: 'Venue', value: match.venue ?? 'TBD'),
        if (match.extraInfo.containsKey('referee'))
          _InfoRow(icon: Icons.sports, label: 'Referee', value: match.extraInfo['referee'] as String),
        _InfoRow(
          icon: Icons.calendar_today_outlined,
          label: 'Date',
          value: '${match.startTime.day}/${match.startTime.month}/${match.startTime.year}',
        ),
        _InfoRow(
          icon: Icons.schedule,
          label: 'Kick-off',
          value: '${match.startTime.hour.toString().padLeft(2, '0')}:${match.startTime.minute.toString().padLeft(2, '0')}',
        ),

        const SizedBox(height: 24),

        // ── Key Stats ────────────────────────────────────────
        const _SectionTitle(title: 'Key Stats'),
        const SizedBox(height: 12),
        ..._buildKeyStats(match),

        const SizedBox(height: 24),

        // ── Score Breakdown ─────────────────────────────────
        if (match.homeScoreDetails != null && match.homeScoreDetails!.isNotEmpty) ...[
          const _SectionTitle(title: 'Score Breakdown'),
          const SizedBox(height: 12),
          _ScoreBreakdown(match: match),
        ],
      ],
    );
  }

  List<Widget> _buildKeyStats(Match match) {
    switch (match.sportType) {
      case SportType.football:
        return [
          const _AnimatedStatBar(
            label: 'Possession',
            homeValue: 58,
            awayValue: 42,
            homeAccent: true,
          ),
          const _AnimatedStatBar(
            label: 'Shots on Target',
            homeValue: 7,
            awayValue: 4,
            homeAccent: true,
          ),
          const _AnimatedStatBar(
            label: 'Corners',
            homeValue: 6,
            awayValue: 3,
          ),
          const _AnimatedStatBar(
            label: 'Fouls',
            homeValue: 9,
            awayValue: 12,
          ),
        ];
      case SportType.basketball:
        return [
          const _AnimatedStatBar(
            label: 'Field Goal %',
            homeValue: 48,
            awayValue: 45,
            suffix: '%',
            homeAccent: true,
          ),
          const _AnimatedStatBar(
            label: 'Rebounds',
            homeValue: 42,
            awayValue: 38,
            homeAccent: true,
          ),
          const _AnimatedStatBar(
            label: 'Assists',
            homeValue: 24,
            awayValue: 21,
          ),
          const _AnimatedStatBar(
            label: 'Turnovers',
            homeValue: 11,
            awayValue: 14,
          ),
        ];
      case SportType.americanFootball:
        return [
          const _AnimatedStatBar(label: 'Total Yards', homeValue: 380, awayValue: 340, homeAccent: true),
          const _AnimatedStatBar(label: 'Passing Yards', homeValue: 260, awayValue: 220),
          const _AnimatedStatBar(label: 'Rushing Yards', homeValue: 120, awayValue: 120),
          const _AnimatedStatBar(label: 'Turnovers', homeValue: 1, awayValue: 2),
        ];
      case SportType.mma:
        return [
          const _AnimatedStatBar(label: 'Hits', homeValue: 45, awayValue: 38, homeAccent: true),
          const _AnimatedStatBar(label: 'Misses', homeValue: 22, awayValue: 28),
          const _AnimatedStatBar(label: 'Strikes', homeValue: 60, awayValue: 55, homeAccent: true),
          const _AnimatedStatBar(label: 'Accuracy', homeValue: 8, awayValue: 5),
        ];
      case SportType.f1:
        return [
          const _AnimatedStatBar(label: 'Lap Time', homeValue: 1, awayValue: 2, homeAccent: true),
          const _AnimatedStatBar(label: 'Speed', homeValue: 200, awayValue: 180),
          const _AnimatedStatBar(label: 'Pit Stops', homeValue: 2, awayValue: 3),
          const _AnimatedStatBar(label: 'Penalties', homeValue: 0, awayValue: 1),
        ];
      case SportType.tennis:
        return [
          const _AnimatedStatBar(label: 'First Serve %', homeValue: 65, awayValue: 62, suffix: '%', homeAccent: true),
          const _AnimatedStatBar(label: 'Aces', homeValue: 8, awayValue: 5),
          const _AnimatedStatBar(label: 'Winners', homeValue: 28, awayValue: 22),
          const _AnimatedStatBar(label: 'Unforced Errors', homeValue: 18, awayValue: 21),
        ];
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// EVENTS TAB
// ══════════════════════════════════════════════════════════════════════

class _EventsTab extends StatelessWidget {
  const _EventsTab({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final events = _generateEvents(match);

    if (events.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.timeline, size: 48, color: AppColors.textTertiary),
              const SizedBox(height: 16),
              Text(
                'No events yet',
                style: AppTextStyles.bodyLarge.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        final isHome = event.isHome;
        return _EventTile(
          event: event,
          isHome: isHome,
          accentColor: SportConfig.accentColor(match.sportType),
        )
            .animate()
            .fadeIn(delay: Duration(milliseconds: 80 * index), duration: 400.ms)
            .slideY(begin: 0.15, end: 0, delay: Duration(milliseconds: 80 * index), duration: 400.ms, curve: Curves.easeOutCubic);
      },
    );
  }

  List<_MatchEvent> _generateEvents(Match match) {
    switch (match.sportType) {
      case SportType.football:
        return [
          _MatchEvent(minute: 12, icon: Icons.sports_soccer, description: 'Goal', player: match.homeTeam.displayName, isHome: true, type: _EventType.goal),
          _MatchEvent(minute: 23, icon: Icons.warning_amber_rounded, description: 'Yellow Card', player: match.awayTeam.displayName, isHome: false, type: _EventType.card),
          _MatchEvent(minute: 34, icon: Icons.sports_soccer, description: 'Goal', player: match.awayTeam.displayName, isHome: false, type: _EventType.goal),
          _MatchEvent(minute: 45, icon: Icons.swap_horiz, description: 'Substitution', player: 'Player Change', isHome: true, type: _EventType.substitution),
          _MatchEvent(minute: 56, icon: Icons.sports_soccer, description: 'Goal', player: match.homeTeam.displayName, isHome: true, type: _EventType.goal),
          _MatchEvent(minute: 67, icon: Icons.swap_horiz, description: 'Substitution', player: 'Tactical Change', isHome: false, type: _EventType.substitution),
          _MatchEvent(minute: 72, icon: Icons.warning_amber_rounded, description: 'Yellow Card', player: match.homeTeam.displayName, isHome: true, type: _EventType.card),
          _MatchEvent(minute: 80, icon: Icons.swap_horiz, description: 'Substitution', player: 'Player Change', isHome: true, type: _EventType.substitution),
        ];
      case SportType.basketball:
        return [
          _MatchEvent(minute: 0, icon: Icons.sports_basketball, description: '2-Point Shot', player: match.homeTeam.displayName, isHome: true, type: _EventType.point),
          _MatchEvent(minute: 5, icon: Icons.sports_basketball, description: '3-Point Shot', player: match.awayTeam.displayName, isHome: false, type: _EventType.threePoint),
          _MatchEvent(minute: 12, icon: Icons.sports_basketball, description: 'Free Throw', player: match.homeTeam.displayName, isHome: true, type: _EventType.freeThrow),
          _MatchEvent(minute: 18, icon: Icons.swap_horiz, description: 'Timeout', player: match.awayTeam.displayName, isHome: false, type: _EventType.substitution),
          _MatchEvent(minute: 24, icon: Icons.sports_basketball, description: '3-Point Shot', player: match.awayTeam.displayName, isHome: false, type: _EventType.threePoint),
          _MatchEvent(minute: 30, icon: Icons.warning_amber_rounded, description: 'Foul', player: match.homeTeam.displayName, isHome: true, type: _EventType.card),
        ];
      case SportType.americanFootball:
        return [
          _MatchEvent(minute: 0, icon: Icons.sports_football, description: 'Touchdown', player: match.homeTeam.displayName, isHome: true, type: _EventType.goal),
          _MatchEvent(minute: 8, icon: Icons.sports_football, description: 'Field Goal', player: match.awayTeam.displayName, isHome: false, type: _EventType.point),
          _MatchEvent(minute: 15, icon: Icons.sports_football, description: 'Touchdown', player: match.awayTeam.displayName, isHome: false, type: _EventType.goal),
          _MatchEvent(minute: 22, icon: Icons.warning_amber_rounded, description: 'Fumble', player: match.homeTeam.displayName, isHome: true, type: _EventType.card),
        ];
      case SportType.f1:
        return [
          _MatchEvent(minute: 0, icon: Icons.directions_car, description: 'Race Start', player: match.homeTeam.displayName, isHome: true, type: _EventType.goal),
          _MatchEvent(minute: 5, icon: Icons.build, description: 'Pit Stop', player: match.awayTeam.displayName, isHome: false, type: _EventType.card),
          _MatchEvent(minute: 15, icon: Icons.speed, description: 'Fastest Lap', player: match.homeTeam.displayName, isHome: true, type: _EventType.point),
          _MatchEvent(minute: 25, icon: Icons.flag, description: 'Checkered Flag', player: match.awayTeam.displayName, isHome: false, type: _EventType.threePoint),
        ];
      case SportType.mma:
        return [
          _MatchEvent(minute: 0, icon: Icons.sports_mma, description: 'Knockdown', player: match.homeTeam.displayName, isHome: true, type: _EventType.goal),
          _MatchEvent(minute: 8, icon: Icons.sports_mma, description: 'Knockdown', player: match.awayTeam.displayName, isHome: false, type: _EventType.goal),
          _MatchEvent(minute: 15, icon: Icons.sports_mma, description: 'Submission', player: match.homeTeam.displayName, isHome: true, type: _EventType.point),
          _MatchEvent(minute: 25, icon: Icons.sports_mma, description: 'TKO', player: match.awayTeam.displayName, isHome: false, type: _EventType.threePoint),
        ];
      default:
        // Return a generic event list for unsupported sport types
        return [
          _MatchEvent(minute: 0, icon: Icons.sports, description: 'Event Started', player: match.homeTeam.displayName, isHome: true, type: _EventType.goal),
          _MatchEvent(minute: 45, icon: Icons.sports, description: 'Event Progress', player: match.awayTeam.displayName, isHome: false, type: _EventType.point),
        ];
    }
  }
}

enum _EventType { goal, card, substitution, point, threePoint, freeThrow }

class _MatchEvent {
  _MatchEvent({
    required this.minute,
    required this.icon,
    required this.description,
    required this.player,
    required this.isHome,
    required this.type,
  });

  final int minute;
  final IconData icon;
  final String description;
  final String player;
  final bool isHome;
  final _EventType type;
}

class _EventTile extends StatelessWidget {
  const _EventTile({
    required this.event,
    required this.isHome,
    required this.accentColor,
  });

  final _MatchEvent event;
  final bool isHome;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final eventColor = _eventColor(event.type);

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left side (home if not isHome)
            Expanded(
              child: isHome
                  ? _buildEventContent(eventColor, alignRight: true)
                  : const SizedBox(),
            ),

            // Timeline center
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  // Minute
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceLight,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.divider, width: 0.5),
                    ),
                    child: Text(
                      "${event.minute}'",
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  // Line
                  Container(
                    width: 2,
                    height: 20,
                    color: AppColors.divider,
                  ),
                  // Dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: eventColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: eventColor.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right side (away if isHome)
            Expanded(
              child: isHome
                  ? const SizedBox()
                  : _buildEventContent(eventColor, alignRight: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEventContent(Color eventColor, {required bool alignRight}) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Row(
        mainAxisAlignment: alignRight ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!alignRight) ...[
            Icon(event.icon, size: 16, color: eventColor),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  event.description,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: eventColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  event.player,
                  style: AppTextStyles.caption,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (alignRight) ...[
            const SizedBox(width: 8),
            Icon(event.icon, size: 16, color: eventColor),
          ],
        ],
      ),
    );
  }

  Color _eventColor(_EventType type) {
    switch (type) {
      case _EventType.goal:
      case _EventType.threePoint:
        return AppColors.successGreen;
      case _EventType.card:
        return AppColors.warningAmber;
      case _EventType.substitution:
        return AppColors.mmaAccent;
      case _EventType.point:
      case _EventType.freeThrow:
        return AppColors.footballAccent;
    }
  }
}

// ══════════════════════════════════════════════════════════════════════
// STATS TAB
// ══════════════════════════════════════════════════════════════════════

class _StatsTab extends StatelessWidget {
  const _StatsTab({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final stats = _getStats(match);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
      physics: const NeverScrollableScrollPhysics(),
      children: [
        _SectionTitle(title: '${match.sportType.displayName} Statistics'),
        const SizedBox(height: 12),

        // Team names header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  match.homeTeam.displayName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(width: 40),
              Expanded(
                child: Text(
                  match.awayTeam.displayName,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Stat rows
        ...stats.asMap().entries.map((entry) {
          return _ComparisonBar(
            stat: entry.value,
            accentColor: SportConfig.accentColor(match.sportType),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: 100 * entry.key), duration: 400.ms)
              .slideX(
                begin: -0.05,
                end: 0,
                delay: Duration(milliseconds: 100 * entry.key),
                duration: 400.ms,
              );
        }),
      ],
    );
  }

  List<_StatEntry> _getStats(Match match) {
    switch (match.sportType) {
      case SportType.football:
        return [
          _StatEntry('Possession', 58, 42),
          _StatEntry('Shots on Target', 7, 4),
          _StatEntry('Total Shots', 14, 9),
          _StatEntry('Corners', 6, 3),
          _StatEntry('Fouls', 9, 12),
          _StatEntry('Offsides', 3, 5),
          _StatEntry('Pass Accuracy', 87, 82),
        ];
      case SportType.basketball:
        return [
          _StatEntry('Field Goal %', 48, 45),
          _StatEntry('3-Point %', 38, 42),
          _StatEntry('Free Throw %', 85, 78),
          _StatEntry('Rebounds', 42, 38),
          _StatEntry('Assists', 24, 21),
          _StatEntry('Steals', 8, 6),
          _StatEntry('Blocks', 5, 4),
          _StatEntry('Turnovers', 11, 14),
        ];
      case SportType.tennis:
        return [
          _StatEntry('Aces', 8, 5),
          _StatEntry('Double Faults', 3, 6),
          _StatEntry('Winners', 28, 22),
          _StatEntry('Unforced Errors', 18, 21),
          _StatEntry('Break Points Won', 4, 3),
          _StatEntry('Net Points Won', 12, 15),
        ];
      case SportType.mma:
        return [
          _StatEntry('Knockdowns', 12, 8),
          _StatEntry('Significant Strikes', 6, 4),
          _StatEntry('Submission Attempts', 8, 3),
          _StatEntry('Takedowns', 2, 5),
        ];
      case SportType.f1:
        return [
          _StatEntry('Pit Stops', 2, 3),
          _StatEntry('Fastest Lap', 1, 2),
          _StatEntry('Positions Gained', 3, -1),
        ];
      case SportType.americanFootball:
        return [
          _StatEntry('Total Yards', 380, 340),
          _StatEntry('Passing Yards', 260, 220),
          _StatEntry('Rushing Yards', 120, 120),
          _StatEntry('Turnovers', 1, 2),
          _StatEntry('Penalties', 5, 8),
          _StatEntry('3rd Down Conv.', 45, 38),
        ];
    }
  }
}

class _StatEntry {
  _StatEntry(this.label, this.homeValue, this.awayValue);
  final String label;
  final int homeValue;
  final int awayValue;
}

// ══════════════════════════════════════════════════════════════════════
// SHARED WIDGETS
// ══════════════════════════════════════════════════════════════════════

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: AppTextStyles.headingSmall.copyWith(fontSize: 16),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.textTertiary),
          const SizedBox(width: 10),
          Text(
            label,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: AppTextStyles.labelMedium.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated horizontal stat bar for the overview tab.
class _AnimatedStatBar extends StatefulWidget {
  const _AnimatedStatBar({
    required this.label,
    required this.homeValue,
    required this.awayValue,
    this.suffix = '',
    this.homeAccent = false,
  });

  final String label;
  final int homeValue;
  final int awayValue;
  final String suffix;
  final bool homeAccent;

  @override
  State<_AnimatedStatBar> createState() => _AnimatedStatBarState();
}

class _AnimatedStatBarState extends State<_AnimatedStatBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.homeValue + widget.awayValue;
    if (total == 0) return const SizedBox.shrink();
    final homePct = widget.homeValue / total;
    final awayPct = widget.awayValue / total;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              widget.label,
              style: AppTextStyles.labelSmall,
            ),
          ),
          // Bar
          Row(
            children: [
              // Home value
              SizedBox(
                width: 36,
                child: Text(
                  '${widget.homeValue}${widget.suffix}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: widget.homeAccent ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
              const SizedBox(width: 8),
              // Progress
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: SizedBox(
                    height: 8,
                    child: AnimatedBuilder(
                      animation: _animation,
                      builder: (context, child) {
                        return Row(
                          children: [
                            Flexible(
                              flex: (homePct * 100).round(),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: widget.homeAccent
                                      ? AppColors.footballAccent
                                      : AppColors.surfaceLighter,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            Flexible(
                              flex: (awayPct * 100).round(),
                              child: Container(
                                color: AppColors.surfaceLighter,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Away value
              SizedBox(
                width: 36,
                child: Text(
                  '${widget.awayValue}${widget.suffix}',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: !widget.homeAccent ? AppColors.textPrimary : AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Side-by-side comparison bar for the Stats tab.
class _ComparisonBar extends StatefulWidget {
  const _ComparisonBar({
    required this.stat,
    required this.accentColor,
  });

  final _StatEntry stat;
  final Color accentColor;

  @override
  State<_ComparisonBar> createState() => _ComparisonBarState();
}

class _ComparisonBarState extends State<_ComparisonBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.stat.homeValue + widget.stat.awayValue;
    final homePct = total > 0 ? widget.stat.homeValue / total : 0.5;
    final homeWins = widget.stat.homeValue >= widget.stat.awayValue;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          // Label centered
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              widget.stat.label,
              style: AppTextStyles.caption,
            ),
          ),
          // Values + bars
          Row(
            children: [
              // Home value
              SizedBox(
                width: 40,
                child: Text(
                  '${widget.stat.homeValue}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: homeWins ? widget.accentColor : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              // Bars
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: AnimatedBuilder(
                    animation: _animation,
                    builder: (context, child) {
                      return Row(
                        children: [
                          // Home bar (grows from left)
                          Expanded(
                            flex: (homePct * 100).round().clamp(1, 99),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerRight,
                              widthFactor: _animation.value,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: homeWins ? widget.accentColor : AppColors.surfaceLighter,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(3),
                                    bottomLeft: Radius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          // Away bar (grows from right)
                          Expanded(
                            flex: ((1 - homePct) * 100).round().clamp(1, 99),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: _animation.value,
                              child: Container(
                                height: 6,
                                decoration: BoxDecoration(
                                  color: !homeWins ? widget.accentColor : AppColors.surfaceLighter,
                                  borderRadius: const BorderRadius.only(
                                    topRight: Radius.circular(3),
                                    bottomRight: Radius.circular(3),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              // Away value
              SizedBox(
                width: 40,
                child: Text(
                  '${widget.stat.awayValue}',
                  style: AppTextStyles.labelLarge.copyWith(
                    color: !homeWins ? widget.accentColor : AppColors.textSecondary,
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Score breakdown table showing period-by-period scores.
class _ScoreBreakdown extends StatelessWidget {
  const _ScoreBreakdown({required this.match});

  final Match match;

  @override
  Widget build(BuildContext context) {
    final homeDetails = match.homeScoreDetails ?? {};
    final awayDetails = match.awayScoreDetails ?? {};
    final periods = homeDetails.keys.toList();

    if (periods.isEmpty) return const SizedBox.shrink();

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header
          Row(
            children: [
              Expanded(
                child: Text(
                  match.homeTeam.displayName,
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              ...periods.map((p) => Expanded(
                    child: Text(
                      p,
                      style: AppTextStyles.labelSmall.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textTertiary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )),
              Expanded(
                child: Text(
                  'Total',
                  style: AppTextStyles.labelSmall.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const Divider(height: 20, color: AppColors.divider),
          // Home row
          Row(
            children: [
              Expanded(
                child: Text(
                  match.homeTeam.shortName ?? match.homeTeam.name,
                  style: AppTextStyles.labelMedium,
                ),
              ),
              ...periods.map((p) => Expanded(
                    child: Text(
                      '${homeDetails[p] ?? 0}',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  )),
              Expanded(
                child: Text(
                  '${match.homeScore ?? 0}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Away row
          Row(
            children: [
              Expanded(
                child: Text(
                  match.awayTeam.shortName ?? match.awayTeam.name,
                  style: AppTextStyles.labelMedium,
                ),
              ),
              ...periods.map((p) => Expanded(
                    child: Text(
                      '${awayDetails[p] ?? 0}',
                      style: AppTextStyles.bodyMedium,
                      textAlign: TextAlign.center,
                    ),
                  )),
              Expanded(
                child: Text(
                  '${match.awayScore ?? 0}',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// WATCH TOGETHER WIDGET
// ══════════════════════════════════════════════════════════════════════

class _WatchTogetherWidget extends StatelessWidget {
  const _WatchTogetherWidget({required this.accentColor});

  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: accentColor.withValues(alpha: 0.3)),
            ),
            child: Icon(
              Icons.people_outline,
              size: 22,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Watch Together',
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Watch with friends in real-time',
                  style: AppTextStyles.caption,
                ),
              ],
            ),
          ),
          const Icon(
            Icons.chevron_right,
            size: 20,
            color: AppColors.textTertiary,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 400.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 400.ms, duration: 400.ms);
  }
}

// ══════════════════════════════════════════════════════════════════════
// QUICK PREDICTION WIDGET
// ══════════════════════════════════════════════════════════════════════

class _QuickPredictionWidget extends StatefulWidget {
  const _QuickPredictionWidget({
    required this.match,
    required this.accentColor,
  });

  final Match match;
  final Color accentColor;

  @override
  State<_QuickPredictionWidget> createState() => _QuickPredictionWidgetState();
}

class _QuickPredictionWidgetState extends State<_QuickPredictionWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _homeAnim;
  late Animation<double> _awayAnim;

  // Mock vote percentages
  double _homePct = 0.62;
  double _awayPct = 0.38;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _homeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _awayAnim = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    // Start animation after a brief delay
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Row(
            children: [
              const Icon(Icons.emoji_events_outlined, size: 18, color: AppColors.warningAmber),
              const SizedBox(width: 8),
              Text(
                'Quick Prediction',
                style: AppTextStyles.labelLarge.copyWith(fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Text(
                '${(_homePct * 100).round().toString()}K votes',
                style: AppTextStyles.caption,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Who will win?',
            style: AppTextStyles.bodySmall,
          ),
          const SizedBox(height: 14),

          // Home team vote
          _buildVoteOption(
            teamName: widget.match.homeTeam.displayName,
            pct: _homePct,
            anim: _homeAnim,
            accentColor: widget.accentColor,
            isHome: true,
          ),
          const SizedBox(height: 10),

          // Away team vote
          _buildVoteOption(
            teamName: widget.match.awayTeam.displayName,
            pct: _awayPct,
            anim: _awayAnim,
            accentColor: widget.accentColor,
            isHome: false,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 500.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 500.ms, duration: 400.ms);
  }

  Widget _buildVoteOption({
    required String teamName,
    required double pct,
    required Animation<double> anim,
    required Color accentColor,
    required bool isHome,
  }) {
    return GestureDetector(
      onTap: () {
        // Non-functional but visually responsive
        setState(() {
          if (isHome) {
            _homePct = (_homePct + 0.01).clamp(0.0, 1.0);
            _awayPct = 1.0 - _homePct;
          } else {
            _awayPct = (_awayPct + 0.01).clamp(0.0, 1.0);
            _homePct = 1.0 - _awayPct;
          }
        });
      },
      child: AnimatedBuilder(
        animation: anim,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(
              children: [
                // Background progress
                Container(
                  height: 48,
                  color: AppColors.surfaceLight,
                ),
                // Animated fill
                FractionallySizedBox(
                  widthFactor: anim.value * pct,
                  alignment: Alignment.centerLeft,
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: (pct > 0.5 ? accentColor : AppColors.surfaceLighter).withValues(alpha: 0.25),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                // Content
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Text(
                          teamName,
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${(pct * 100).round()}%',
                          style: AppTextStyles.labelMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: pct > 0.5 ? accentColor : AppColors.textSecondary,
                          ),
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
    );
  }
}


