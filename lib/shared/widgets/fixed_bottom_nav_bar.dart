import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';

/// A fixed bottom navigation bar that provides consistent navigation
/// across all screens in the app.
///
/// This widget maintains the selected state and provides visual feedback
/// for the current route. It's designed to be used as a persistent
/// bottom navigation bar in the main scaffold.
class FixedBottomNavBar extends ConsumerWidget {
  const FixedBottomNavBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;
    
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.glassBackground,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        border: Border.all(color: AppColors.glassBorder, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context: context,
                icon: Icons.home_rounded,
                label: 'Home',
                isSelected: currentRoute == '/home',
                onTap: () => context.go('/home'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.explore_rounded,
                label: 'Explore',
                isSelected: currentRoute == '/explore',
                onTap: () => context.go('/explore'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.search_rounded,
                label: 'Search',
                isSelected: currentRoute == '/search',
                onTap: () => context.go('/search'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.favorite_rounded,
                label: 'Favorites',
                isSelected: currentRoute == '/favorites',
                onTap: () => context.go('/favorites'),
              ),
              _buildNavItem(
                context: context,
                icon: Icons.person_rounded,
                label: 'Profile',
                isSelected: currentRoute == '/profile',
                onTap: () => context.go('/profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppColors.footballAccent.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                
                color: isSelected 
                    ? AppColors.footballAccent
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                size: 22,
                color: isSelected 
                    ? Colors.white
                    : AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: isSelected 
                    ? AppColors.footballAccent
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
