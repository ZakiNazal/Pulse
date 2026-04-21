import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/auth_screen.dart';
import '../../features/explore/explore_screen.dart';
import '../../features/favorites/favorites_screen.dart';
import '../../features/home/home_screen.dart';
import '../../features/match_details/match_details_screen.dart';
import '../../features/profile/profile_screen.dart';
import '../../features/search/search_screen.dart';
import '../../features/splash/splash_screen.dart';
import '../../shared/widgets/fixed_bottom_nav_bar.dart';
import '../constants/app_colors.dart';

/// A wrapper widget that provides a consistent layout with fixed bottom navigation
/// for all main screens in the app.
///
/// This widget automatically shows/hides the bottom navigation based on the current route.
/// Screens like splash, auth, and match details don't show the bottom nav.
class MainScreenWrapper extends ConsumerWidget {
  const MainScreenWrapper({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentRoute = GoRouterState.of(context).uri.path;
    
    // Routes that should NOT show bottom navigation
    final routesWithoutBottomNav = {
      '/splash',
      '/auth',
    };
    
    // Match details route pattern (e.g., '/match/123')
    final isMatchDetailsRoute = currentRoute.startsWith('/match/');
    
    final shouldShowBottomNav = !routesWithoutBottomNav.contains(currentRoute) && 
                              !isMatchDetailsRoute;

    if (shouldShowBottomNav) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: child,
        bottomNavigationBar: const FixedBottomNavBar(),
      );
    } else {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: child,
      );
    }
  }
}

/// Enhanced app router that wraps all routes with the MainScreenWrapper
class AppRouterWrapper {
  static GoRouter get router => _buildRouter();

  static GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/splash',
      debugLogDiagnostics: true,
      routes: [
        // ── Splash ──────────────────────────────────────────────────────
        GoRoute(
          path: '/splash',
          pageBuilder: (context, state) => _buildNoTransitionPage(
            context: context,
            state: state,
            child: const MainScreenWrapper(
              child: SplashScreen(),
            ),
          ),
        ),

        // ── Auth ────────────────────────────────────────────────────────
        GoRoute(
          path: '/auth',
          pageBuilder: (context, state) => _buildNoTransitionPage(
            context: context,
            state: state,
            child: const MainScreenWrapper(
              child: AuthScreen(),
            ),
          ),
        ),

        // ── Home ────────────────────────────────────────────────────────
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => _buildFadeSlideUpPage(
            context: context,
            state: state,
            child: const MainScreenWrapper(
              child: HomeScreen(),
            ),
          ),
        ),

        // ── Match Details ───────────────────────────────────────────────
        GoRoute(
          path: '/match/:id',
          pageBuilder: (context, state) {
            final matchId = state.pathParameters['id']!;
            return _buildFadeSlideUpPage(
              context: context,
              state: state,
              child: MainScreenWrapper(
                child: MatchDetailsScreen(matchId: matchId),
              ),
            );
          },
        ),

        // ── Explore ─────────────────────────────────────────────────────
        GoRoute(
          path: '/explore',
          pageBuilder: (context, state) => _buildFadeSlideUpPage(
            context: context,
            state: state,
            child: const MainScreenWrapper(
              child: ExploreScreen(),
            ),
          ),
        ),

        // ── Search ──────────────────────────────────────────────────────
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => _buildFadePage(
            context: context,
            state: state,
            child: const MainScreenWrapper(
              child: SearchScreen(),
            ),
          ),
        ),

        // ── Favorites ───────────────────────────────────────────────────
        GoRoute(
          path: '/favorites',
          pageBuilder: (context, state) => _buildFadeSlideUpPage(
            context: context,
            state: state,
            child: const MainScreenWrapper(
              child: FavoritesScreen(),
            ),
          ),
        ),

        // ── Profile ─────────────────────────────────────────────────────
        GoRoute(
          path: '/profile',
          pageBuilder: (context, state) => _buildFadeSlideUpPage(
            context: context,
            state: state,
            child: const MainScreenWrapper(
              child: ProfileScreen(),
            ),
          ),
        ),
      ],

      // ── Error / 404 ────────────────────────────────────────────────────
      errorPageBuilder: (context, state) => _buildFadePage(
        context: context,
        state: state,
        child: MainScreenWrapper(
          child: Scaffold(
            backgroundColor: const Color(0xFF0A0A0F),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.sports,
                    size: 64,
                    color: Color(0xFF6B7280),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Page Not Found',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: const Color(0xFFFFFFFF),
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'The route "${state.uri.path}" does not exist.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: const Color(0xFF9CA3AF),
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => context.go('/home'),
                    child: const Text('Go Home'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Custom Page Builders ──────────────────────────────────────────────

  /// No transition — instant switch (used for splash screen).
  static Page<void> _buildNoTransitionPage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: Duration.zero,
      reverseTransitionDuration: Duration.zero,
      transitionsBuilder: (context, animation, secondaryAnimation, child) =>
          child,
    );
  }

  /// Fade transition only (300 ms, ease-out-cubic).
  static Page<void> _buildFadePage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: child,
        );
      },
    );
  }

  /// Fade + slide up from bottom (300 ms, ease-out-cubic).
  ///
  /// Produces premium feel of a modal sheet sliding in while fading.
  static Page<void> _buildFadeSlideUpPage({
    required BuildContext context,
    required GoRouterState state,
    required Widget child,
  }) {
    final tween = Tween(begin: const Offset(0, 0.08), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic));

    return CustomTransitionPage<void>(
      key: state.pageKey,
      child: child,
      transitionDuration: const Duration(milliseconds: 300),
      reverseTransitionDuration: const Duration(milliseconds: 300),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          ),
          child: SlideTransition(
            position: animation.drive(tween),
            child: child,
          ),
        );
      },
    );
  }
}
