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
import '../../shared/widgets/match_card.dart';

// ── Iconsax extension (mirrors home_screen) ────────────────────────────

class Iconsax {
  static const IconData home_2 = Icons.home;
  static const IconData compass = Icons.explore;
  static const IconData heart = Icons.favorite_border;
  static const IconData heartFilled = Icons.favorite;
  static const IconData user = Icons.person_outline;
  static const IconData searchNormal = Icons.search;
  static const IconData closeCircle = Icons.highlight_off;
  static const IconData trophy = Icons.emoji_events_outlined;
  static const IconData star = Icons.star_outline;
  static const IconData people = Icons.people_outline;
}

/// Mock data for favorited teams.
class _FavoriteTeam {
  const _FavoriteTeam({
    required this.id,
    required this.name,
    required this.shortName,
    required this.league,
    required this.sportType,
    this.logo,
  });

  final String id;
  final String name;
  final String shortName;
  final String league;
  final SportType sportType;
  final String? logo;
}

/// Mock data for favorited leagues.
class _FavoriteLeague {
  const _FavoriteLeague({
    required this.id,
    required this.name,
    required this.country,
    required this.sportType,
  });

  final String id;
  final String name;
  final String country;
  final SportType sportType;
}

/// The Favorites screen with tabbed content (Teams / Matches / Leagues).
///
/// Features glassmorphism cards, remove functionality, pull-to-refresh,
/// empty states, and staggered entrance animations.
class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Mock favorite teams
  List<_FavoriteTeam> _teams = const [
    _FavoriteTeam(
      id: 'mci',
      name: 'Manchester City',
      shortName: 'MAN CITY',
      league: 'Premier League',
      sportType: SportType.football,
      logo: 'assets/teams/mci.png',
    ),
    _FavoriteTeam(
      id: 'lakers',
      name: 'Los Angeles Lakers',
      shortName: 'LAKERS',
      league: 'NBA',
      sportType: SportType.basketball,
    ),
    _FavoriteTeam(
      id: 'bar',
      name: 'FC Barcelona',
      shortName: 'BARCELONA',
      league: 'La Liga',
      sportType: SportType.football,
      logo: 'assets/teams/bar.png',
    ),
    _FavoriteTeam(
      id: 'rma',
      name: 'Real Madrid',
      shortName: 'REAL MADRID',
      league: 'La Liga',
      sportType: SportType.football,
      logo: 'assets/teams/rma.png',
    ),
    _FavoriteTeam(
      id: 'csg',
      name: 'Chennai Super Kings',
      shortName: 'CSK',
      league: 'Indian Premier League',
      sportType: SportType.football,
    ),
  ];

  // Mock favorite leagues
  List<_FavoriteLeague> _leagues = const [
    _FavoriteLeague(
      id: 'pl',
      name: 'Premier League',
      country: 'England',
      sportType: SportType.football,
    ),
    _FavoriteLeague(
      id: 'ucl',
      name: 'UEFA Champions League',
      country: 'Europe',
      sportType: SportType.football,
    ),
    _FavoriteLeague(
      id: 'nba',
      name: 'NBA',
      country: 'USA',
      sportType: SportType.basketball,
    ),
    _FavoriteLeague(
      id: 'ipl',
      name: 'Indian Premier League',
      country: 'India',
      sportType: SportType.football,
    ),
  ];

  bool _isRefreshing = false;

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

  Future<void> _onRefresh() async {
    setState(() => _isRefreshing = true);
    // Simulate refresh
    await Future.delayed(const Duration(milliseconds: 800));
    await ref.read(matchNotifierProvider.notifier).refresh();
    if (mounted) {
      setState(() => _isRefreshing = false);
    }
  }

  void _removeTeam(String id) {
    setState(() {
      _teams = _teams.where((t) => t.id != id).toList();
    });
    _showRemovedSnackbar('Team removed from favorites');
  }

  void _removeLeague(String id) {
    setState(() {
      _leagues = _leagues.where((l) => l.id != id).toList();
    });
    _showRemovedSnackbar('League removed from favorites');
  }

  void _showRemovedSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.surfaceLight,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final matchState = ref.watch(matchNotifierProvider);
    // Mock: pick a couple of upcoming matches as "favorite" matches
    final favoriteMatches =
        matchState.upcomingMatches.take(2).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Header ────────────────────────────────────────────
            _buildHeader(),
            const SizedBox(height: 16),
            // ── Tabs ──────────────────────────────────────────────
            _buildTabBar(),
            const SizedBox(height: 16),
            // ── Tab Content ───────────────────────────────────────
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildTeamsTab(),
                  _buildMatchesTab(favoriteMatches),
                  _buildLeaguesTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Header ──────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          Text(
            'Favorites',
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
          // Total count badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.glassBorder, width: 0.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.heartFilled,
                  size: 14,
                  color: AppColors.errorRed,
                ),
                const SizedBox(width: 6),
                Text(
                  '${_teams.length + _leagues.length}',
                  style: AppTextStyles.labelMedium.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
        ],
      ),
    );
  }

  // ── Tab Bar ─────────────────────────────────────────────────────────

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
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
              color: AppColors.shadow.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelColor: AppColors.textPrimary,
        unselectedLabelColor: AppColors.textTertiary,
        labelStyle: AppTextStyles.labelLarge.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: AppTextStyles.labelMedium,
        labelPadding: EdgeInsets.zero,
        padding: EdgeInsets.zero,
        tabs: [
          const Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Icon(Iconsax.people, size: 16),
                 SizedBox(width: 6),
                Text('Teams'),
              ],
            ),
          ),
          const Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                 Icon(Icons.sports_soccer, size: 16),
                 SizedBox(width: 6),
                Text('Matches'),
              ],
            ),
          ),
          const Tab(
            height: 38,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Iconsax.trophy, size: 16),
                SizedBox(width: 6),
                Text('Leagues'),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 150.ms, duration: 400.ms);
  }

  // ── Teams Tab ───────────────────────────────────────────────────────

  Widget _buildTeamsTab() {
    if (_isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.footballAccent,
        ),
      );
    }

    if (_teams.isEmpty) {
      return _buildEmptyState(
        icon: Iconsax.heart,
        title: 'No favorite teams yet',
        subtitle: 'Tap the heart icon on any team to add them here',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.footballAccent,
      backgroundColor: AppColors.surfaceLight,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: _teams.length,
        itemBuilder: (context, index) {
          final team = _teams[index];
          final accentColor = SportConfig.accentColor(team.sportType);

          return _buildTeamCard(team, accentColor, index);
        },
      ),
    );
  }

  Widget _buildTeamCard(_FavoriteTeam team, Color accentColor, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Sport accent bar
          Container(
            width: 4,
            height: 48,
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
          // Team logo / initials
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: team.logo != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      team.logo!,
                      width: 28,
                      height: 28,
                      errorBuilder: (_, __, ___) => Text(
                        _getInitials(team.shortName),
                        style: AppTextStyles.labelMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: accentColor,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                : Text(
                    team.sportType.emoji,
                    style: const TextStyle(fontSize: 22),
                  ),
          ),
          const SizedBox(width: 14),
          // Team info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  team.name,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: accentColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        team.sportType.emoji,
                        style: const TextStyle(fontSize: 9),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      team.league,
                      style: AppTextStyles.labelSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          GestureDetector(
            onTap: () => _removeTeam(team.id),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.closeCircle,
                size: 18,
                color: AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + index * 60),
          duration: 350.ms,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          delay: Duration(milliseconds: 100 + index * 60),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ── Matches Tab ─────────────────────────────────────────────────────

  Widget _buildMatchesTab(List<Match> favoriteMatches) {
    if (_isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.footballAccent,
        ),
      );
    }

    if (favoriteMatches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.sports_soccer,
        title: 'No favorite matches yet',
        subtitle: 'Tap the heart icon on any match to save it here',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.footballAccent,
      backgroundColor: AppColors.surfaceLight,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: favoriteMatches.length,
        itemBuilder: (context, index) {
          return MatchCard(
            match: favoriteMatches[index],
            key: ValueKey(favoriteMatches[index].id),
            index: index,
            onTap: () =>
                context.go('/match/${favoriteMatches[index].id}'),
          );
        },
      ),
    );
  }

  // ── Leagues Tab ─────────────────────────────────────────────────────

  Widget _buildLeaguesTab() {
    if (_isRefreshing) {
      return const Center(
        child: CircularProgressIndicator(
          strokeWidth: 3,
          color: AppColors.footballAccent,
        ),
      );
    }

    if (_leagues.isEmpty) {
      return _buildEmptyState(
        icon: Iconsax.trophy,
        title: 'No favorite leagues yet',
        subtitle: 'Follow leagues to stay updated on all their matches',
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      color: AppColors.footballAccent,
      backgroundColor: AppColors.surfaceLight,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(top: 16, bottom: 100),
        itemCount: _leagues.length,
        itemBuilder: (context, index) {
          final league = _leagues[index];
          final accentColor = SportConfig.accentColor(league.sportType);

          return _buildLeagueCard(league, accentColor, index);
        },
      ),
    );
  }

  Widget _buildLeagueCard(
      _FavoriteLeague league, Color accentColor, int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          // Sport accent bar
          Container(
            width: 4,
            height: 48,
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
          // League emoji
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              league.sportType.emoji,
              style: const TextStyle(fontSize: 22),
            ),
          ),
          const SizedBox(width: 14),
          // League info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  league.name,
                  style: AppTextStyles.labelLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 12,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      league.country,
                      style: AppTextStyles.labelSmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Remove button
          GestureDetector(
            onTap: () => _removeLeague(league.id),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.errorRed.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Iconsax.closeCircle,
                size: 18,
                color: AppColors.errorRed,
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
          delay: Duration(milliseconds: 100 + index * 60),
          duration: 350.ms,
        )
        .slideY(
          begin: 0.08,
          end: 0,
          delay: Duration(milliseconds: 100 + index * 60),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ── Empty State ─────────────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.divider),
              ),
              child: Icon(
                icon,
                size: 36,
                color: AppColors.textTertiary,
              ),
            )
                .animate()
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1, 1),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                ),
            const SizedBox(height: 20),
            Text(
              title,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: AppTextStyles.bodySmall,
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }

  // ── Bottom Navigation ───────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Iconsax.home_2,
            label: 'Home',
            isSelected: false,
            onTap: () => context.go('/home'),
          ),
          _buildNavItem(
            icon: Iconsax.compass,
            label: 'Explore',
            isSelected: false,
            onTap: () => context.go('/explore'),
          ),
          _buildNavItem(
            icon: Iconsax.heart,
            label: 'Favorites',
            isSelected: true,
            onTap: () {},
          ),
          _buildNavItem(
            icon: Iconsax.user,
            label: 'Profile',
            isSelected: false,
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
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

  String _getInitials(String name) {
    final parts = name
        .replaceAll(RegExp(r'[^a-zA-Z\s]'), '')
        .split(' ')
        .where((w) => w.isNotEmpty)
        .toList();
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length >= 2 ? 2 : 1).toUpperCase();
  }
}
