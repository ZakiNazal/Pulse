import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../shared/providers/match_provider.dart';
import '../../../shared/widgets/match_card.dart';
import '../../../shared/widgets/skeleton_loader.dart';
import '../../../shared/widgets/sport_selector.dart';
import '../../../core/models/match.dart';
import 'widgets/hot_match_card.dart';

/// The main Home screen — the core experience of the Pulse app.
///
/// Presents a time-based greeting, sport filter, hot matches carousel,
/// and a tabbed match list (Live / Upcoming / Finished) with pull-to-refresh,
/// skeleton loading, and empty states.
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final RefreshController _refreshController = RefreshController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _refreshController.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning ☀️';
    if (hour < 17) return 'Good Afternoon 🌤️';
    return 'Good Evening 🌙';
  }

  String _formattedDate() {
    final now = DateTime.now();
    return DateFormat('EEEE, MMMM d, y').format(now);
  }

  List<Match> _matchesForTab(int index, MatchState state) {
    switch (index) {
      case 0:
        return state.liveMatches;
      case 1:
        return state.upcomingMatches;
      case 2:
        return state.finishedMatches;
      default:
        return [];
    }
  }

  String _emptyMessage(int index) {
    switch (index) {
      case 0:
        return 'No live matches right now';
      case 1:
        return 'No upcoming matches scheduled';
      case 2:
        return 'No finished matches yet';
      default:
        return '';
    }
  }

  IconData _emptyIcon(int index) {
    switch (index) {
      case 0:
        return Icons.sports_soccer;
      case 1:
        return Icons.event_available;
      case 2:
        return Icons.check_circle_outline;
      default:
        return Icons.sports;
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(matchNotifierProvider.notifier).refresh();
    _refreshController.refreshCompleted();
  }

  // ── Build ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(matchNotifierProvider);
    final notifier = ref.read(matchNotifierProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar ─────────────────────────────────────────
            _buildTopBar(),

            // ── Date ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                _formattedDate(),
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 16),

            // ── Sport Selector ──────────────────────────────────
            SportSelector(
              selected: state.selectedSport,
              onSelected: (sport) =>
                  notifier.filterBySport(sport),
            ),

            const SizedBox(height: 20),

            // ── Hot Matches (if any) ───────────────────────────
            if (state.hotMatches.isNotEmpty) _buildHotMatches(state),

            // ── Tab bar ─────────────────────────────────────────
            _buildTabBar(state),

            // ── Tab content ─────────────────────────────────────
            Expanded(child: _buildTabContent(state)),
          ],
        ),
      ),
    );
  }

  // ── Top Bar ────────────────────────────────────────────────────────

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          // Greeting
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _greeting(),
                  style: AppTextStyles.headingLarge.copyWith(fontSize: 24),
                )
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOutCubic),
                const SizedBox(height: 2),
                Text(
                  'Stay in the game',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 100.ms, duration: 400.ms)
                    .slideY(begin: -0.1, end: 0, duration: 400.ms),
              ],
            ),
          ),

          // Notification bell
          _buildIconButton(
            icon: Iconsax.notification,
            onTap: () {
              // TODO: Navigate to notifications
            },
          ),
          const SizedBox(width: 8),

          // Search
          _buildIconButton(
            icon: Iconsax.searchNormal,
            onTap: () => context.go('/search'),
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder, width: 0.5),
        ),
        child: Icon(icon, size: 20, color: AppColors.textSecondary),
      ),
    );
  }

  // ── Hot Matches ────────────────────────────────────────────────────

  Widget _buildHotMatches(MatchState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(
                '🔥 Hot Matches',
                style: AppTextStyles.headingSmall.copyWith(fontSize: 18),
              )
                  .animate()
                  .fadeIn(delay: 200.ms, duration: 400.ms)
                  .slideX(begin: -0.1, end: 0, duration: 400.ms),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  // Switch to live tab
                  _tabController.animateTo(0);
                },
                child: Text(
                  'See all',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.footballAccent,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(left: 20),
            itemCount: state.hotMatches.length,
            itemBuilder: (context, index) {
              return HotMatchCard(match: state.hotMatches[index]);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  // ── Tab Bar ────────────────────────────────────────────────────────

  Widget _buildTabBar(MatchState state) {
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
          _buildTab('LIVE', state.liveMatchCount, isLive: true),
          _buildTab('UPCOMING', null),
          _buildTab('FINISHED', null),
        ],
      ),
    );
  }

  Widget _buildTab(String label, int? count, {bool isLive = false}) {
    return Tab(
      height: 38,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLive) ...[
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
                  end: const Offset(1.3, 1.3),
                  duration: 800.ms,
                )
                .fade(begin: 1.0, end: 0.3, duration: 800.ms),
            const SizedBox(width: 6),
          ],
          Text(label),
          if (count != null && count > 0) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: isLive
                    ? AppColors.liveRed.withValues(alpha: 0.15)
                    : AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$count',
                style: AppTextStyles.labelSmall.copyWith(
                  color: isLive ? AppColors.liveRed : AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Tab Content ────────────────────────────────────────────────────

  Widget _buildTabContent(MatchState state) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildMatchList(0, state),
        _buildMatchList(1, state),
        _buildMatchList(2, state),
      ],
    );
  }

  Widget _buildMatchList(int tabIndex, MatchState state) {
    if (state.isLoading) {
      return _buildLoadingState();
    }

    final matches = _matchesForTab(tabIndex, state);

    if (matches.isEmpty) {
      return _buildEmptyState(tabIndex);
    }

    return SmartRefresher(
      controller: _refreshController,
      enablePullDown: true,
      onRefresh: _onRefresh,
      header: ClassicHeader(
        height: 60,
        textStyle: AppTextStyles.labelSmall,
        idleIcon: const Icon(Icons.arrow_downward, color: AppColors.textTertiary, size: 18),
        releaseIcon: const Icon(Icons.refresh, color: AppColors.textSecondary, size: 20),
      ),
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 12, bottom: 90),
        physics: const BouncingScrollPhysics(),
        itemCount: matches.length,
        itemBuilder: (context, index) {
          return MatchCard(
            match: matches[index],
            key: ValueKey(matches[index].id),
          ).animate().fadeIn(
                delay: Duration(milliseconds: 50 * index),
                duration: 350.ms,
              ).slideY(
                begin: 0.08,
                end: 0,
                delay: Duration(milliseconds: 50 * index),
                duration: 350.ms,
                curve: Curves.easeOutCubic,
              );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 12, bottom: 90),
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 6,
      itemBuilder: (context, index) => const MatchCardSkeleton(),
    );
  }

  Widget _buildEmptyState(int tabIndex) {
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
                _emptyIcon(tabIndex),
                size: 36,
                color: AppColors.textTertiary,
              ),
            )
                .animate()
                .scale(begin: const Offset(0.5, 0.5), end: const Offset(1, 1), duration: 500.ms, curve: Curves.elasticOut),
            const SizedBox(height: 20),
            Text(
              _emptyMessage(tabIndex),
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Check back later or try another sport',
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

  }

// ── Iconsax extension (class-like access to iconsax icons) ────────────
//
// This section uses the iconsax package which exports named IconData
// constants at the top level, e.g. `Iconsax.home_2`.
// If the package API changes, update the references below accordingly.

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
}
