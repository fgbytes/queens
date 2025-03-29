import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:queens/app/router/app_routes.dart';

class LevelsPage extends StatelessWidget {
  const LevelsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Levels'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Select Difficulty or Level'),
            const SizedBox(height: 20),
            // Placeholder button to navigate to the actual game board
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.game),
              child: const Text('Start Level 1 (Game)'),
            ),
          ],
        ),
      ),
    );
  }
}
