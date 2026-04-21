import 'package:equatable/equatable.dart';
import 'league.dart';
import 'sport_type.dart';
import 'team.dart';

/// Represents the current status of a match.
enum MatchStatus {
  /// The match is currently in progress.
  live,

  /// The match has not started yet.
  upcoming,

  /// The match has concluded.
  finished,
}

/// Extension methods on [MatchStatus] for display and serialization.
extension MatchStatusX on MatchStatus {
  /// JSON-safe string key used for serialization.
  String get jsonKey => name;

  /// Human-readable display label.
  String get displayName {
    switch (this) {
      case MatchStatus.live:
        return 'LIVE';
      case MatchStatus.upcoming:
        return 'Upcoming';
      case MatchStatus.finished:
        return 'FT';
    }
  }

  /// Parses a [MatchStatus] from a JSON string key.
  static MatchStatus fromJsonKey(String? key) {
    if (key == null) return MatchStatus.upcoming;
    return MatchStatus.values.byName(key);
  }
}

/// The core model that normalizes match data across all supported sports.
///
/// Every sport – football, basketball, American football, F1, and MMA – is represented through the same unified interface. Sport-
/// specific details live inside [extraInfo], [homeScoreDetails], and
/// [awayScoreDetails].
class Match extends Equatable {
  const Match({
    required this.id,
    required this.sportType,
    required this.league,
    required this.homeTeam,
    required this.awayTeam,
    required this.status,
    required this.startTime,
    this.homeScore,
    this.awayScore,
    this.elapsedMinutes,
    this.venue,
    this.extraInfo = const {},
    this.isHot = false,
    this.homeScoreDetails,
    this.awayScoreDetails,
  });

  // ── Identity ──────────────────────────────────────────────────────

  /// Unique identifier for the match.
  final String id;

  // ── Context ───────────────────────────────────────────────────────

  /// The type of sport this match belongs to.
  final SportType sportType;

  /// The league / competition this match is part of.
  final League league;

  // ── Teams ─────────────────────────────────────────────────────────

  final Team homeTeam;
  final Team awayTeam;

  // ── Scores ────────────────────────────────────────────────────────

  /// Total score for the home team (null when [status] is [MatchStatus.upcoming]).
  final int? homeScore;

  /// Total score for the away team (null when [status] is [MatchStatus.upcoming]).
  final int? awayScore;

  /// Period-by-period score breakdown for the home team.
  ///
  /// Example keys: `"Q1"`, `"Q2"`, `"Half"`, `"Set 1"`, `"Innings 1"`.
  final Map<String, int>? homeScoreDetails;

  /// Period-by-period score breakdown for the away team.
  final Map<String, int>? awayScoreDetails;

  // ── Status & Time ─────────────────────────────────────────────────

  /// Current status of the match.
  final MatchStatus status;

  /// UTC timestamp for when the match begins.
  final DateTime startTime;

  /// Minutes elapsed since kick-off (only meaningful when live).
  final int? elapsedMinutes;

  // ── Location & Extras ─────────────────────────────────────────────

  /// Name of the stadium, arena, or venue.
  final String? venue;

  /// Free-form map for sport-specific metadata.
  ///
  /// **Examples:**
  /// - Football: `{"half": 2, "addedTime": 3, "referee": "M. Oliver"}`
  /// - Basketball: `{"currentQuarter": 3, "shotClock": 14}`
  /// - American Football: `{"currentQuarter": "Q4", "down": 3, "yardsToGo": 7}`
  /// - F1: `{"currentLap": 15, "pitStops": 2}`
  /// - MMA: `{"currentRound": 3, "takedownTime": 45}`
  final Map<String, dynamic> extraInfo;

  /// Whether this match is flagged as trending / popular.
  final bool isHot;

  // ── Computed Properties ───────────────────────────────────────────

  /// Whether the match is currently live.
  bool get isLive => status == MatchStatus.live;

  /// Whether the match has finished.
  bool get isFinished => status == MatchStatus.finished;

  /// Whether the match has not started yet.
  bool get isUpcoming => status == MatchStatus.upcoming;

  /// The total number of goals / points scored.
  int? get totalScore {
    if (homeScore == null || awayScore == null) return null;
    return homeScore! + awayScore!;
  }

  /// Goal / point difference (positive = home leading).
  int? get scoreDifference {
    if (homeScore == null || awayScore == null) return null;
    return homeScore! - awayScore!;
  }

  /// Formatted elapsed time string for live matches.
  ///
  /// Returns something like `"67'"` or `"34.2 Ov"` (cricket) depending
  /// on the sport type and available [extraInfo].
  String get formattedElapsedTime {
    if (!isLive) return '';
    if (elapsedMinutes == null) return 'LIVE';

    switch (sportType) {
      case SportType.f1:
        final lap = extraInfo['currentLap']?.toString() ?? '$elapsedMinutes\'';
        return 'Lap $lap';
      default:
        return '$elapsedMinutes\'';
    }
  }

  // ── Serialization ─────────────────────────────────────────────────

  /// Creates a [Match] from a JSON map.
  factory Match.fromJson(Map<String, dynamic> json) {
    return Match(
      id: json['id'] as String,
      sportType: SportTypeX.fromJsonKey(json['sportType'] as String?) ??
          SportType.football,
      league: League.fromJson(json['league'] as Map<String, dynamic>),
      homeTeam: Team.fromJson(json['homeTeam'] as Map<String, dynamic>),
      awayTeam: Team.fromJson(json['awayTeam'] as Map<String, dynamic>),
      homeScore: json['homeScore'] as int?,
      awayScore: json['awayScore'] as int?,
      status: MatchStatusX.fromJsonKey(json['status'] as String?),
      startTime: DateTime.parse(json['startTime'] as String),
      elapsedMinutes: json['elapsedMinutes'] as int?,
      venue: json['venue'] as String?,
      extraInfo: Map<String, dynamic>.from(
        json['extraInfo'] as Map? ?? <String, dynamic>{},
      ),
      isHot: json['isHot'] as bool? ?? false,
      homeScoreDetails: json['homeScoreDetails'] != null
          ? Map<String, int>.from(json['homeScoreDetails'] as Map)
          : null,
      awayScoreDetails: json['awayScoreDetails'] != null
          ? Map<String, int>.from(json['awayScoreDetails'] as Map)
          : null,
    );
  }

  /// Serializes this [Match] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sportType': sportType.jsonKey,
      'league': league.toJson(),
      'homeTeam': homeTeam.toJson(),
      'awayTeam': awayTeam.toJson(),
      'homeScore': homeScore,
      'awayScore': awayScore,
      'status': status.jsonKey,
      'startTime': startTime.toIso8601String(),
      'elapsedMinutes': elapsedMinutes,
      'venue': venue,
      'extraInfo': extraInfo,
      'isHot': isHot,
      'homeScoreDetails': homeScoreDetails,
      'awayScoreDetails': awayScoreDetails,
    };
  }

  /// Creates a copy of this [Match] with the given fields replaced.
  Match copyWith({
    String? id,
    SportType? sportType,
    League? league,
    Team? homeTeam,
    Team? awayTeam,
    int? homeScore,
    int? awayScore,
    MatchStatus? status,
    DateTime? startTime,
    int? elapsedMinutes,
    String? venue,
    Map<String, dynamic>? extraInfo,
    bool? isHot,
    Map<String, int>? homeScoreDetails,
    Map<String, int>? awayScoreDetails,
  }) {
    return Match(
      id: id ?? this.id,
      sportType: sportType ?? this.sportType,
      league: league ?? this.league,
      homeTeam: homeTeam ?? this.homeTeam,
      awayTeam: awayTeam ?? this.awayTeam,
      homeScore: homeScore ?? this.homeScore,
      awayScore: awayScore ?? this.awayScore,
      status: status ?? this.status,
      startTime: startTime ?? this.startTime,
      elapsedMinutes: elapsedMinutes ?? this.elapsedMinutes,
      venue: venue ?? this.venue,
      extraInfo: extraInfo ?? this.extraInfo,
      isHot: isHot ?? this.isHot,
      homeScoreDetails: homeScoreDetails ?? this.homeScoreDetails,
      awayScoreDetails: awayScoreDetails ?? this.awayScoreDetails,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sportType,
        league,
        homeTeam,
        awayTeam,
        homeScore,
        awayScore,
        status,
        startTime,
        elapsedMinutes,
        venue,
        extraInfo,
        isHot,
        homeScoreDetails,
        awayScoreDetails,
      ];

  @override
  String toString() =>
      'Match(id: $id, ${homeTeam.displayName} vs ${awayTeam.displayName}, '
      'status: ${status.name})';
}
