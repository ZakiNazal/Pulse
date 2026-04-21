import 'package:flutter/material.dart';

/// Centralized color tokens for the Pulse app dark theme.
///
/// Every color lives here so the rest of the codebase references a single
/// source of truth. Use these constants in widgets, canvas painting, and
/// any other visual layer.
@immutable
class AppColors {
  const AppColors._();

  // ── Background ────────────────────────────────────────────────────

  /// Deepest background – used by [Scaffold] and full-bleed pages.
  static const Color background = Color(0xFF0A0A0F);

  /// Elevated surface – cards, bottom sheets, dialogs.
  static const Color surface = Color(0xFF14141F);

  /// Lighter surface variant – list tiles, input fields.
  static const Color surfaceLight = Color(0xFF1E1E2E);

  /// Lightest surface variant – hovered / pressed states.
  static const Color surfaceLighter = Color(0xFF2A2A3E);

  // ── Text ──────────────────────────────────────────────────────────

  /// Primary text on dark surfaces.
  static const Color textPrimary = Color(0xFFFFFFFF);

  /// Secondary / supporting text.
  static const Color textSecondary = Color(0xFF9CA3AF);

  /// Tertiary / disabled / placeholder text.
  static const Color textTertiary = Color(0xFF6B7280);

  // ── Semantic ──────────────────────────────────────────────────────

  /// Pulsing indicator for live matches and notifications.
  static const Color liveRed = Color(0xFFEF4444);

  /// Positive outcomes – wins, online status, confirmations.
  static const Color successGreen = Color(0xFF22C55E);

  /// Errors, losses, destructive actions.
  static const Color errorRed = Color(0xFFDC2626);

  /// Warning / caution.
  static const Color warningAmber = Color(0xFFF59E0B);

  // ── Glass Effect ──────────────────────────────────────────────────

  /// Semi-transparent white for glassmorphism fills.
  static const Color glassBackground = Color(0x1AFFFFFF);

  /// Semi-transparent white for glassmorphism borders.
  static const Color glassBorder = Color(0x33FFFFFF);

  // ── Structural ────────────────────────────────────────────────────

  /// Thin divider lines between sections.
  static const Color divider = Color(0x1FFFFFFF);

  /// Subtle shadow for elevated elements.
  static const Color shadow = Color(0x40000000);

  // ── Sport Accent Colors ───────────────────────────────────────────

  /// Football accent – vibrant green.
  static const Color footballAccent = Color(0xFF22C55E);

  /// Basketball accent – warm orange.
  static const Color basketballAccent = Color(0xFFF97316);

  /// American Football accent – bold red.
  static const Color americanFootballAccent = Color(0xFFEF4444);

  /// F1 accent – bold red.
  static const Color f1Accent = Color(0xFFEF4444);

  /// MMA accent – neutral grey.
  static const Color mmaAccent = Color(0xFF6B7280);

  /// Tennis accent – vibrant yellow.
  static const Color tennisAccent = Color(0xFFEAB308);

  /// MMA gradient (grey spectrum).
  static const LinearGradient mmaGradient = LinearGradient(
    colors: [Color(0xFF6B7280), Color(0xFF424242)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// F1 gradient (red spectrum).
  static const LinearGradient f1Gradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFB71C1C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Sport Accent Colors ────────────────────────────────────────────

  /// Football gradient (green spectrum).
  static const LinearGradient footballGradient = LinearGradient(
    colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Basketball gradient (orange spectrum).
  static const LinearGradient basketballGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEA580C)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Tennis gradient (yellow spectrum).
  static const LinearGradient tennisGradient = LinearGradient(
    colors: [Color(0xFFEAB308), Color(0xFFCA8A04)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Cricket gradient (blue spectrum).
  static const LinearGradient cricketGradient = LinearGradient(
    colors: [Color(0xFF2196F3), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// American Football gradient (red spectrum).
  static const LinearGradient americanFootballGradient = LinearGradient(
    colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Esports gradient (purple spectrum).
  static const LinearGradient esportsGradient = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF9333EA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Helpers ───────────────────────────────────────────────────────

  /// Returns primary accent [Color] for the given sport index.
  ///
  /// The index corresponds to position in [SportType.values].
  static const List<Color> sportAccents = [
    footballAccent,
    basketballAccent,
    americanFootballAccent,
    f1Accent,
    mmaAccent,
    tennisAccent,
  ];

  /// Returns [LinearGradient] associated with the given sport index.
  static const List<LinearGradient> sportGradients = [
    footballGradient,
    basketballGradient,
    americanFootballGradient,
    f1Gradient,
    mmaGradient,
    tennisGradient,
  ];
}
