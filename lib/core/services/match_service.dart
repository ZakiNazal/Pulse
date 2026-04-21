import '../models/league.dart';
import '../models/match.dart';
import '../models/sport_type.dart';
import '../config/api_config.dart';
import 'api_service.dart';
import 'basketball_service.dart';
import 'football_service.dart';
import 'real_football_service.dart';
import 'real_basketball_service.dart';
import 'real_f1_service.dart';
import 'real_mma_service.dart';

/// Unified service that aggregates match data from all sport-specific
/// [ApiService] implementations.
///
/// This is the primary entry point for the UI layer to fetch match data.
/// It delegates to the appropriate sport-specific service based on
/// [SportType] and provides convenience methods for cross-sport queries.
///
/// ### Usage
/// ```dart
/// final matchService = MatchService();
///
/// // Get all live matches across all sports
/// final allLive = await matchService.getAllLiveMatches();
///
/// // Get only football live matches
/// final footballLive = await matchService.getAllLiveMatches(
///   filter: SportType.football,
/// );
///
/// // Get trending/hot matches
/// final hot = matchService.getHotMatches(allLive);
/// ```
///
/// ### Dependency Injection
/// For production use with real APIs, inject the service instances:
/// ```dart
/// final matchService = MatchService(
///   services: {
///     SportType.football: RealFootballService(apiKey: '...'),
///     SportType.basketball: RealBasketballService(apiKey: '...'),
///     // ...
///   },
/// );
/// ```
class MatchService {
  /// Singleton instance for convenient access throughout the app.
  static final MatchService instance = MatchService._internal();

  /// Internal constructor for singleton.
  MatchService._internal() : _services = _defaultServices();

  /// Map of sport types to their respective API service implementations.
  final Map<SportType, ApiService> _services;

  /// Creates the default set of services (mock or real based on config).
  static Map<SportType, ApiService> _defaultServices() {
    if (ApiConfig.useRealApi) {
      return {
        SportType.football: RealFootballService(),
        SportType.basketball: RealBasketballService(),
        SportType.americanFootball: RealMMAService(), // Mock until real API key provided
        SportType.f1: RealF1Service(),
        SportType.mma: RealMMAService(),
      };
    } else {
      return {
        SportType.football: FootballService(),
        SportType.basketball: BasketballService(),
        SportType.americanFootball: FootballService(), // Use football as mock for American Football
        SportType.f1: FootballService(), // Use football as mock for F1
        SportType.mma: FootballService(), // Use football as mock for MMA
      };
    }
  }

  /// Creates a [MatchService] with the given sport-to-service mapping.
  ///
  /// If [services] is not provided, all mock services are used by default.
  /// Note: For custom service injection, use the named constructor below.
  MatchService({Map<SportType, ApiService>? services})
      : _services = services ?? _defaultServices();

  /// Convenience method that returns ALL matches (live + upcoming + finished).
  ///
  /// This is the primary method used by the UI layer to load all data at once.
  Future<List<Match>> getMatches() async {
    final allMatches = <Match>[];

    for (final service in _services.values) {
      allMatches.addAll(await service.getLiveMatches());
      allMatches.addAll(await service.getUpcomingMatches());
      allMatches.addAll(await service.getFinishedMatches());
    }

    return allMatches;
  }

  /// Returns the [ApiService] for a specific [sportType].
  ///
  /// Throws an [ArgumentError] if no service is registered for the type.
  ApiService serviceFor(SportType sportType) {
    final service = _services[sportType];
    if (service == null) {
      throw ArgumentError('No service registered for $sportType');
    }
    return service;
  }

  /// Returns all live matches, optionally filtered by [filter] sport type.
  ///
  /// Results are sorted by match start time (most recently started first).
  Future<List<Match>> getAllLiveMatches({SportType? filter}) async {
    if (filter != null) {
      return serviceFor(filter).getLiveMatches();
    }

    final allMatches = <Match>[];
    for (final service in _services.values) {
      allMatches.addAll(await service.getLiveMatches());
    }
    allMatches.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allMatches;
  }

  /// Returns all upcoming matches, optionally filtered by [filter] sport type.
  ///
  /// Results are sorted by match start time (soonest first).
  Future<List<Match>> getAllUpcomingMatches({SportType? filter}) async {
    if (filter != null) {
      return serviceFor(filter).getUpcomingMatches();
    }

    final allMatches = <Match>[];
    for (final service in _services.values) {
      allMatches.addAll(await service.getUpcomingMatches());
    }
    allMatches.sort((a, b) => a.startTime.compareTo(b.startTime));
    return allMatches;
  }

  /// Returns all finished matches, optionally filtered by [filter] sport type.
  ///
  /// Results are sorted by start time (most recent first).
  Future<List<Match>> getAllFinishedMatches({SportType? filter}) async {
    if (filter != null) {
      return serviceFor(filter).getFinishedMatches();
    }

    final allMatches = <Match>[];
    for (final service in _services.values) {
      allMatches.addAll(await service.getFinishedMatches());
    }
    allMatches.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allMatches;
  }

  /// Searches for matches across all sports using the given [query].
  ///
  /// The query is matched against team names, league names, venues,
  /// and sport-specific metadata.
  Future<List<Match>> searchAll(String query) async {
    if (query.trim().isEmpty) return [];

    final allMatches = <Match>[];
    for (final service in _services.values) {
      allMatches.addAll(await service.searchMatches(query));
    }

    // Prioritize live matches, then upcoming, then finished.
    final statusOrder = {
      MatchStatus.live: 0,
      MatchStatus.upcoming: 1,
      MatchStatus.finished: 2,
    };
    allMatches.sort((a, b) {
      final statusDiff =
          (statusOrder[a.status] ?? 2) - (statusOrder[b.status] ?? 2);
      if (statusDiff != 0) return statusDiff;
      return b.startTime.compareTo(a.startTime);
    });

    return allMatches;
  }

  /// Returns all popular leagues across all registered sports.
  Future<List<League>> getAllPopularLeagues() async {
    final allLeagues = <League>[];
    for (final service in _services.values) {
      allLeagues.addAll(await service.getPopularLeagues());
    }
    return allLeagues;
  }

  /// Filters a list of matches to return only those marked as hot/trending.
  ///
  /// Hot matches are determined by the [Match.isHot] flag, which is set by
  /// individual sport services based on factors like rivalry, viewership,
  /// or editorial curation.
  ///
  /// Results are sorted with live matches first, then by isHot priority.
  List<Match> getHotMatches(List<Match> matches) {
    final hot = matches.where((m) => m.isHot).toList();

    // Sort live matches to the top, then by start time.
    hot.sort((a, b) {
      if (a.isLive && !b.isLive) return -1;
      if (!a.isLive && b.isLive) return 1;
      return b.startTime.compareTo(a.startTime);
    });

    return hot;
  }

  /// Returns match details for a specific match across all sports.
  ///
  /// Searches through all registered services to find the match with
  /// the given [matchId].
  Future<Match?> getMatchDetails(String matchId) async {
    for (final service in _services.values) {
      final match = await service.getMatchDetails(matchId);
      if (match != null) return match;
    }
    return null;
  }

  /// Returns all matches grouped by sport type.
  ///
  /// Useful for building tabbed or categorized views.
  Future<Map<SportType, List<Match>>> getAllMatchesGrouped() async {
    final result = <SportType, List<Match>>{};

    for (final entry in _services.entries) {
      final matches = <Match>[
        ...await entry.value.getLiveMatches(),
        ...await entry.value.getUpcomingMatches(),
        ...await entry.value.getFinishedMatches(),
      ];
      result[entry.key] = matches;
    }

    return result;
  }

  /// Returns a count of live matches per sport type.
  ///
  /// Useful for showing badge counts on sport category tabs.
  Future<Map<SportType, int>> getLiveMatchCounts() async {
    final counts = <SportType, int>{};
    for (final entry in _services.entries) {
      final liveMatches = await entry.value.getLiveMatches();
      counts[entry.key] = liveMatches.length;
    }
    return counts;
  }

  /// Simulates live score updates across all sports.
  ///
  /// Currently only [FootballService] implements simulation. Other services
  /// return their existing live matches unchanged.
  /// Returns the complete updated list of live matches.
  Future<List<Match>> simulateLiveUpdates() async {
    final allLive = <Match>[];

    for (final entry in _services.entries) {
      if (entry.value is FootballService) {
        final footballService = entry.value as FootballService;
        allLive.addAll(await footballService.simulateLiveUpdates());
      } else {
        allLive.addAll(await entry.value.getLiveMatches());
      }
    }

    allLive.sort((a, b) => b.startTime.compareTo(a.startTime));
    return allLive;
  }
}
