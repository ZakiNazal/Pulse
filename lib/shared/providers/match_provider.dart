import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/match.dart';
import '../../core/models/sport_type.dart';
import '../../core/services/match_service.dart';

// ── State ────────────────────────────────────────────────────────────

@immutable
class MatchState {
  const MatchState({
    this.allMatches = const [],
    this.selectedSport,
    this.isLoading = true,
    this.errorMessage,
  });

  final List<Match> allMatches;
  final SportType? selectedSport;
  final bool isLoading;
  final String? errorMessage;

  MatchState copyWith({
    List<Match>? allMatches,
    SportType? selectedSport,
    bool? isLoading,
    String? errorMessage,
  }) {
    return MatchState(
      allMatches: allMatches ?? this.allMatches,
      selectedSport: selectedSport ?? this.selectedSport,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  List<Match> get filteredMatches {
    if (selectedSport == null) return allMatches;
    return allMatches.where((m) => m.sportType == selectedSport).toList();
  }

  List<Match> get liveMatches =>
      filteredMatches.where((m) => m.isLive).toList();

  List<Match> get upcomingMatches =>
      filteredMatches.where((m) => m.isUpcoming).toList();

  List<Match> get finishedMatches =>
      filteredMatches.where((m) => m.isFinished).toList();

  List<Match> get hotMatches =>
      allMatches.where((m) => m.isHot && m.isLive).toList();

  int get liveMatchCount => liveMatches.length;

  Match? getMatchById(String id) {
    try {
      return allMatches.firstWhere((m) => m.id == id);
    } catch (_) {
      return null;
    }
  }
}

// ── Providers ─────────────────────────────────────────────────────────

/// Provides the singleton [MatchService].
final matchServiceProvider = Provider<MatchService>((ref) {
  return MatchService.instance;
});

/// Provides the [MatchNotifier] which manages all match state.
final matchNotifierProvider = NotifierProvider<MatchNotifier, MatchState>(() {
  return MatchNotifier();
});

// ── Notifier ──────────────────────────────────────────────────────────

/// Manages the state of matches for the home screen and any other consumer.
///
/// Responsibilities:
/// - Load matches from [MatchService]
/// - Filter by [SportType] (null = all sports)
/// - Categorise by [MatchStatus] (live / upcoming / finished)
/// - Simulate live score updates for demo purposes
class MatchNotifier extends Notifier<MatchState> {
  MatchNotifier();

  final _random = Random();
  Timer? _updateTimer;

  @override
  MatchState build() {
    // Don't load matches immediately - defer to avoid issues during navigation
    Future.microtask(() {
      final service = ref.read(matchServiceProvider);
      _loadMatches(service);
    });
    return const MatchState();
  }

  Future<void> _loadMatches(MatchService service) async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      final matches = await service.getMatches(forceRefresh: false);
      state = state.copyWith(
        allMatches: matches,
        isLoading: false,
      );
      _startLiveUpdates();
    } catch (e) {
      state = state.copyWith(
        errorMessage: 'Failed to load matches. Pull down to retry.',
        isLoading: false,
      );
    }
  }

  Future<void> refresh() async {
    _updateTimer?.cancel();
    final service = ref.read(matchServiceProvider);
    service.invalidateCache();
    await _loadMatches(service);
  }

  void filterBySport(SportType? sport) {
    state = state.copyWith(selectedSport: sport);
  }

  void _startLiveUpdates() {
    _updateTimer?.cancel();
    _updateTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _simulateLiveUpdates();
    });
  }

  void _simulateLiveUpdates() {
    if (state.allMatches.isEmpty) return;
    
    final liveIndices = <int>[];
    for (var i = 0; i < state.allMatches.length; i++) {
      if (state.allMatches[i].isLive) liveIndices.add(i);
    }
    if (liveIndices.isEmpty) return;
    
    final updateCount = _random.nextInt(2) + 1;
    final updated = List<Match>.from(state.allMatches);
    
    for (var i = 0; i < updateCount && liveIndices.isNotEmpty; i++) {
      final idx = liveIndices.removeAt(_random.nextInt(liveIndices.length));
      final match = updated[idx];
      final newElapsed = (match.elapsedMinutes ?? 0) + 1;
      final newHomeScore = match.homeScore != null && _random.nextDouble() < 0.3
          ? match.homeScore! + 1
          : match.homeScore;
      final newAwayScore = match.awayScore != null && _random.nextDouble() < 0.2
          ? match.awayScore! + 1
          : match.awayScore;
      
      updated[idx] = match.copyWith(
        elapsedMinutes: newElapsed > 120 ? 90 : newElapsed,
        homeScore: newHomeScore,
        awayScore: newAwayScore,
      );
    }
    // Update state once after all modifications
    state = state.copyWith(allMatches: updated);
  }

}
