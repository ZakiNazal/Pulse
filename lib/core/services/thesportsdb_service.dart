import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/league.dart';
import '../models/match.dart';
import '../models/sport_type.dart';
import '../models/team.dart';

/// Free sports data from TheSportsDB (api key "3" = no payment needed).
/// Base URL: https://www.thesportsdb.com/api/v1/json/3
class TheSportsDBService {
  static const String _base = 'https://www.thesportsdb.com/api/v1/json/3';

  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 20),
    headers: {'Accept': 'application/json'},
  ));

  // Cached results to avoid hammering the API
  List<Match>? _cache;
  DateTime? _cacheTime;
  static const _ttl = Duration(minutes: 5);

  bool get _cacheValid =>
      _cache != null &&
      _cacheTime != null &&
      DateTime.now().difference(_cacheTime!) < _ttl;

  // Popular league IDs from TheSportsDB (keep list short to limit API calls)
  static const _leaguesByType = {
    SportType.football: ['4328', '4335', '4480', '4332'],
    SportType.basketball: ['4387'],
    SportType.f1: ['4370'],
    SportType.mma: ['4443'],
    SportType.americanFootball: ['4391'],
    SportType.tennis: ['4181'],
  };

  // Sport name strings used by the eventsday endpoint
  static const _dayNames = {
    SportType.football: 'Soccer',
    SportType.basketball: 'Basketball',
    SportType.f1: 'Motorsport',
    SportType.mma: 'Fighting',
    SportType.americanFootball: 'American Football',
  };

  Future<List<Match>> getAllMatches({bool forceRefresh = false}) async {
    if (!forceRefresh && _cacheValid) return _cache!;

    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    final todayResults = <Match>[];
    final upcoming = <Match>[];
    final finished = <Match>[];

    // Fetch in waves to avoid hammering the free API
    await _fetchToday(today, todayResults);
    await Future.wait([
      _fetchLeagues(SportType.football, upcoming, finished),
      _fetchLeagues(SportType.basketball, upcoming, finished),
    ]);
    await Future.wait([
      _fetchLeagues(SportType.f1, upcoming, finished),
      _fetchLeagues(SportType.mma, upcoming, finished),
    ]);

    // Merge, deduplicating by event ID
    final byId = <String, Match>{};
    for (final m in [...todayResults, ...upcoming, ...finished]) {
      byId[m.id] = m;
    }

    _cache = byId.values.toList();
    _cacheTime = DateTime.now();
    return _cache!;
  }

  Future<List<League>> getPopularLeagues() async {
    final results = <League>[];
    await Future.wait(_dayNames.entries.map((entry) async {
      try {
        final r = await _dio.get('$_base/all_leagues.php',
            queryParameters: {'s': entry.value});
        final list = (r.data?['leagues'] as List?) ?? [];
        results.addAll(
          list.take(3).map((l) => _league(l, entry.key)).whereType<League>(),
        );
      } catch (e) {
        debugPrint('[TSDB] leagues ${entry.value}: $e');
      }
    }));
    return results;
  }

  Future<List<Match>> searchMatches(String query) async {
    if (query.trim().isEmpty) return [];
    final results = <Match>[];
    try {
      final r = await _dio.get('$_base/searchevents.php',
          queryParameters: {'e': query.trim()});
      final events = (r.data?['event'] as List?) ?? [];
      for (final e in events) {
        final sport = _sportType(e['strSport'] as String? ?? '');
        final m = _parseEvent(e, sport);
        if (m != null) results.add(m);
      }
    } catch (e) {
      debugPrint('[TSDB] search: $e');
    }
    return results;
  }

  void invalidate() {
    _cache = null;
    _cacheTime = null;
  }

  // ── Private helpers ──────────────────────────────────────────────────

  Future<void> _fetchToday(String date, List<Match> out) async {
    await Future.wait(_dayNames.entries.map((entry) async {
      try {
        final r = await _dio.get('$_base/eventsday.php',
            queryParameters: {'d': date, 's': entry.value});
        final events = (r.data?['events'] as List?) ?? [];
        out.addAll(events
            .map((e) => _parseEvent(e, entry.key))
            .whereType<Match>());
      } catch (e) {
        debugPrint('[TSDB] today ${entry.value}: $e');
      }
    }));
  }

  Future<void> _fetchLeagues(
    SportType sport,
    List<Match> upcoming,
    List<Match> finished,
  ) async {
    final ids = _leaguesByType[sport] ?? [];
    await Future.wait(ids.map((id) async {
      await Future.wait([
        _fetchEndpoint('$_base/eventsnext.php', {'id': id}, sport, upcoming),
        _fetchEndpoint('$_base/eventslast.php', {'id': id}, sport, finished),
      ]);
    }));
  }

  Future<void> _fetchEndpoint(
    String url,
    Map<String, String> params,
    SportType sport,
    List<Match> out,
  ) async {
    try {
      final r = await _dio.get(url, queryParameters: params);
      final events = (r.data?['events'] as List?) ?? [];
      out.addAll(events.map((e) => _parseEvent(e, sport)).whereType<Match>());
    } catch (e) {
      debugPrint('[TSDB] $url ${params.values.first}: $e');
    }
  }

  Match? _parseEvent(dynamic raw, SportType sportType) {
    try {
      final e = raw as Map<String, dynamic>;
      final id = e['idEvent']?.toString() ?? '';
      if (id.isEmpty) return null;

      final dateStr = e['dateEvent'] as String? ?? '';
      final timeStr = e['strTime'] as String? ?? '00:00:00';

      DateTime startTime;
      try {
        startTime = DateTime.parse('${dateStr}T$timeStr').toLocal();
      } catch (_) {
        startTime = DateTime.now().add(const Duration(hours: 1));
      }

      final homeScore = _parseScore(e['intHomeScore']);
      final awayScore = _parseScore(e['intAwayScore']);
      final statusStr = e['strStatus'] as String? ?? '';
      final status = _inferStatus(statusStr, startTime, homeScore, awayScore);

      // Badge field name varies between endpoints
      final homeBadge = _nonEmpty(e['strHomeTeamBadge']) ?? _nonEmpty(e['imageHomeTeam']);
      final awayBadge = _nonEmpty(e['strAwayTeamBadge']) ?? _nonEmpty(e['imageAwayTeam']);

      final homeName = e['strHomeTeam'] as String? ?? 'Home';
      final awayName = e['strAwayTeam'] as String? ?? 'Away';

      int? elapsed;
      if (status == MatchStatus.live) {
        elapsed = DateTime.now().difference(startTime).inMinutes.clamp(1, 90);
      }

      final totalGoals = (homeScore ?? 0) + (awayScore ?? 0);
      final isHot = status == MatchStatus.live ||
          (status == MatchStatus.finished && totalGoals >= 4);

      return Match(
        id: id,
        sportType: sportType,
        league: League(
          id: e['idLeague']?.toString() ?? '',
          name: e['strLeague'] as String? ?? '',
          logo: '',
          country: e['strCountry'] as String? ?? '',
          sportType: sportType,
        ),
        homeTeam: Team(
          id: e['idHomeTeam']?.toString() ?? '',
          name: homeName,
          shortName: _shortName(homeName),
          logo: homeBadge,
        ),
        awayTeam: Team(
          id: e['idAwayTeam']?.toString() ?? '',
          name: awayName,
          shortName: _shortName(awayName),
          logo: awayBadge,
        ),
        homeScore: homeScore,
        awayScore: awayScore,
        startTime: startTime,
        status: status,
        venue: _nonEmpty(e['strVenue'] as String?),
        isHot: isHot,
        elapsedMinutes: elapsed,
      );
    } catch (e) {
      debugPrint('[TSDB] parse: $e');
      return null;
    }
  }

  MatchStatus _inferStatus(
    String raw,
    DateTime start,
    int? homeScore,
    int? awayScore,
  ) {
    final s = raw.toLowerCase().trim();
    if (s.contains('finished') || s == 'ft' || s == 'aet' || s == 'pen' || s == 'ap') {
      return MatchStatus.finished;
    }
    if (s == '1h' || s == '2h' || s == 'ht' || s == 'et' || s == 'live' ||
        s == 'p' || s == 'bt' || s == 'inprogress') {
      return MatchStatus.live;
    }

    final now = DateTime.now();
    if (now.isAfter(start)) {
      if (homeScore != null || awayScore != null) return MatchStatus.finished;
      if (now.difference(start).inMinutes < 120) return MatchStatus.live;
      return MatchStatus.finished;
    }

    return MatchStatus.upcoming;
  }

  int? _parseScore(dynamic val) {
    if (val == null) return null;
    final s = val.toString().trim();
    if (s.isEmpty || s == 'null') return null;
    return int.tryParse(s);
  }

  String? _nonEmpty(String? s) =>
      (s != null && s.trim().isNotEmpty) ? s.trim() : null;

  SportType _sportType(String s) {
    final l = s.toLowerCase();
    if (l.contains('soccer') || (l.contains('football') && !l.contains('american'))) {
      return SportType.football;
    }
    if (l.contains('basketball')) return SportType.basketball;
    if (l.contains('motorsport') || l.contains('formula')) return SportType.f1;
    if (l.contains('fighting') || l.contains('mma') || l.contains('ufc')) {
      return SportType.mma;
    }
    if (l.contains('american')) return SportType.americanFootball;
    if (l.contains('tennis')) return SportType.tennis;
    return SportType.football;
  }

  String _shortName(String name) {
    const map = {
      'Manchester United': 'Man Utd',
      'Manchester City': 'Man City',
      'Tottenham Hotspur': 'Spurs',
      'Newcastle United': 'Newcastle',
      'Nottingham Forest': "Nott'm F",
      'Real Madrid CF': 'Real Madrid',
      'FC Barcelona': 'Barcelona',
      'Atlético de Madrid': 'Atletico',
      'Bayern München': 'Bayern',
      'Borussia Dortmund': 'Dortmund',
      'Juventus FC': 'Juventus',
      'Paris Saint-Germain FC': 'PSG',
      'Los Angeles Lakers': 'LA Lakers',
      'Golden State Warriors': 'Warriors',
      'Boston Celtics': 'Celtics',
      'Miami Heat': 'Miami Heat',
    };
    return map[name] ?? (name.length > 14 ? name.split(' ').take(2).join(' ') : name);
  }

  League? _league(dynamic raw, SportType sport) {
    try {
      final l = raw as Map<String, dynamic>;
      return League(
        id: l['idLeague']?.toString() ?? '',
        name: l['strLeague'] as String? ?? '',
        logo: l['strLogo'] as String? ?? '',
        country: l['strCountry'] as String? ?? '',
        sportType: sport,
      );
    } catch (_) {
      return null;
    }
  }
}
