import 'dart:async';

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

// ── Iconsax extension (mirrors home_screen) ────────────────────────────

class Iconsax {
  static const IconData home_2 = Icons.home;
  static const IconData compass = Icons.explore;
  static const IconData heart = Icons.favorite_border;
  static const IconData user = Icons.person_outline;
  static const IconData notification = Icons.notifications_none_outlined;
  static const IconData searchNormal = Icons.search;
  static const IconData arrowLeft = Icons.arrow_back_ios_new;
  static const IconData closeCircle = Icons.highlight_off;
  static const IconData clock = Icons.schedule;
  static const IconData trending = Icons.trending_up;
  static const IconData star = Icons.star_outline;
}

/// The Search screen — real-time search with debounced input.
///
/// Features auto-focused search field, grouped results (Matches, Teams,
/// Leagues), recent/trending searches, and animated list transitions.
class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounce;
  List<Match> _results = [];
  bool _isSearching = false;
  bool _hasSearched = false;

  // Mock recent searches
  final List<String> _recentSearches = [
    'Real Madrid',
    'Premier League',
    'NBA',
    'Lakers vs Warriors',
  ];

  // Mock trending searches
  final List<String> _trendingSearches = [
    'Champions League',
    'Manchester City',
    'LeBron James',
    'IPL 2026',
    'World Cup',
    'Formula 1',
    'Djokovic',
    'Valorant VCT',
  ];

  @override
  void initState() {
    super.initState();
    // Auto-focus the search field after the frame renders.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();

    if (query.trim().isEmpty) {
      setState(() {
        _results = [];
        _isSearching = false;
        _hasSearched = false;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query.trim());
    });
  }

  Future<void> _performSearch(String query) async {
    setState(() {
      _isSearching = true;
    });

    try {
      final service = ref.read(matchServiceProvider);
      final results = await service.searchAll(query);

      if (mounted) {
        setState(() {
          _results = results;
          _isSearching = false;
          _hasSearched = true;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _hasSearched = true;
        });
      }
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _results = [];
      _isSearching = false;
      _hasSearched = false;
    });
    _focusNode.requestFocus();
  }

  void _onSearchTap(String term) {
    _searchController.text = term;
    _performSearch(term);
  }

  void _removeRecentSearch(String term) {
    setState(() {
      _recentSearches.remove(term);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Search Bar ────────────────────────────────────────
            _buildSearchBar(),

            // ── Content ──────────────────────────────────────────
            Expanded(
              child: _hasSearched
                  ? _buildResults()
                  : _buildDefaultContent(),
            ),
          ],
        ),
      ),
    );
  }

  // ── Search Bar ──────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 12, 20, 8),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => context.go('/home'),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.glassBorder, width: 0.5),
              ),
              child: const Icon(
                Iconsax.arrowLeft,
                size: 20,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 10),
          // Search input
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: _focusNode.hasFocus
                      ? AppColors.footballAccent.withValues(alpha: 0.5)
                      : AppColors.glassBorder,
                  width: 0.5,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 14),
                  const Icon(
                    Iconsax.searchNormal,
                    size: 18,
                    color: AppColors.textTertiary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onQueryChanged,
                      style: AppTextStyles.bodyMedium,
                      cursorColor: AppColors.footballAccent,
                      decoration: const InputDecoration(
                        hintText: 'Search teams, players, leagues...',
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        isDense: true,
                        contentPadding: EdgeInsets.symmetric(vertical: 12),
                        hintStyle: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                  if (_searchController.text.isNotEmpty)
                    GestureDetector(
                      onTap: _clearSearch,
                      child: const Padding(
                        padding: EdgeInsets.only(right: 12),
                        child: Icon(
                          Iconsax.closeCircle,
                          size: 18,
                          color: AppColors.textTertiary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          )
              .animate()
              .fadeIn(duration: 300.ms)
              .slideX(begin: 0.1, end: 0, duration: 300.ms),
        ],
      ),
    );
  }

  // ── Default Content (recent + trending) ─────────────────────────────

  Widget _buildDefaultContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent Searches
          if (_recentSearches.isNotEmpty) ...[
            const SizedBox(height: 16),
            _buildSectionHeader(
              title: 'Recent Searches',
              icon: Iconsax.clock,
            ),
            const SizedBox(height: 12),
            ...List.generate(_recentSearches.length, (index) {
              return _buildRecentSearchItem(_recentSearches[index])
                  .animate()
                  .fadeIn(
                    delay: Duration(milliseconds: 100 + index * 50),
                    duration: 300.ms,
                  )
                  .slideY(
                    begin: 0.05,
                    end: 0,
                    delay: Duration(milliseconds: 100 + index * 50),
                    duration: 300.ms,
                  );
            }),
          ],

          // Trending Searches
          const SizedBox(height: 28),
          _buildSectionHeader(
            title: 'Trending',
            icon: Iconsax.trending,
          ),
          const SizedBox(height: 12),
          _buildTrendingChips(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader({required String title, required IconData icon}) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 50.ms, duration: 300.ms);
  }

  Widget _buildRecentSearchItem(String term) {
    return GestureDetector(
      onTap: () => _onSearchTap(term),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            const Icon(
              Iconsax.clock,
              size: 16,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                term,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => _removeRecentSearch(term),
              child: const Icon(
                Iconsax.closeCircle,
                size: 16,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrendingChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(_trendingSearches.length, (index) {
        final term = _trendingSearches[index];
        return GestureDetector(
          onTap: () => _onSearchTap(term),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppColors.glassBorder,
                width: 0.5,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Iconsax.trending,
                  size: 12,
                  color: AppColors.textTertiary,
                ),
                const SizedBox(width: 6),
                Text(
                  term,
                  style: AppTextStyles.labelMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        )
            .animate()
            .fadeIn(
              delay: Duration(milliseconds: 150 + index * 40),
              duration: 300.ms,
            )
            .scale(
              begin: const Offset(0.9, 0.9),
              end: const Offset(1.0, 1.0),
              delay: Duration(milliseconds: 150 + index * 40),
              duration: 300.ms,
              curve: Curves.easeOutBack,
            );
      }),
    );
  }

  // ── Search Results ──────────────────────────────────────────────────

  Widget _buildResults() {
    if (_isSearching) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 36,
              height: 36,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.footballAccent,
                backgroundColor: AppColors.surfaceLighter,
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .rotate(begin: 0, end: 1, duration: 1200.ms),
            const SizedBox(height: 16),
            Text(
              'Searching...',
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    if (_results.isEmpty && _hasSearched) {
      return _buildEmptyResults();
    }

    // Group results by category
    final matchResults =
        _results.where((m) => true).toList(); // All are matches
    final teamNames = <String>{};
    final leagueNames = <String>{};

    for (final match in _results) {
      teamNames.add(match.homeTeam.name);
      teamNames.add(match.awayTeam.name);
      leagueNames.add(match.league.name);
    }

    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      children: [
        // Matches section
        if (matchResults.isNotEmpty) ...[
          const SizedBox(height: 16),
          _buildResultSectionHeader('Matches', matchResults.length),
          const SizedBox(height: 8),
          ...List.generate(matchResults.length, (index) {
            final match = matchResults[index];
            return _buildMatchResultItem(match)
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: index * 60),
                  duration: 350.ms,
                )
                .slideY(
                  begin: 0.06,
                  end: 0,
                  delay: Duration(milliseconds: index * 60),
                  duration: 350.ms,
                  curve: Curves.easeOutCubic,
                );
          }),
        ],

        // Teams section
        if (teamNames.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildResultSectionHeader('Teams', teamNames.length),
          const SizedBox(height: 8),
          ...List.generate(teamNames.length, (index) {
            return _buildGenericResultItem(
              name: teamNames.elementAt(index),
              subtitle: 'Team',
              icon: Icons.people_outline,
              onTap: () {},
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: index * 50 + 100),
                  duration: 350.ms,
                )
                .slideY(
                  begin: 0.06,
                  end: 0,
                  delay: Duration(milliseconds: index * 50 + 100),
                  duration: 350.ms,
                );
          }),
        ],

        // Leagues section
        if (leagueNames.isNotEmpty) ...[
          const SizedBox(height: 20),
          _buildResultSectionHeader('Leagues', leagueNames.length),
          const SizedBox(height: 8),
          ...List.generate(leagueNames.length, (index) {
            return _buildGenericResultItem(
              name: leagueNames.elementAt(index),
              subtitle: 'League',
              icon: Icons.emoji_events_outlined,
              onTap: () {},
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: index * 50 + 200),
                  duration: 350.ms,
                )
                .slideY(
                  begin: 0.06,
                  end: 0,
                  delay: Duration(milliseconds: index * 50 + 200),
                  duration: 350.ms,
                );
          }),
        ],

        const SizedBox(height: 40),
      ],
    );
  }

  Widget _buildResultSectionHeader(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.surfaceLighter,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$count',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMatchResultItem(Match match) {
    final accentColor = SportConfig.accentColor(match.sportType);

    return GestureDetector(
      onTap: () => context.go('/match/${match.id}'),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            // Sport emoji badge
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(
                match.sportType.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const SizedBox(width: 12),
            // Match info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${match.homeTeam.displayName} vs ${match.awayTeam.displayName}',
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${match.league.name} • ${match.league.country}',
                    style: AppTextStyles.labelSmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            // Status
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: match.isLive
                    ? AppColors.liveRed.withValues(alpha: 0.12)
                    : AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: match.isLive
                      ? AppColors.liveRed.withValues(alpha: 0.25)
                      : AppColors.divider,
                  width: 0.5,
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
          ],
        ),
      ),
    );
  }

  Widget _buildGenericResultItem({
    required String name,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.labelSmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_right,
              size: 18,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyResults() {
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
              child: const Icon(
                Iconsax.searchNormal,
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
              'No results found',
              style: AppTextStyles.headingSmall.copyWith(
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 400.ms),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
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
