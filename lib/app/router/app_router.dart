import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:queens/counter/counter.dart'; // Import your CounterPage
import 'package:queens/debug_playground/view/debug_playground_page.dart'; // Import playground
import 'package:queens/debug_playground/view/game_board_page.dart'; // Import game board
import 'package:queens/debug_playground/view/resizable_game_board_page.dart'; // Import the new page

// Define the route paths
class AppRoutes {
  static const String counter = '/counter'; // Changed from '/'
  static const String debugPlayground = '/'; // New initial route
  static const String gameBoard = '/debug/game-board'; // Path for game board
  static const String resizableGameBoard =
      '/debug/resizable-game-board'; // New route path
  // Add other route paths here
}

// Create the router configuration
final GoRouter router = GoRouter(
  initialLocation: AppRoutes.debugPlayground, // Set playground as initial route
  routes: <RouteBase>[
    // Debug Playground Route
    GoRoute(
      path: AppRoutes.debugPlayground,
      builder: (BuildContext context, GoRouterState state) {
        return const DebugPlaygroundPage();
      },
      // Nested routes within debug if needed later
    ),
    // Game Board Route (can be top-level or nested under debug)
    GoRoute(
      path: AppRoutes.gameBoard,
      builder: (BuildContext context, GoRouterState state) {
        return const GameBoardPage();
      },
    ),
    // Resizable Game Board Route (New)
    GoRoute(
      path: AppRoutes.resizableGameBoard,
      builder: (BuildContext context, GoRouterState state) {
        return const ResizableGameBoardPage(); // Map to the new page
      },
    ),
    // Original Counter Route
    GoRoute(
      path: AppRoutes.counter,
      builder: (BuildContext context, GoRouterState state) {
        return const CounterPage(); // Map the path to CounterPage
      },
      // If you had sub-routes for counter, they would go here:
      // routes: <RouteBase>[
      //   GoRoute(
      //     path: 'details',
      //     builder: (BuildContext context, GoRouterState state) {
      //       return const CounterDetailsScreen();
      //     },
      //   ),
      // ],
    ),
    // Add other top-level routes here:
    // GoRoute(
    //   path: AppRoutes.settings,
    //   builder: (BuildContext context, GoRouterState state) {
    //     return const SettingsPage();
    //   },
    // ),
  ],
  // Optional: Add error handling
  errorBuilder: (context, state) => Scaffold(
    appBar: AppBar(title: const Text('Page Not Found')),
    body: Center(child: Text('Error: ${state.error}')),
  ),
);
