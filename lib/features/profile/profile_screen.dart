import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

// ── Iconsax extension (mirrors home_screen) ────────────────────────────

class Iconsax {
  static const IconData home_2 = Icons.home;
  static const IconData compass = Icons.explore;
  static const IconData heart = Icons.favorite_border;
  static const IconData heartFilled = Icons.favorite;
  static const IconData user = Icons.person_outline;
  static const IconData notification = Icons.notifications_none_outlined;
  static const IconData searchNormal = Icons.search;
  static const IconData moon = Icons.dark_mode_outlined;
  static const IconData language = Icons.language;
  static const IconData bell = Icons.notifications_active_outlined;
  static const IconData alarm = Icons.alarm;
  static const IconData help = Icons.help_outline;
  static const IconData shield = Icons.shield_outlined;
  static const IconData document = Icons.description_outlined;
  static const IconData star = Icons.star_outline;
  static const IconData info = Icons.info_outline;
  static const IconData logout = Icons.logout;
  static const IconData arrowright = Icons.arrow_forward_ios;
  static const IconData trophy = Icons.emoji_events_outlined;
  static const IconData clipboard = Icons.assignment_outlined;
}

/// The Profile screen — UI-only (no real authentication).
///
/// Displays a profile header with avatar, stats, settings toggles,
/// support links, and a sign-out button. All containers use the
/// glassmorphism design system with smooth staggered animations.
class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  // Settings state
  bool _notificationsEnabled = true;
  final bool _darkModeEnabled = true;
  bool _scoreAlertsEnabled = true;
  bool _matchRemindersEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Profile Header ───────────────────────────────────
            SliverToBoxAdapter(
              child: _buildProfileHeader(),
            ),

            // ── Stats Row ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildStatsRow(),
            ),

            // ── Menu Items ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildSettingsSection(),
            ),

            // ── App Version ────────────────────────────────────────
            SliverToBoxAdapter(
              child: _buildVersionInfo(),
            ),

            // ── Bottom spacing ──────────────────────────────────────
            const SliverToBoxAdapter(
              child: SizedBox(height: 100),
            ),
          ],
        ),
      ),
    );
  }

  // ── Profile Header ──────────────────────────────────────────────────

  Widget _buildProfileHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Title row
          Row(
            children: [
              Text(
                'Profile',
                style: AppTextStyles.headingLarge,
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(
                    begin: -0.2,
                    end: 0,
                    duration: 400.ms,
                    curve: Curves.easeOutCubic,
                  ),
            ],
          ),
          const SizedBox(height: 28),

          // Avatar
          Container(
            width: 96,
            height: 96,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.footballAccent,
                  AppColors.basketballAccent,
                ],
              ),
            ),
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.background,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Container(
                width: 86,
                height: 86,
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.glassBorder,
                    width: 0.5,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  'JD',
                  style: AppTextStyles.headingMedium.copyWith(
                    fontSize: 28,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ),
          )
              .animate()
              .fadeIn(delay: 100.ms, duration: 500.ms)
              .scale(
                begin: const Offset(0.6, 0.6),
                end: const Offset(1.0, 1.0),
                delay: 100.ms,
                duration: 500.ms,
                curve: Curves.elasticOut,
              ),

          const SizedBox(height: 16),

          // Name
          Text(
            'John Doe',
            style: AppTextStyles.headingMedium,
          )
              .animate()
              .fadeIn(delay: 200.ms, duration: 400.ms)
              .slideY(
                begin: 0.1,
                end: 0,
                delay: 200.ms,
                duration: 400.ms,
              ),

          const SizedBox(height: 4),

          // Username
          Text(
            '@johndoe',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
          )
              .animate()
              .fadeIn(delay: 250.ms, duration: 400.ms),

          const SizedBox(height: 4),

          // Member since
          Text(
            'Member since March 2026',
            style: AppTextStyles.caption,
          )
              .animate()
              .fadeIn(delay: 300.ms, duration: 400.ms),
        ],
      ),
    );
  }

  // ── Stats Row ───────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            _buildStatItem(
              value: '12',
              label: 'Favorites',
              icon: Iconsax.heartFilled,
              color: AppColors.errorRed,
              delay: 350,
            ),
            _buildStatDivider(),
            _buildStatItem(
              value: '3',
              label: 'Predictions',
              icon: Iconsax.clipboard,
              color: AppColors.basketballAccent,
              delay: 400,
            ),
            _buildStatDivider(),
            _buildStatItem(
              value: '5',
              label: 'Leagues',
              icon: Iconsax.trophy,
              color: AppColors.footballAccent,
              delay: 450,
            ),
          ],
        ),
      ).animate().fadeIn(delay: 350.ms, duration: 400.ms).slideY(
            begin: 0.05,
            end: 0,
            delay: 350.ms,
            duration: 400.ms,
          ),
    );
  }

  Widget _buildStatItem({
    required String value,
    required String label,
    required IconData icon,
    required Color color,
    required int delay,
  }) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headingSmall.copyWith(
              fontSize: 20,
            ),
          )
              .animate()
              .fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textTertiary,
            ),
          )
              .animate()
              .fadeIn(
                  delay: Duration(milliseconds: delay + 50),
                  duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 36,
      decoration: BoxDecoration(
        color: AppColors.divider,
        borderRadius: BorderRadius.circular(0.5),
      ),
    );
  }

  // ── Settings Section ────────────────────────────────────────────────

  Widget _buildSettingsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 500.ms, duration: 400.ms),
          const SizedBox(height: 12),
          // Notifications toggle
          _buildSettingsToggle(
            icon: Iconsax.notification,
            title: 'Notifications',
            value: _notificationsEnabled,
            onChanged: (v) => setState(() => _notificationsEnabled = v),
            delay: 520,
          ),
          const SizedBox(height: 8),
          // Dark Mode toggle
          _buildSettingsToggle(
            icon: Iconsax.moon,
            title: 'Dark Mode',
            value: _darkModeEnabled,
            onChanged: (_) {
              // Always on in dark theme — just visual feedback
            },
            delay: 560,
          ),
          const SizedBox(height: 8),
          // Language
          _buildSettingsNavigation(
            icon: Iconsax.language,
            title: 'Language',
            trailing: 'English',
            onTap: () {},
            delay: 600,
          ),
          const SizedBox(height: 8),
          // Score Alerts toggle
          _buildSettingsToggle(
            icon: Iconsax.bell,
            title: 'Score Alerts',
            value: _scoreAlertsEnabled,
            onChanged: (v) => setState(() => _scoreAlertsEnabled = v),
            delay: 640,
          ),
          const SizedBox(height: 8),
          // Match Reminders toggle
          _buildSettingsToggle(
            icon: Iconsax.alarm,
            title: 'Match Reminders',
            value: _matchRemindersEnabled,
            onChanged: (v) => setState(() => _matchRemindersEnabled = v),
            delay: 680,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsToggle({
    required IconData icon,
    required String title,
    required bool value,
    required ValueChanged<bool> onChanged,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.glassBorder,
          width: 0.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.surfaceLighter,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: AppColors.textSecondary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              title,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          // Custom-styled toggle
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              width: 48,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: value
                    ? AppColors.footballAccent
                    : AppColors.surfaceLighter,
                border: Border.all(
                  color: value
                      ? AppColors.footballAccent
                      : AppColors.divider,
                  width: 0.5,
                ),
                boxShadow: value
                    ? [
                        BoxShadow(
                          color: AppColors.footballAccent.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                alignment:
                    value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  margin: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: value
                        ? AppColors.textPrimary
                        : AppColors.textTertiary,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: delay), duration: 350.ms)
        .slideX(
          begin: 0.06,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  Widget _buildSettingsNavigation({
    required IconData icon,
    required String title,
    required String trailing,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              trailing,
              style: AppTextStyles.labelMedium.copyWith(
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Iconsax.arrowright,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: delay), duration: 350.ms)
        .slideX(
          begin: 0.06,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ── Support Section ─────────────────────────────────────────────────

  Widget _buildSupportSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Support',
            style: AppTextStyles.labelLarge.copyWith(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          )
              .animate()
              .fadeIn(delay: 700.ms, duration: 400.ms),
          const SizedBox(height: 12),
          _buildSupportItem(
            icon: Iconsax.help,
            title: 'Help Center',
            onTap: () {},
            delay: 720,
          ),
          const SizedBox(height: 8),
          _buildSupportItem(
            icon: Iconsax.shield,
            title: 'Privacy Policy',
            onTap: () {},
            delay: 760,
          ),
          const SizedBox(height: 8),
          _buildSupportItem(
            icon: Iconsax.document,
            title: 'Terms of Service',
            onTap: () {},
            delay: 800,
          ),
          const SizedBox(height: 8),
          _buildSupportItem(
            icon: Iconsax.star,
            title: 'Rate Pulse',
            onTap: () {},
            delay: 840,
          ),
          const SizedBox(height: 8),
          _buildSupportItem(
            icon: Iconsax.info,
            title: 'About',
            trailing: 'v1.0.0',
            onTap: () {},
            delay: 880,
          ),
        ],
      ),
    );
  }

  Widget _buildSupportItem({
    required IconData icon,
    required String title,
    String? trailing,
    required VoidCallback onTap,
    required int delay,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: AppColors.glassBorder,
            width: 0.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.surfaceLighter,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.textSecondary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: AppTextStyles.labelMedium.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
            if (trailing != null) const SizedBox(width: 4),
            const Icon(
              Iconsax.arrowright,
              size: 14,
              color: AppColors.textTertiary,
            ),
          ],
        ),
      ),
    )
        .animate()
        .fadeIn(
            delay: Duration(milliseconds: delay), duration: 350.ms)
        .slideX(
          begin: 0.06,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }

  // ── Sign Out Button ─────────────────────────────────────────────────

  Widget _buildSignOutButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GestureDetector(
        onTap: () => _showSignOutDialog(context),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.errorRed.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.errorRed.withValues(alpha: 0.2),
              width: 0.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Iconsax.logout,
                size: 20,
                color: AppColors.errorRed,
              ),
              const SizedBox(width: 8),
              Text(
                'Sign Out',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.errorRed,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .fadeIn(delay: 900.ms, duration: 400.ms)
          .slideY(
            begin: 0.05,
            end: 0,
            delay: 900.ms,
            duration: 400.ms,
          ),
    );
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.divider, width: 0.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.errorRed.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Iconsax.logout,
                  size: 28,
                  color: AppColors.errorRed,
                ),
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.5, 0.5),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(height: 16),
              Text(
                'Sign Out',
                style: AppTextStyles.headingSmall,
              ),
              const SizedBox(height: 8),
              Text(
                'Are you sure you want to sign out? You can always sign back in.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(ctx),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceLight,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.glassBorder,
                            width: 0.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pop(ctx);
                        // In production, would call auth service
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text('Signed out successfully'),
                            backgroundColor: AppColors.surfaceLight,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(
                                color: AppColors.divider,
                                width: 0.5,
                              ),
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: AppColors.errorRed,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            'Sign Out',
                            style: AppTextStyles.labelLarge.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Version Info ────────────────────────────────────────────────────

  Widget _buildVersionInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Center(
        child: Text(
          'Pulse v1.0.0',
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textTertiary,
          ),
        ).animate().fadeIn(delay: 950.ms, duration: 400.ms),
      ),
    );
  }

  // ── Bottom Navigation ───────────────────────────────────────────────

  Widget _buildBottomNav(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(
            icon: Iconsax.home_2,
            label: 'Home',
            isSelected: false,
            onTap: () => context.go('/home'),
          ),
          _buildNavItem(
            icon: Iconsax.compass,
            label: 'Explore',
            isSelected: false,
            onTap: () => context.go('/explore'),
          ),
          _buildNavItem(
            icon: Iconsax.heart,
            label: 'Favorites',
            isSelected: false,
            onTap: () => context.go('/favorites'),
          ),
          _buildNavItem(
            icon: Iconsax.user,
            label: 'Profile',
            isSelected: true,
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final accentColor =
        isSelected ? AppColors.footballAccent : AppColors.textTertiary;
    final iconColor =
        isSelected ? AppColors.footballAccent : AppColors.textTertiary;

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.footballAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 22, color: iconColor),
            const SizedBox(height: 2),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: accentColor,
                fontWeight:
                    isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
