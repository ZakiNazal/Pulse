import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Centralized text-style tokens for the Pulse app.
///
/// All styles use the Inter typeface for body / UI text and Space Grotesk
/// for scores and numeric displays. Every style is dark-theme-ready and
/// references [AppColors] for its color values.
@immutable
class AppTextStyles {
  const AppTextStyles._();

  // ── Headings (Space Grotesk) ──────────────────────────────────────

  /// Page-level hero heading (e.g. "Live Matches").
  static final TextStyle headingLarge = GoogleFonts.spaceGrotesk(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  /// Section heading (e.g. "Premier League").
  static final TextStyle headingMedium = GoogleFonts.spaceGrotesk(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  /// Sub-section heading (e.g. team name in a card).
  static final TextStyle headingSmall = GoogleFonts.spaceGrotesk(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // ── Body (Inter) ──────────────────────────────────────────────────

  /// Primary body text – paragraphs, descriptions.
  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Standard body text – list items, card content.
  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textPrimary,
  );

  /// Small body text – secondary info within cards.
  static final TextStyle bodySmall = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.textSecondary,
  );

  // ── Labels (Inter) ────────────────────────────────────────────────

  /// Prominent label – badges, chips, tab labels.
  static final TextStyle labelLarge = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.textPrimary,
    letterSpacing: 0.1,
  );

  /// Standard label – button text, menu items.
  static final TextStyle labelMedium = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
    letterSpacing: 0.2,
  );

  /// Small label – timestamps, metadata.
  static final TextStyle labelSmall = GoogleFonts.inter(
    fontSize: 10,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textTertiary,
    letterSpacing: 0.3,
  );

  // ── Score Display (Space Grotesk) ────────────────────────────────

  /// Extra-large score number for match cards and detail headers.
  ///
  /// Uses Space Grotesk at a heavy weight for a monospace-inspired,
  /// sporty feel.
  static final TextStyle scoreStyle = GoogleFonts.spaceGrotesk(
    fontSize: 36,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.textPrimary,
    letterSpacing: -1.0,
  );

  /// Slightly smaller score variant for compact list items.
  static final TextStyle scoreStyleSmall = GoogleFonts.spaceGrotesk(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.0,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  // ── Caption ───────────────────────────────────────────────────────

  /// Tiny helper text – disclaimers, version info.
  static final TextStyle caption = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.textTertiary,
    letterSpacing: 0.2,
  );

  // ── Live Badge ────────────────────────────────────────────────────

  /// Bold red style used for the "LIVE" indicator dot + label.
  static final TextStyle liveBadge = GoogleFonts.inter(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    height: 1.2,
    color: AppColors.liveRed,
    letterSpacing: 0.8,
  );

  // ── helpers ───────────────────────────────────────────────────────

  /// Returns a copy of [style] with [color] replaced.
  ///
  /// Useful for one-off overrides without polluting the constant definitions.
  static TextStyle withColor(TextStyle style, Color color) {
    return style.copyWith(color: color);
  }

  /// Returns a copy of [style] with [fontWeight] replaced.
  static TextStyle withWeight(TextStyle style, FontWeight weight) {
    return style.copyWith(fontWeight: weight);
  }
}
