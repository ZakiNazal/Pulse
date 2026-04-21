import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/sport_config.dart';
import '../../core/models/match.dart';
import '../../core/models/sport_type.dart';
import '../../core/models/league.dart';
import '../../shared/providers/match_provider.dart';
import '../../shared/widgets/match_card.dart';

// ── Iconsax extension (mirrors home_screen) ────────────────────────────

class Iconsax {
  static const IconData home_2 = Icons.home;
  static const IconData compass = Icons.explore;
  static const IconData heart = Icons.favorite_border;
  static const IconData user = Icons.person_outline;
  static const IconData notification = Icons.notifications_none_outlined;
  static const IconData searchNormal = Icons.search;
  static const IconData share = Icons.share;
  static const IconData arrowLeft = Icons.arrow_back_ios_new;
  static const IconData people = Icons.people_outline;
  static const IconData trophy = Icons.emoji_events_outlined;
  static const IconData location = Icons.location_on_outlined;
  static const IconData calendar = Icons.calendar_today_outlined;
  static const IconData whistle = Icons.sports;
  static const IconData clock = Icons.schedule;
  static const IconData arrowRight = Icons.arrow_forward_ios;
  static const IconData fire = Icons.local_fire_department;
}

/// The Explore/Discover screen for the Pulse app.
///
/// Presents trending matches, popular leagues, sports categories, and
/// personalized suggestions — all with glassmorphism cards and staggered
/// entrance animations.
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final matchState = ref.watch(matchNotifierProvider);
    final allMatches = matchState.allMatches;

    // Build a flat list of popular leagues from SportConfig
    final popularLeagues = <_LeagueCardData>[];
    for (final sport in SportType.values) {
      final leagues = SportConfig.popularLeagues(sport);
      for (final league in leagues) {
        popularLeagues.add(_LeagueCardData(
          league: league,
          sportType: sport,
          matchCount: allMatches
              .where((m) => m.league.id == league.id)
              .length,
        ));
      }
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── AppBar ───────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildAppBar(context),
            ),

            // ── Trending Now ────────────────────────────────────────
            if (matchState.hotMatches.isNotEmpty)
              SliverToBoxAdapter(
                child: _buildTrendingSection(matchState.hotMatches),
              ),

            // ── Popular Leagues ─────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildPopularLeaguesSection(popularLeagues, context),
            ),

            // ── Sports ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSportsSection(allMatches),
            ),

            // ── Suggested For You ───────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSuggestedSection(allMatches),
            ),

            // ── Bottom spacing ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  // ── AppBar ──────────────────────────────────────────────────────────

  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(
            'Explore',
            style: AppTextStyles.headingLarge,
          )
              .animate()
              .fadeIn(duration: 400.ms)
              .slideY(
                begin: -0.2,
                end: 0,
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              ),
          const Spacer(),
          GestureDetector(
            onTap: () => context.go('/search'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: const Icon(Iconsax.searchNormal, size: 20, color: AppColors.textSecondary),
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        ],
      ),
    );
  }

  // ── Trending Now ────────────────────────────────────────────────────

  Widget _buildTrendingSection(List<Match> hotMatches) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Trending Now',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 18),
              )
                  .animate()
                  .fadeIn(delay: 150.ms, duration: 400.ms)
                  .slideX(begin: -0.1, end: 0, duration: 400.ms),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.liveRed.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.liveRed.withValues(alpha: 0.25),
                    width: 0.5,
                  ),
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
                    )
                        .animate(onPlay: (c) => c.repeat())
                        .scale(
                          begin: const Offset(1.0, 1.0),
                          end: const Offset(1.4, 1.4),
                          duration: 800.ms,
                        )
                        .fade(begin: 1.0, end: 0.3, duration: 800.ms),
                    const SizedBox(width: 6),
                    Text(
                      '${hotMatches.length} live',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.liveRed,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: hotMatches.length,
            itemBuilder: (context, index) {
              final match = hotMatches[index];
              final accentColor = SportConfig.accentColor(match.sportType);

              return GestureDetector(
                onTap: () => context.go('/match/${match.id}'),
                child: Container(
                  width: 220,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: accentColor.withValues(alpha: 0.5),
                      width: 1.0,
                    ),
                    color: AppColors.surface,
                    boxShadow: [
                      BoxShadow(
                        color: accentColor.withValues(alpha: 0.08),
                        blurRadius: 16,
                        spreadRadius: 0,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      // Glass tint
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            color: AppColors.glassBackground,
                          ),
                        ),
                      ),
                      // Sport accent bar on left
                      Positioned(
                        left: 0,
                        top: 0,
                        bottom: 0,
                        child: Container(
                          width: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                accentColor,
                                accentColor.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Content
                      Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // League + sport
                            Row(
                              children: [
                                Container(
                                  width: 22,
                                  height: 22,
                                  decoration: BoxDecoration(
                                    color: accentColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    match.sportType.emoji,
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    match.league.name,
                                    style: AppTextStyles.labelSmall.copyWith(
                                      color: AppColors.textSecondary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            // Teams
                            Text(
                              match.homeTeam.displayName,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Center(
                              child: Text(
                                'vs',
                                style: AppTextStyles.bodySmall.copyWith(
                                  color: AppColors.textTertiary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              match.awayTeam.displayName,
                              style: AppTextStyles.labelLarge.copyWith(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.right,
                            ),
                            const Spacer(),
                            // Footer
                            Row(
                              children: [
                                Text(
                                  match.formattedElapsedTime,
                                  style: AppTextStyles.labelSmall.copyWith(
                                    color: AppColors.liveRed,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                if (match.homeScore != null &&
                                    match.awayScore != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: accentColor.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${match.homeScore} - ${match.awayScore}',
                                      style: AppTextStyles.labelMedium.copyWith(
                                        color: accentColor,
                                        fontWeight: FontWeight.w700,
                                      ),
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
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 100 + index * 80),
                    duration: 400.ms,
                  )
                  .slideX(
                    begin: 0.12,
                    end: 0,
                    delay: Duration(milliseconds: 100 + index * 80),
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Popular Leagues ─────────────────────────────────────────────────

  Widget _buildPopularLeaguesSection(
      List<_LeagueCardData> leagues, BuildContext context) {
    // Show top 6 leagues
    final displayLeagues = leagues.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Popular Leagues',
            style: AppTextStyles.headingSmall.copyWith(fontSize: 18),
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 1.55,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: displayLeagues.length,
            itemBuilder: (context, index) {
              final data = displayLeagues[index];
              final accentColor = SportConfig.accentColor(data.sportType);

              return GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Navigate to ${data.league.name}'),
                      backgroundColor: AppColors.surfaceLight,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: const BorderSide(
                          color: AppColors.divider,
                          width: 0.5,
                        ),
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.glassBorder,
                      width: 0.5,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Emoji + country
                      Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              data.sportType.emoji,
                              style: const TextStyle(fontSize: 18),
                            ),
                          ),
                          const Spacer(),
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
                            alignment: Alignment.center,
                            child: Text(
                              _countryInitials(data.league.country),
                              style: AppTextStyles.labelSmall
                                  .copyWith(fontSize: 7),
                            ),
                          ),
                        ],
                      ),
                      // League name
                      Text(
                        data.league.name,
                        style: AppTextStyles.labelLarge.copyWith(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Match count
                      Row(
                        children: [
                          const Icon(
                            Iconsax.trophy,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${data.matchCount} matches',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 200 + index * 60),
                    duration: 400.ms,
                  )
                  .scale(
                    begin: const Offset(0.95, 0.95),
                    end: const Offset(1.0, 1.0),
                    delay: Duration(milliseconds: 200 + index * 60),
                    duration: 400.ms,
                    curve: Curves.easeOutBack,
                  );
            },
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ── Sports ──────────────────────────────────────────────────────────

  Widget _buildSportsSection(List<Match> allMatches) {
    const sports = SportType.values;
    final descriptions = {
      SportType.football: 'Global leagues & cups',
      SportType.basketball: 'NBA, EuroLeague & more',
      SportType.americanFootball: 'NFL, NCAA & CFL',
      SportType.f1: 'Formula 1 & MotoGP',
      SportType.mma: 'UFC, Bellator & ONE',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Sports',
            style: AppTextStyles.headingSmall.copyWith(fontSize: 18),
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms)
              .slideX(begin: -0.1, end: 0, duration: 400.ms),
        ),
        const SizedBox(height: 12),
        ...List.generate(sports.length, (index) {
          final sport = sports[index];
          final accentColor = SportConfig.accentColor(sport);
          final liveCount = allMatches
              .where((m) => m.sportType == sport && m.isLive)
              .length;

          return GestureDetector(
            onTap: () {
              // Filter by sport
            },
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 10),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.glassBorder,
                  width: 0.5,
                ),
              ),
              clipBehavior: Clip.antiAlias,
              child: Row(
                children: [
                  // Accent gradient bar on left
                  Container(
                    width: 4,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          accentColor,
                          accentColor.withValues(alpha: 0.3),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Sport emoji
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      sport.emoji,
                      style: const TextStyle(fontSize: 20),
                    ),
                  ),
                  const SizedBox(width: 14),
                  // Name + description
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          sport.displayName,
                          style: AppTextStyles.labelLarge.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          descriptions[sport] ?? '',
                          style: AppTextStyles.labelSmall,
                        ),
                      ],
                    ),
                  ),
                  // Live count badge
                  if (liveCount > 0)
                    Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.liveRed.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppColors.liveRed.withValues(alpha: 0.25),
                          width: 0.5,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 5,
                            height: 5,
                            decoration: const BoxDecoration(
                              color: AppColors.liveRed,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$liveCount live',
                            style: AppTextStyles.labelSmall.copyWith(
                              color: AppColors.liveRed,
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Icon(
                      Iconsax.arrowRight,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(
                delay: Duration(milliseconds: 300 + index * 60),
                duration: 400.ms,
              )
              .slideX(
                begin: 0.08,
                end: 0,
                delay: Duration(milliseconds: 300 + index * 60),
                duration: 400.ms,
                curve: Curves.easeOutCubic,
              );
        }),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Suggested For You ───────────────────────────────────────────────

  Widget _buildSuggestedSection(List<Match> allMatches) {
    // Pick upcoming matches as suggestions (mock "favorites" based)
    final suggestions = allMatches
        .where((m) => m.isUpcoming)
        .take(3)
        .toList();

    if (suggestions.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                'Suggested For You',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 18),
              )
                  .animate()
                  .fadeIn(delay: 500.ms, duration: 400.ms)
                  .slideX(begin: -0.1, end: 0, duration: 400.ms),
              const Spacer(),
              Text(
                'Based on favorites',
                style: AppTextStyles.labelSmall,
              ).animate().fadeIn(delay: 600.ms, duration: 400.ms),
            ],
          ),
        ),
        const SizedBox(height: 12),
        ...List.generate(suggestions.length, (index) {
          return MatchCard(
            match: suggestions[index],
            key: ValueKey(suggestions[index].id),
            index: index,
          );
        }),
      ],
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final accentColor =
        isSelected ? AppColors.footballAccent : AppColors.textTertiary;
    final iconColor =
        isSelected ? AppColors.footballAccent : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.footballAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: accentColor,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────

  String _countryInitials(String country) {
    final parts =
        country.replaceAll(RegExp(r'[^a-zA-Z\s]'), '').split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return country.substring(0, 2).toUpperCase();
  }
}

/// Lightweight data holder for league grid cards.
class _LeagueCardData {
  const _LeagueCardData({
    required this.league,
    required this.sportType,
    required this.matchCount,
  });

  final League league;
  final SportType sportType;
  final int matchCount;
}


