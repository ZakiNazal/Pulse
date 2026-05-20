import '../models/league.dart';
import '../models/match.dart';
import 'thesportsdb_service.dart';

/// Thin wrapper around [TheSportsDBService] that the rest of the app uses.
/// Keeps the provider interface stable while the data source can change.
class MatchService {
  static final MatchService instance = MatchService._();
  MatchService._();

  final TheSportsDBService _api = TheSportsDBService();

  Future<List<Match>> getMatches({bool forceRefresh = false}) =>
      _api.getAllMatches(forceRefresh: forceRefresh);

  Future<List<League>> getAllPopularLeagues() => _api.getPopularLeagues();

  Future<List<Match>> searchAll(String query) => _api.searchMatches(query);

  void invalidateCache() => _api.invalidate();
}
