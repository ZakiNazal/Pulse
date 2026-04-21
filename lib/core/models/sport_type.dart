import 'package:flutter/material.dart';

/// Represents the types of sports supported by the Pulse app.
enum SportType {
  football,
  basketball,
  americanFootball,
  f1,
  mma,
  tennis,
}

/// Extension methods on [SportType] for display properties and theming.
extension SportTypeX on SportType {
  /// Human-readable display name for the sport.
  String get displayName {
    switch (this) {
      case SportType.football:
        return 'Football';
      case SportType.basketball:
        return 'Basketball';
      case SportType.americanFootball:
        return 'American Football';
      case SportType.f1:
        return 'Formula 1';
      case SportType.mma:
        return 'MMA';
      case SportType.tennis:
        return 'Tennis';
    }
  }

  /// Short display name (≤ 3 characters) for compact UI elements.
  String get shortName {
    switch (this) {
      case SportType.football:
        return 'FUT';
      case SportType.basketball:
        return 'BKT';
      case SportType.americanFootball:
        return 'NFL';
      case SportType.f1:
        return 'F1';
      case SportType.mma:
        return 'MMA';
      case SportType.tennis:
        return 'TEN';
    }
  }

  /// Asset path to the sport icon SVG.
  String get icon => 'assets/sports/$name.svg';

  /// Emoji representation of the sport.
  String get emoji {
    switch (this) {
      case SportType.football:
        return '⚽';
      case SportType.basketball:
        return '🏀';
      case SportType.americanFootball:
        return '🏈';
      case SportType.f1:
        return '🏎️';
      case SportType.mma:
        return '🥊';
      case SportType.tennis:
        return '🎾';
    }
  }

  /// Primary [MaterialColor] accent for the sport.
  MaterialColor get accentColor {
    switch (this) {
      case SportType.football:
        return Colors.green;
      case SportType.basketball:
        return Colors.orange;
      case SportType.americanFootball:
        return Colors.red;
      case SportType.f1:
        return Colors.red;
      case SportType.mma:
        return Colors.grey;
      case SportType.tennis:
        return Colors.yellow;
    }
  }

  /// Primary [Color] shade (500) for quick access.
  Color get color => accentColor;

  /// JSON-safe string key used for serialization.
  String get jsonKey => name;

  /// Parses a [SportType] from a JSON string key.
  ///
  /// Returns `null` if the string does not match any known sport.
  static SportType? fromJsonKey(String? key) {
    if (key == null) return null;
    return SportType.values.byName(key);
  }
}
