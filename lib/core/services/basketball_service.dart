import '../models/league.dart';
import '../models/match.dart';
import '../models/sport_type.dart';
import '../models/team.dart';
import 'api_service.dart';

/// Mock implementation of [ApiService] for basketball.
///
/// Provides realistic NBA and EuroLeague match data with proper quarter
/// scoring, venues, and varied match statuses.
///
/// ### Real API Integration
/// Replace this class with a real implementation that calls a basketball API
/// (e.g. balldontlie API, NBA Stats API, SportsData.io).
class BasketballService implements ApiService {
  BasketballService();

  /// In-memory cache of mock matches.
  List<Match> _matches = [];

  /// Lazy-initializes the mock match data.
  Future<void> _initIfNeeded() async {
    if (_matches.isNotEmpty) return;
    _matches = _buildMockMatches();
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
        id: 'nba',
        name: 'NBA',
        country: 'USA',
        sportType: SportType.basketball,
        flag: 'assets/flags/us.svg',
      ),
      League(
        id: 'euroleague',
        name: 'EuroLeague',
        country: 'Europe',
        sportType: SportType.basketball,
        flag: 'assets/flags/eu.svg',
      ),
      League(
        id: 'acb',
        name: 'Liga ACB',
        country: 'Spain',
        sportType: SportType.basketball,
        flag: 'assets/flags/es.svg',
      ),
      League(
        id: 'wnba',
        name: 'WNBA',
        country: 'USA',
        sportType: SportType.basketball,
        flag: 'assets/flags/us.svg',
      ),
    ];
  }

  // ── Mock Data Generation ───────────────────────────────────────────

  List<Match> _buildMockMatches() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return [
      // ── LIVE MATCHES ──────────────────────────────────────────────

      Match(
        id: 'basketball-live-1',
        sportType: SportType.basketball,
        league: const League(
          id: 'nba',
          name: 'NBA',
          country: 'USA',
          sportType: SportType.basketball,
          flag: 'assets/flags/us.svg',
        ),
        homeTeam: const Team(
          id: 'lal',
          name: 'Los Angeles Lakers',
          shortName: 'LAL',
          logo: 'assets/teams/lal.png',
        ),
        awayTeam: const Team(
          id: 'bos',
          name: 'Boston Celtics',
          shortName: 'BOS',
          logo: 'assets/teams/bos.png',
        ),
        homeScore: 87,
        awayScore: 92,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 105)),
        elapsedMinutes: 105,
        venue: 'Crypto.com Arena',
        isHot: true,
        extraInfo: const {
          'currentQuarter': 3,
          'shotClock': 14,
          'attendance': 18997,
        },
        homeScoreDetails: const {'Q1': 28, 'Q2': 24, 'Q3': 35},
        awayScoreDetails: const {'Q1': 31, 'Q2': 30, 'Q3': 31},
      ),

      Match(
        id: 'basketball-live-2',
        sportType: SportType.basketball,
        league: const League(
          id: 'nba',
          name: 'NBA',
          country: 'USA',
          sportType: SportType.basketball,
          flag: 'assets/flags/us.svg',
        ),
        homeTeam: const Team(
          id: 'gsw',
          name: 'Golden State Warriors',
          shortName: 'GSW',
          logo: 'assets/teams/gsw.png',
        ),
        awayTeam: const Team(
          id: 'dal',
          name: 'Dallas Mavericks',
          shortName: 'DAL',
          logo: 'assets/teams/dal.png',
        ),
        homeScore: 64,
        awayScore: 58,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 60)),
        elapsedMinutes: 60,
        venue: 'Chase Center',
        extraInfo: const {
          'currentQuarter': 2,
          'shotClock': 8,
          'attendance': 18064,
        },
        homeScoreDetails: const {'Q1': 34, 'Q2': 30},
        awayScoreDetails: const {'Q1': 26, 'Q2': 32},
      ),

      Match(
        id: 'basketball-live-3',
        sportType: SportType.basketball,
        league: const League(
          id: 'nba',
          name: 'NBA',
          country: 'USA',
          sportType: SportType.basketball,
          flag: 'assets/flags/us.svg',
        ),
        homeTeam: const Team(
          id: 'mil',
          name: 'Milwaukee Bucks',
          shortName: 'MIL',
          logo: 'assets/teams/mil.png',
        ),
        awayTeam: const Team(
          id: 'phi',
          name: 'Philadelphia 76ers',
          shortName: 'PHI',
          logo: 'assets/teams/phi.png',
        ),
        homeScore: 102,
        awayScore: 98,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 130)),
        elapsedMinutes: 130,
        venue: 'Fiserv Forum',
        extraInfo: const {
          'currentQuarter': 4,
          'shotClock': 22,
          'attendance': 17800,
        },
        homeScoreDetails: const {'Q1': 28, 'Q2': 30, 'Q3': 22, 'Q4': 22},
        awayScoreDetails: const {'Q1': 24, 'Q2': 26, 'Q3': 25, 'Q4': 23},
      ),

      Match(
        id: 'basketball-live-4',
        sportType: SportType.basketball,
        league: const League(
          id: 'euroleague',
          name: 'EuroLeague',
          country: 'Europe',
          sportType: SportType.basketball,
          flag: 'assets/flags/eu.svg',
        ),
        homeTeam: const Team(
          id: 'rmb',
          name: 'Real Madrid Basket',
          shortName: 'R. MADRID',
          logo: 'assets/teams/rmb.png',
        ),
        awayTeam: const Team(
          id: 'pan',
          name: 'Panathinaikos',
          shortName: 'PAO',
          logo: 'assets/teams/pan.png',
        ),
        homeScore: 56,
        awayScore: 52,
        status: MatchStatus.live,
        startTime: today.subtract(const Duration(minutes: 72)),
        elapsedMinutes: 72,
        venue: 'WiZink Center',
        extraInfo: const {
          'currentQuarter': 3,
          'shotClock': 11,
        },
        homeScoreDetails: const {'Q1': 18, 'Q2': 15, 'Q3': 23},
        awayScoreDetails: const {'Q1': 14, 'Q2': 20, 'Q3': 18},
      ),

      // ── UPCOMING MATCHES ──────────────────────────────────────────

      Match(
        id: 'basketball-upcoming-1',
        sportType: SportType.basketball,
        league: const League(
          id: 'nba',
          name: 'NBA',
          country: 'USA',
          sportType: SportType.basketball,
          flag: 'assets/flags/us.svg',
        ),
        homeTeam: const Team(
          id: 'den',
          name: 'Denver Nuggets',
          shortName: 'DEN',
          logo: 'assets/teams/den.png',
        ),
        awayTeam: const Team(
          id: 'mia',
          name: 'Miami Heat',
          shortName: 'MIA',
          logo: 'assets/teams/mia.png',
        ),
        status: MatchStatus.upcoming,
        startTime: today.add(const Duration(hours: 4)),
        venue: 'Ball Arena',
        extraInfo: const {'season': '2024-25'},
      ),

      Match(
        id: 'basketball-upcoming-2',
        sportType: SportType.basketball,
        league: const League(
          id: 'nba',
          name: 'NBA',
          country: 'USA',
          sportType: SportType.basketball,
          flag: 'assets/flags/us.svg',
        ),
        homeTeam: const Team(
          id: 'phx',
          name: 'Phoenix Suns',
          shortName: 'PHX',
          logo: 'assets/teams/phx.png',
        ),
        awayTeam: const Team(
          id: 'nyk',
          name: 'New York Knicks',
          shortName: 'NYK',
          logo: 'assets/teams/nyk.png',
        ),
        status: MatchStatus.upcoming,
        startTime: today.add(const Duration(hours: 6, minutes: 30)),
        venue: 'Footprint Center',
        extraInfo: const {'season': '2024-25'},
      ),

      Match(
        id: 'basketball-upcoming-3',
        sportType: SportType.basketball,
        league: const League(
          id: 'euroleague',
          name: 'EuroLeague',
          country: 'Europe',
          sportType: SportType.basketball,
          flag: 'assets/flags/eu.svg',
        ),
        homeTeam: const Team(
          id: 'fcb',
          name: 'FC Barcelona Basket',
          shortName: 'BARCA',
          logo: 'assets/teams/fcb_basket.png',
        ),
        awayTeam: const Team(
          id: 'olm',
          name: 'Olympiacos',
          shortName: 'OLYMPIACOS',
          logo: 'assets/teams/olm.png',
        ),
        status: MatchStatus.upcoming,
        startTime: today.add(const Duration(hours: 7, minutes: 45)),
        venue: 'Palau Blaugrana',
        extraInfo: const {'round': 28},
      ),

      // ── FINISHED MATCHES ──────────────────────────────────────────

      Match(
        id: 'basketball-finished-1',
        sportType: SportType.basketball,
        league: const League(
          id: 'nba',
          name: 'NBA',
          country: 'USA',
          sportType: SportType.basketball,
          flag: 'assets/flags/us.svg',
        ),
        homeTeam: const Team(
          id: 'cle',
          name: 'Cleveland Cavaliers',
          shortName: 'CLE',
          logo: 'assets/teams/cle.png',
        ),
        awayTeam: const Team(
          id: 'okc',
          name: 'Oklahoma City Thunder',
          shortName: 'OKC',
          logo: 'assets/teams/okc.png',
        ),
        homeScore: 118,
        awayScore: 112,
        status: MatchStatus.finished,
        startTime: today.subtract(const Duration(hours: 5)),
        venue: 'Rocket Mortgage FieldHouse',
        extraInfo: const {
          'attendance': 19432,
          'mvp': 'D. Garland (32 pts, 11 ast)',
        },
        homeScoreDetails: const {
          'Q1': 31,
          'Q2': 28,
          'Q3': 30,
          'Q4': 29,
        },
        awayScoreDetails: const {
          'Q1': 30,
          'Q2': 26,
          'Q3': 29,
          'Q4': 27,
        },
      ),

      Match(
        id: 'basketball-finished-2',
        sportType: SportType.basketball,
        league: const League(
          id: 'nba',
          name: 'NBA',
          country: 'USA',
          sportType: SportType.basketball,
          flag: 'assets/flags/us.svg',
        ),
        homeTeam: const Team(
          id: 'lac',
          name: 'Los Angeles Clippers',
          shortName: 'LAC',
          logo: 'assets/teams/lac.png',
        ),
        awayTeam: const Team(
          id: 'sas',
          name: 'San Antonio Spurs',
          shortName: 'SAS',
          logo: 'assets/teams/sas.png',
        ),
        homeScore: 108,
        awayScore: 115,
        status: MatchStatus.finished,
        startTime: today.subtract(const Duration(hours: 7)),
        venue: 'Intuit Dome',
        extraInfo: const {
          'attendance': 18000,
          'mvp': 'V. Wembanyama (34 pts, 12 reb)',
        },
        homeScoreDetails: const {
          'Q1': 27,
          'Q2': 30,
          'Q3': 25,
          'Q4': 26,
        },
        awayScoreDetails: const {
          'Q1': 28,
          'Q2': 29,
          'Q3': 30,
          'Q4': 28,
        },
      ),

      Match(
        id: 'basketball-finished-3',
        sportType: SportType.basketball,
        league: const League(
          id: 'nba',
          name: 'NBA',
          country: 'USA',
          sportType: SportType.basketball,
          flag: 'assets/flags/us.svg',
        ),
        homeTeam: const Team(
          id: 'min',
          name: 'Minnesota Timberwolves',
          shortName: 'MIN',
          logo: 'assets/teams/min.png',
        ),
        awayTeam: const Team(
          id: 'mem',
          name: 'Memphis Grizzlies',
          shortName: 'MEM',
          logo: 'assets/teams/mem.png',
        ),
        homeScore: 121,
        awayScore: 119,
        status: MatchStatus.finished,
        startTime: today.subtract(const Duration(hours: 4, minutes: 30)),
        venue: 'Target Center',
        extraInfo: const {
          'attendance': 18100,
          'mvp': 'A. Edwards (38 pts, 7 reb)',
          'overtime': 'OT',
        },
        homeScoreDetails: const {
          'Q1': 32,
          'Q2': 28,
          'Q3': 30,
          'Q4': 24,
          'OT': 7,
        },
        awayScoreDetails: const {
          'Q1': 30,
          'Q2': 31,
          'Q3': 26,
          'Q4': 25,
          'OT': 7,
        },
      ),
    ];
  }
}
