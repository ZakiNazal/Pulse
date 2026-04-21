import 'dart:math';

import '../models/league.dart';
import '../models/match.dart';
import '../models/sport_type.dart';
import '../models/team.dart';
import 'api_service.dart';

/// Mock implementation of [ApiService] for football (soccer).
///
/// Provides realistic match data with real team names, proper leagues, and
/// varied match statuses (live, upcoming, finished). The mock data is
/// designed to look authentic for demo and development purposes.
///
/// ### Real API Integration
/// Replace this class with a real implementation that calls a football API
/// (e.g. API-Football, Football-Data.org). The interface remains the same.
class FootballService implements ApiService {
  FootballService();

  /// In-memory cache of mock matches.
  List<Match> _matches = [];

  /// Random instance for simulating live score updates.
  final _random = Random();

  /// Lazy-initializes the mock match data.
  Future<void> _initIfNeeded() async {
    if (_matches.isNotEmpty) return;
    _matches = _buildMockMatches();
    // Simulate network delay for realistic behavior.
    await Future.delayed(const Duration(milliseconds: 300));
  }

  // ── ApiService Implementation ───────────────────────────────────────

  @override
  Future<List<Match>> getLiveMatches() async {
    await _initIfNeeded();
    return _matches.where((m) => m.status == MatchStatus.live).toList();
  }

  @override
  Future<List<Match>> getUpcomingMatches({DateTime? date}) async {
    await _initIfNeeded();
    return _matches.where((m) => m.status == MatchStatus.upcoming).toList();
  }

  @override
  Future<List<Match>> getFinishedMatches({DateTime? date}) async {
    await _initIfNeeded();
    return _matches
        .where((m) => m.status == MatchStatus.finished)
        .toList();
  }

  @override
  Future<Match?> getMatchDetails(String matchId) async {
    await _initIfNeeded();
    try {
      return _matches.firstWhere((m) => m.id == matchId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<Match>> searchMatches(String query) async {
    await _initIfNeeded();
    final q = query.toLowerCase();
    return _matches.where((m) {
      return m.homeTeam.name.toLowerCase().contains(q) ||
          m.awayTeam.name.toLowerCase().contains(q) ||
          m.league.name.toLowerCase().contains(q) ||
          (m.venue?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  @override
  Future<List<League>> getPopularLeagues() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return const [
      League(
        id: 'pl',
        name: 'Premier League',
        country: 'England',
        sportType: SportType.football,
        flag: 'assets/flags/gb-eng.svg',
      ),
      League(
        id: 'laliga',
        name: 'La Liga',
        country: 'Spain',
        sportType: SportType.football,
        flag: 'assets/flags/es.svg',
      ),
      League(
        id: 'seriea',
        name: 'Serie A',
        country: 'Italy',
        sportType: SportType.football,
        flag: 'assets/flags/it.svg',
      ),
      League(
        id: 'bundesliga',
        name: 'Bundesliga',
        country: 'Germany',
        sportType: SportType.football,
        flag: 'assets/flags/de.svg',
      ),
      League(
        id: 'ligue1',
        name: 'Ligue 1',
        country: 'France',
        sportType: SportType.football,
        flag: 'assets/flags/fr.svg',
      ),
      League(
        id: 'ucl',
        name: 'UEFA Champions League',
        country: 'Europe',
        sportType: SportType.football,
        flag: 'assets/flags/eu.svg',
      ),
    ];
  }

  // ── Live Simulation ────────────────────────────────────────────────

  /// Simulates live score updates by randomly changing scores and
  /// incrementing elapsed minutes on live matches.
  ///
  /// Returns the updated list of live matches.
  Future<List<Match>> simulateLiveUpdates() async {
    await _initIfNeeded();
    final updatedMatches = <Match>[];

    for (final match in _matches) {
      if (match.status != MatchStatus.live) continue;

      var newHome = match.homeScore ?? 0;
      var newAway = match.awayScore ?? 0;
      var newElapsed = match.elapsedMinutes ?? 45;

      // Increment elapsed time (1-3 minutes per tick).
      newElapsed += _random.nextInt(3) + 1;
      if (newElapsed > 90) newElapsed = 90;

      // Small chance of a goal (roughly 8% per team per tick).
      if (_random.nextDouble() < 0.08) newHome++;
      if (_random.nextDouble() < 0.08) newAway++;

      // Determine half based on elapsed time.
      final half = newElapsed <= 45 ? 1 : 2;
      final addedTime = newElapsed >= 88 ? _random.nextInt(5) + 1 : 0;

      final updated = match.copyWith(
        homeScore: newHome,
        awayScore: newAway,
        elapsedMinutes: newElapsed,
        extraInfo: {
          ...match.extraInfo,
          'half': half,
          'addedTime': addedTime,
          'referee': 'M. Oliver',
        },
      );
      updatedMatches.add(updated);
    }

    // Replace updated matches in the cache.
    _matches = _matches.map((m) {
      if (m.status != MatchStatus.live) return m;
      final updated = updatedMatches.cast<Match?>().firstWhere(
            (u) => u?.id == m.id,
            orElse: () => null,
          );
      return updated ?? m;
    }).toList();

    return updatedMatches;
  }

  // ── Mock Data Generation ───────────────────────────────────────────

  List<Match> _buildMockMatches() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      // ── LIVE MATCHES ──────────────────────────────────────────────

      Match(
        id: 'football-live-1',
        sportType: SportType.football,
        league: const League(
          id: 'pl',
          name: 'Premier League',
          country: 'England',
          sportType: SportType.football,
          flag: 'assets/flags/gb-eng.svg',
        ),
        homeTeam: const Team(
          id: 'mci',
          name: 'Manchester City',
          shortName: 'MAN CITY',
          logo: 'assets/teams/mci.png',
        ),
        awayTeam: const Team(
          id: 'liv',
          name: 'Liverpool',
          shortName: 'LIVERPOOL',
          logo: 'assets/teams/liv.png',
        ),
        homeScore: 2,
        awayScore: 1,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 67)),
        elapsedMinutes: 67,
        venue: 'Etihad Stadium',
        isHot: true,
        extraInfo: const {
          'half': 2,
          'addedTime': 0,
          'referee': 'M. Oliver',
        },
        homeScoreDetails: const {'HT': 1},
        awayScoreDetails: const {'HT': 0},
      ),

      Match(
        id: 'football-live-2',
        sportType: SportType.football,
        league: const League(
          id: 'laliga',
          name: 'La Liga',
          country: 'Spain',
          sportType: SportType.football,
          flag: 'assets/flags/es.svg',
        ),
        homeTeam: const Team(
          id: 'rma',
          name: 'Real Madrid',
          shortName: 'REAL MADRID',
          logo: 'assets/teams/rma.png',
        ),
        awayTeam: const Team(
          id: 'bar',
          name: 'Barcelona',
          shortName: 'BARCELONA',
          logo: 'assets/teams/bar.png',
        ),
        homeScore: 1,
        awayScore: 1,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 34)),
        elapsedMinutes: 34,
        venue: 'Santiago Bernabeu',
        isHot: true,
        extraInfo: const {
          'half': 1,
          'addedTime': 0,
          'referee': 'A. Mateu Lahoz',
        },
      ),

      Match(
        id: 'football-live-3',
        sportType: SportType.football,
        league: const League(
          id: 'seriea',
          name: 'Serie A',
          country: 'Italy',
          sportType: SportType.football,
          flag: 'assets/flags/it.svg',
        ),
        homeTeam: const Team(
          id: 'inter',
          name: 'Inter Milan',
          shortName: 'INTER',
          logo: 'assets/teams/inter.png',
        ),
        awayTeam: const Team(
          id: 'juv',
          name: 'Juventus',
          shortName: 'JUVENTUS',
          logo: 'assets/teams/juv.png',
        ),
        homeScore: 3,
        awayScore: 0,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 78)),
        elapsedMinutes: 78,
        venue: 'San Siro',
        extraInfo: const {
          'half': 2,
          'addedTime': 0,
          'referee': 'D. Orsato',
        },
        homeScoreDetails: const {'HT': 2},
        awayScoreDetails: const {'HT': 0},
      ),

      Match(
        id: 'football-live-4',
        sportType: SportType.football,
        league: const League(
          id: 'bundesliga',
          name: 'Bundesliga',
          country: 'Germany',
          sportType: SportType.football,
          flag: 'assets/flags/de.svg',
        ),
        homeTeam: const Team(
          id: 'bay',
          name: 'Bayern Munich',
          shortName: 'BAYERN',
          logo: 'assets/teams/bay.png',
        ),
        awayTeam: const Team(
          id: 'bvb',
          name: 'Borussia Dortmund',
          shortName: 'DORTMUND',
          logo: 'assets/teams/bvb.png',
        ),
        homeScore: 2,
        awayScore: 2,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 52)),
        elapsedMinutes: 52,
        venue: 'Allianz Arena',
        isHot: true,
        extraInfo: const {
          'half': 2,
          'addedTime': 0,
          'referee': 'F. Zwayer',
        },
        homeScoreDetails: const {'HT': 1},
        awayScoreDetails: const {'HT': 2},
      ),

      Match(
        id: 'football-live-5',
        sportType: SportType.football,
        league: const League(
          id: 'ucl',
          name: 'UEFA Champions League',
          country: 'Europe',
          sportType: SportType.football,
          flag: 'assets/flags/eu.svg',
        ),
        homeTeam: const Team(
          id: 'psg',
          name: 'Paris Saint-Germain',
          shortName: 'PSG',
          logo: 'assets/teams/psg.png',
        ),
        awayTeam: const Team(
          id: 'ars',
          name: 'Arsenal',
          shortName: 'ARSENAL',
          logo: 'assets/teams/ars.png',
        ),
        homeScore: 0,
        awayScore: 1,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 23)),
        elapsedMinutes: 23,
        venue: 'Parc des Princes',
        extraInfo: const {
          'half': 1,
          'addedTime': 0,
          'referee': 'C. Turpin',
        },
      ),

      // ── UPCOMING MATCHES ──────────────────────────────────────────

      Match(
        id: 'football-upcoming-1',
        sportType: SportType.football,
        league: const League(
          id: 'pl',
          name: 'Premier League',
          country: 'England',
          sportType: SportType.football,
          flag: 'assets/flags/gb-eng.svg',
        ),
        homeTeam: const Team(
          id: 'ars',
          name: 'Arsenal',
          shortName: 'ARSENAL',
          logo: 'assets/teams/ars.png',
        ),
        awayTeam: const Team(
          id: 'che',
          name: 'Chelsea',
          shortName: 'CHELSEA',
          logo: 'assets/teams/che.png',
        ),
        status: MatchStatus.upcoming,
        startTime: today.add(const Duration(hours: 3)),
        venue: 'Emirates Stadium',
        extraInfo: const {'matchday': 28},
      ),

      Match(
        id: 'football-upcoming-2',
        sportType: SportType.football,
        league: const League(
          id: 'laliga',
          name: 'La Liga',
          country: 'Spain',
          sportType: SportType.football,
          flag: 'assets/flags/es.svg',
        ),
        homeTeam: const Team(
          id: 'atm',
          name: 'Atletico Madrid',
          shortName: 'AT. MADRID',
          logo: 'assets/teams/atm.png',
        ),
        awayTeam: const Team(
          id: 'sev',
          name: 'Sevilla',
          shortName: 'SEVILLA',
          logo: 'assets/teams/sev.png',
        ),
        status: MatchStatus.upcoming,
        startTime: today.add(const Duration(hours: 5, minutes: 30)),
        venue: 'Civitas Metropolitano',
        extraInfo: const {'matchday': 30},
      ),

      Match(
        id: 'football-upcoming-3',
        sportType: SportType.football,
        league: const League(
          id: 'seriea',
          name: 'Serie A',
          country: 'Italy',
          sportType: SportType.football,
          flag: 'assets/flags/it.svg',
        ),
        homeTeam: const Team(
          id: 'nap',
          name: 'Napoli',
          shortName: 'NAPOLI',
          logo: 'assets/teams/nap.png',
        ),
        awayTeam: const Team(
          id: 'rom',
          name: 'AS Roma',
          shortName: 'ROMA',
          logo: 'assets/teams/rom.png',
        ),
        status: MatchStatus.upcoming,
        startTime: today.add(const Duration(hours: 8)),
        venue: 'Stadio Diego Armando Maradona',
        extraInfo: const {'matchday': 29},
      ),

      Match(
        id: 'football-upcoming-4',
        sportType: SportType.football,
        league: const League(
          id: 'ligue1',
          name: 'Ligue 1',
          country: 'France',
          sportType: SportType.football,
          flag: 'assets/flags/fr.svg',
        ),
        homeTeam: const Team(
          id: 'lyo',
          name: 'Olympique Lyon',
          shortName: 'LYON',
          logo: 'assets/teams/lyo.png',
        ),
        awayTeam: const Team(
          id: 'mon',
          name: 'AS Monaco',
          shortName: 'MONACO',
          logo: 'assets/teams/mon.png',
        ),
        status: MatchStatus.upcoming,
        startTime: today.add(const Duration(hours: 1, minutes: 15)),
        venue: 'Groupama Stadium',
        extraInfo: const {'matchday': 27},
      ),

      // ── FINISHED MATCHES ──────────────────────────────────────────

      Match(
        id: 'football-finished-1',
        sportType: SportType.football,
        league: const League(
          id: 'pl',
          name: 'Premier League',
          country: 'England',
          sportType: SportType.football,
          flag: 'assets/flags/gb-eng.svg',
        ),
        homeTeam: const Team(
          id: 'mun',
          name: 'Manchester United',
          shortName: 'MAN UTD',
          logo: 'assets/teams/mun.png',
        ),
        awayTeam: const Team(
          id: 'tot',
          name: 'Tottenham Hotspur',
          shortName: 'TOTTENHAM',
          logo: 'assets/teams/tot.png',
        ),
        homeScore: 3,
        awayScore: 2,
        status: MatchStatus.finished,
        startTime: today.subtract(const Duration(hours: 4)),
        venue: 'Old Trafford',
        extraInfo: const {
          'half': 2,
          'addedTime': 4,
          'referee': 'A. Taylor',
          'attendance': 73200,
        },
        homeScoreDetails: const {'HT': 1, 'FT': 3},
        awayScoreDetails: const {'HT': 1, 'FT': 2},
      ),

      Match(
        id: 'football-finished-2',
        sportType: SportType.football,
        league: const League(
          id: 'laliga',
          name: 'La Liga',
          country: 'Spain',
          sportType: SportType.football,
          flag: 'assets/flags/es.svg',
        ),
        homeTeam: const Team(
          id: 'fcn',
          name: 'FC Barcelona',
          shortName: 'BARCELONA',
          logo: 'assets/teams/bar.png',
        ),
        awayTeam: const Team(
          id: 'val',
          name: 'Valencia',
          shortName: 'VALENCIA',
          logo: 'assets/teams/val.png',
        ),
        homeScore: 4,
        awayScore: 0,
        status: MatchStatus.finished,
        startTime: today.subtract(const Duration(hours: 6)),
        venue: 'Camp Nou',
        extraInfo: const {
          'half': 2,
          'addedTime': 2,
          'referee': 'J. Munuera',
          'attendance': 93254,
        },
        homeScoreDetails: const {'HT': 2, 'FT': 4},
        awayScoreDetails: const {'HT': 0, 'FT': 0},
      ),

      Match(
        id: 'football-finished-3',
        sportType: SportType.football,
        league: const League(
          id: 'bundesliga',
          name: 'Bundesliga',
          country: 'Germany',
          sportType: SportType.football,
          flag: 'assets/flags/de.svg',
        ),
        homeTeam: const Team(
          id: 'rbl',
          name: 'RB Leipzig',
          shortName: 'LEIPZIG',
          logo: 'assets/teams/rbl.png',
        ),
        awayTeam: const Team(
          id: 'lev',
          name: 'Bayer Leverkusen',
          shortName: 'LEVERKUSEN',
          logo: 'assets/teams/lev.png',
        ),
        homeScore: 1,
        awayScore: 3,
        status: MatchStatus.finished,
        startTime: today.subtract(const Duration(hours: 5)),
        venue: 'Red Bull Arena',
        extraInfo: const {
          'half': 2,
          'addedTime': 3,
          'referee': 'D. Siebert',
          'attendance': 42100,
        },
        homeScoreDetails: const {'HT': 0, 'FT': 1},
        awayScoreDetails: const {'HT': 2, 'FT': 3},
      ),

      Match(
        id: 'football-finished-4',
        sportType: SportType.football,
        league: const League(
          id: 'ucl',
          name: 'UEFA Champions League',
          country: 'Europe',
          sportType: SportType.football,
          flag: 'assets/flags/eu.svg',
        ),
        homeTeam: const Team(
          id: 'acm',
          name: 'AC Milan',
          shortName: 'AC MILAN',
          logo: 'assets/teams/acm.png',
        ),
        awayTeam: const Team(
          id: 'bay',
          name: 'Bayern Munich',
          shortName: 'BAYERN',
          logo: 'assets/teams/bay.png',
        ),
        homeScore: 2,
        awayScore: 2,
        status: MatchStatus.finished,
        startTime: today.subtract(const Duration(hours: 8)),
        venue: 'San Siro',
        extraInfo: const {
          'half': 2,
          'addedTime': 5,
          'referee': 'A. Mateu Lahoz',
          'attendance': 75300,
          'aggregate': 'AC Milan 4-4 Bayern Munich (Away goals)',
        },
        homeScoreDetails: const {'HT': 1, 'FT': 2},
        awayScoreDetails: const {'HT': 1, 'FT': 2},
      ),
    ];
  }
}
