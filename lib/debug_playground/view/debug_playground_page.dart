import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:queens/app/router/app_router.dart';

class DebugPlaygroundPage extends StatelessWidget {
  const DebugPlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Queens Debug Playground'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to the Debug Playground',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This is the starting page of the app, used for testing features.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              const Text(
                'Testing Features:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Game Board Button
              _buildFeatureButton(
                context,
                title: 'Game Board (Fixed)',
                description:
                    'Test the Queens game board implementation (10x10)',
                icon: Icons.grid_on,
                onTap: () => context.push(AppRoutes.gameBoard),
              ),
              const SizedBox(height: 16),
              // Resizable Game Board Button (New)
              _buildFeatureButton(
                context,
                title: 'Game Board (Resizable)',
                description: 'Test the game board with size controls',
                icon: Icons.aspect_ratio,
                onTap: () =>
                    context.push(AppRoutes.resizableGameBoard), // New route
              ),
              const SizedBox(height: 16),
              // Counter Button (original feature)
              _buildFeatureButton(
                context,
                title: 'Counter',
                description: 'The original counter demo screen',
                icon: Icons.add_circle_outline,
                onTap: () => context.push(AppRoutes.counter),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureButton(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(description),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios),
            ],
          ),
        ),
      ),
    );
  }
}
