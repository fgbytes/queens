import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:queens/achievements/view/achievements_page.dart';
// Import the new route definitions
import 'package:queens/app/router/app_routes.dart';
// Import existing pages (keeping debug routes for now)
import 'package:queens/counter/counter.dart';
import 'package:queens/debug_playground/view/debug_playground_page.dart';
import 'package:queens/debug_playground/view/main_page_prototype.dart';
import 'package:queens/game/view/game_page.dart';
// Import the new pages
import 'package:queens/home/view/home_page.dart';
import 'package:queens/levels/view/levels_page.dart';
import 'package:queens/settings/view/settings_page.dart';

// Define the route paths - REMOVED as it's now in app_routes.dart
// class AppRoutes { ... }

// Create the router configuration
final GoRouter router = GoRouter(
  initialLocation: AppRoutes.home, // Set home as the initial route
  routes: <RouteBase>[
    // Main App Routes
    GoRoute(
      path: AppRoutes.home,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: AppRoutes.achievements,
      builder: (context, state) => const AchievementsPage(),
    ),
    GoRoute(
      path: AppRoutes.levels,
      builder: (context, state) => const LevelsPage(),
    ),
    GoRoute(
      path: AppRoutes.game,
      builder: (context, state) => const GamePage(),
    ),
    GoRoute(
      path: AppRoutes.settings,
      builder: (context, state) => const SettingsPage(),
    ),

    // Existing Debug Routes (Consider moving under a /debug prefix later)
    GoRoute(
      path:
          '/_debugPlayground', // Renamed path slightly to avoid conflict with '/'
      builder: (context, state) => const DebugPlaygroundPage(),
    ),
    GoRoute(
      path: '/_debug/main-page-prototype', // Renamed path
      builder: (context, state) => const MainPagePrototype(),
    ),
    GoRoute(
      path: '/_debug/counter', // Renamed path
      builder: (context, state) => const CounterPage(),
    ),
  ],
  // Optional: Add error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(child: Text('Error: ${state.error}')),
  ),
);
