import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/app_theme.dart';
import '../widgets/app_router_wrapper.dart';

/// Root widget for the Pulse sports app.
///
/// Configures [MaterialApp.router] with a dark-only theme and a [GoRouter]
/// instance that manages navigation between all screens.
class PulseApp extends StatelessWidget {
  const PulseApp({super.key});

  // ── Router ────────────────────────────────────────────────────────────

  static final GoRouter _router = AppRouterWrapper.router;

  // ── Build ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.dark,
      routerConfig: _router,
    );
  }
}
