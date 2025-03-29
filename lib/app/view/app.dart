import 'package:flutter/material.dart';
// import 'package:queens/counter/counter.dart'; // No longer needed here
import 'package:queens/l10n/l10n.dart';
import 'package:queens/theme/app_theme.dart';
import 'package:queens/app/router/app_router.dart'; // Import the router

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Create an instance of MaterialTheme
    final materialTheme = MaterialTheme();

    // Use MaterialApp.router
    return MaterialApp.router(
      // Router configuration
      routerConfig: router, // Provide the router configuration

      // Theme configuration (remains the same)
      theme: materialTheme.light(context),
      darkTheme: materialTheme.dark(context),
      themeMode: ThemeMode.system,

      // Localization configuration (remains the same)
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      // home: const CounterPage(), // Remove the home property
    );
  }
}
