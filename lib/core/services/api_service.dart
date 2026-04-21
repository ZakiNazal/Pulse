import '../models/league.dart';
import '../models/match.dart';

/// Abstract base class that defines the contract for all sport-specific
/// API services in the Pulse app.
///
/// Every sport (football, basketball, tennis, cricket, esports) implements
/// this interface. The current implementations use mock data for demo
/// purposes, but the architecture is designed so that swapping in a real
/// HTTP-based service requires only a new implementation of this class.
///
/// ### Real API Integration Guide
/// 1. Create a new class that extends [ApiService] (e.g. `RealFootballService`).
/// 2. Implement each method using `http` or `dio` packages.
/// 3. Register the real service in [MatchService] instead of the mock.
/// 4. All UI code that depends on [MatchService] will work unchanged.
abstract class ApiService {
  /// Returns all matches that are currently live.
  ///
  /// For real APIs, this would typically hit an endpoint like
  /// `GET /matches?status=live`.
  Future<List<Match>> getLiveMatches();

  /// Returns upcoming (not yet started) matches.
  ///
  /// Optionally filter by [date]. If `null`, returns today's upcoming matches.
  Future<List<Match>> getUpcomingMatches({DateTime? date});

  /// Returns finished (completed) matches.
  ///
  /// Optionally filter by [date]. If `null`, returns today's finished matches.
  Future<List<Match>> getFinishedMatches({DateTime? date});

  /// Returns detailed information for a specific match identified by [matchId].
  ///
  /// Returns `null` if no match is found with the given ID.
  Future<Match?> getMatchDetails(String matchId);

  /// Searches for matches matching the given [query].
  ///
  /// The query is matched against team names, league names, and venues.
  Future<List<Match>> searchMatches(String query);

  /// Returns the list of popular leagues for this sport.
  Future<List<League>> getPopularLeagues();
}
