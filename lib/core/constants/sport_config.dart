// ignore_for_file: unused_field

import 'package:flutter/material.dart';
import '../models/league.dart';
import '../models/sport_type.dart';
import 'app_colors.dart';

/// Immutable configuration entry for a single sport.
@immutable
class SportConfigEntry {
  const SportConfigEntry({
    required this.sportType,
    required this.accentColor,
    required this.gradient,
    required this.iconPath,
    required this.popularLeagues,
  });

  final SportType sportType;
  final Color accentColor;
  final LinearGradient gradient;
  final String iconPath;
  final List<League> popularLeagues;
}

/// Centralized per-sport configuration registry.
///
/// Provides quick access to accent colors, gradients, icons, and popular
/// league data for each [SportType]. The mock league data is intended for
/// demo / development purposes only.
class SportConfig {
  SportConfig._();

  // ── Football ──────────────────────────────────────────────────────

  static const _footballLeagues = [
    _MockLeague(
      id: 'pl',
      name: 'Premier League',
      country: 'England',
      sportKey: 'football',
      flagCode: 'gb-eng',
    ),
    _MockLeague(
      id: 'laliga',
      name: 'La Liga',
      country: 'Spain',
      sportKey: 'football',
      flagCode: 'es',
    ),
    _MockLeague(
      id: 'seriea',
      name: 'Serie A',
      country: 'Italy',
      sportKey: 'football',
      flagCode: 'it',
    ),
    _MockLeague(
      id: 'bundesliga',
      name: 'Bundesliga',
      country: 'Germany',
      sportKey: 'football',
      flagCode: 'de',
    ),
    _MockLeague(
      id: 'ligue1',
      name: 'Ligue 1',
      country: 'France',
      sportKey: 'football',
      flagCode: 'fr',
    ),
    _MockLeague(
      id: 'ucl',
      name: 'UEFA Champions League',
      country: 'Europe',
      sportKey: 'football',
      flagCode: 'eu',
    ),
  ];

  // ── Basketball ────────────────────────────────────────────────────

  static const _basketballLeagues = [
    _MockLeague(
      id: 'nba',
      name: 'NBA',
      country: 'USA',
      sportKey: 'basketball',
      flagCode: 'us',
    ),
    _MockLeague(
      id: 'euroleague',
      name: 'EuroLeague',
      country: 'Europe',
      sportKey: 'basketball',
      flagCode: 'eu',
    ),
    _MockLeague(
      id: 'acb',
      name: 'Liga ACB',
      country: 'Spain',
      sportKey: 'basketball',
      flagCode: 'es',
    ),
    _MockLeague(
      id: 'wnba',
      name: 'WNBA',
      country: 'USA',
      sportKey: 'basketball',
      flagCode: 'us',
    ),
  ];

  // ── Tennis ────────────────────────────────────────────────────────

  static const _tennisLeagues = [
    _MockLeague(
      id: 'atp',
      name: 'ATP Tour',
      country: 'International',
      sportKey: 'tennis',
      flagCode: 'un',
    ),
    _MockLeague(
      id: 'wta',
      name: 'WTA Tour',
      country: 'International',
      sportKey: 'tennis',
      flagCode: 'un',
    ),
    _MockLeague(
      id: 'itf',
      name: 'ITF',
      country: 'International',
      sportKey: 'tennis',
      flagCode: 'un',
    ),
  ];

  // ── Cricket ───────────────────────────────────────────────────────

  static const _cricketLeagues = [
    _MockLeague(
      id: 'ipl',
      name: 'Indian Premier League',
      country: 'India',
      sportKey: 'cricket',
      flagCode: 'in',
    ),
    _MockLeague(
      id: 'bbl',
      name: 'Big Bash League',
      country: 'Australia',
      sportKey: 'cricket',
      flagCode: 'au',
    ),
    _MockLeague(
      id: 'cpl',
      name: 'Caribbean Premier League',
      country: 'West Indies',
      sportKey: 'cricket',
      flagCode: 'wi',
    ),
    _MockLeague(
      id: 'psl',
      name: 'Pakistan Super League',
      country: 'Pakistan',
      sportKey: 'cricket',
      flagCode: 'pk',
    ),
    _MockLeague(
      id: 'theAshes',
      name: 'The Ashes',
      country: 'England / Australia',
      sportKey: 'cricket',
      flagCode: 'gb',
    ),
  ];

  // ── American Football ─────────────────────────────────────────────

  static const _americanFootballLeagues = [
    _MockLeague(
      id: 'nfl',
      name: 'NFL',
      country: 'USA',
      sportKey: 'americanFootball',
      flagCode: 'us',
    ),
    _MockLeague(
      id: 'ncaa',
      name: 'NCAA College Football',
      country: 'USA',
      sportKey: 'americanFootball',
      flagCode: 'us',
    ),
    _MockLeague(
      id: 'cfl',
      name: 'CFL',
      country: 'Canada',
      sportKey: 'americanFootball',
      flagCode: 'ca',
    ),
  ];

  // ── Esports ───────────────────────────────────────────────────────

  static const _esportsLeagues = [
    _MockLeague(
      id: 'lck',
      name: 'LCK',
      country: 'South Korea',
      sportKey: 'esports',
      flagCode: 'kr',
    ),
    _MockLeague(
      id: 'lcs',
      name: 'LCS',
      country: 'USA',
      sportKey: 'esports',
      flagCode: 'us',
    ),
    _MockLeague(
      id: 'vct',
      name: 'VCT',
      country: 'International',
      sportKey: 'esports',
      flagCode: 'un',
    ),
    _MockLeague(
      id: 'blast',
      name: 'BLAST Premier',
      country: 'International',
      sportKey: 'esports',
      flagCode: 'un',
    ),
  ];

  // ── F1 ───────────────────────────────────────────────────────

  static const _f1Leagues = [
    _MockLeague(
      id: 'f1',
      name: 'Formula 1',
      country: 'International',
      sportKey: 'f1',
      flagCode: 'un',
    ),
  ];

  // ── MMA ───────────────────────────────────────────────────────

  static const _mmaLeagues = [
    _MockLeague(
      id: 'ufc',
      name: 'UFC',
      country: 'USA',
      sportKey: 'mma',
      flagCode: 'us',
    ),
  ];

  // ── Configuration Map ─────────────────────────────────────────────

  /// Pre-built configuration map keyed by [SportType].
  static final Map<SportType, SportConfigEntry> _configs = {
    SportType.football: SportConfigEntry(
      sportType: SportType.football,
      accentColor: AppColors.footballAccent,
      gradient: AppColors.footballGradient,
      iconPath: 'assets/sports/football.svg',
      popularLeagues: _footballLeagues.map(_mockToLeague).toList(),
    ),
    SportType.basketball: SportConfigEntry(
      sportType: SportType.basketball,
      accentColor: AppColors.basketballAccent,
      gradient: AppColors.basketballGradient,
      iconPath: 'assets/sports/basketball.svg',
      popularLeagues: _basketballLeagues.map(_mockToLeague).toList(),
    ),
    SportType.americanFootball: SportConfigEntry(
      sportType: SportType.americanFootball,
      accentColor: AppColors.americanFootballAccent,
      gradient: AppColors.americanFootballGradient,
      iconPath: 'assets/sports/americanFootball.svg',
      popularLeagues: _americanFootballLeagues.map(_mockToLeague).toList(),
    ),
    SportType.f1: SportConfigEntry(
      sportType: SportType.f1,
      accentColor: AppColors.f1Accent,
      gradient: AppColors.f1Gradient,
      iconPath: 'assets/sports/f1.svg',
      popularLeagues: _f1Leagues.map(_mockToLeague).toList(),
    ),
    SportType.mma: SportConfigEntry(
      sportType: SportType.mma,
      accentColor: AppColors.mmaAccent,
      gradient: AppColors.mmaGradient,
      iconPath: 'assets/sports/mma.svg',
      popularLeagues: _mmaLeagues.map(_mockToLeague).toList(),
    ),
    SportType.tennis: SportConfigEntry(
      sportType: SportType.tennis,
      accentColor: AppColors.tennisAccent,
      gradient: AppColors.tennisGradient,
      iconPath: 'assets/sports/tennis.svg',
      popularLeagues: _tennisLeagues.map(_mockToLeague).toList(),
    ),
  };

  // ── Public API ────────────────────────────────────────────────────

  /// Returns the [SportConfigEntry] for the given [sportType].
  ///
  /// Throws an [ArgumentError] if the sport type is not configured.
  static SportConfigEntry forSport(SportType sportType) {
    final config = _configs[sportType];
    if (config == null) {
      throw ArgumentError('No configuration found for $sportType');
    }
    return config;
  }

  /// Returns the accent [Color] for the given [sportType].
  static Color accentColor(SportType sportType) =>
      forSport(sportType).accentColor;

  /// Returns the [LinearGradient] for the given [sportType].
  static LinearGradient gradient(SportType sportType) =>
      forSport(sportType).gradient;

  /// Returns the icon asset path for the given [sportType].
  static String iconPath(SportType sportType) =>
      forSport(sportType).iconPath;

  /// Returns the list of popular [League] objects for the given [sportType].
  static List<League> popularLeagues(SportType sportType) =>
      forSport(sportType).popularLeagues;

  /// A simple ordered list of all supported sport types.
  static const List<SportType> allSports = SportType.values;

  /// The full configuration map (read-only).
  static Map<SportType, SportConfigEntry> get configs =>
      Map.unmodifiable(_configs);

  // ── Internal Helpers ──────────────────────────────────────────────

  /// Converts a [_MockLeague] private const into a real [League] instance.
  static League _mockToLeague(_MockLeague mock) {
    return League(
      id: mock.id,
      name: mock.name,
      country: mock.country,
      sportType: SportTypeX.fromJsonKey(mock.sportKey) ?? SportType.football,
      logo: null,
      flag: 'assets/flags/${mock.flagCode}.svg',
    );
  }
}

// ── Private helper for compile-time const league data ────────────────

/// Lightweight const-safe representation used to build mock [League] data.
class _MockLeague {
  const _MockLeague({
    required this.id,
    required this.name,
    required this.country,
    required this.sportKey,
    required this.flagCode,
  });

  final String id;
  final String name;
  final String country;
  final String sportKey;
  final String flagCode;
}
