import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app.dart';

/// Entry point for the Pulse sports app.
///
/// Wraps the entire widget tree in a [ProviderScope] so that every screen
/// and widget can access Riverpod providers for state management.
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: PulseApp()));
}
