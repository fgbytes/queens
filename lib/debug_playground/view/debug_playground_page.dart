import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:queens/app/router/app_routes.dart';

class DebugPlaygroundPage extends StatefulWidget {
  const DebugPlaygroundPage({super.key});

  @override
  State<DebugPlaygroundPage> createState() => _DebugPlaygroundPageState();
}

class _DebugPlaygroundPageState extends State<DebugPlaygroundPage> {
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
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to the Debug Playground',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This area contains temporary test widgets and prototypes.',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.go(AppRoutes.home),
                child: const Text('<- Back to Home'),
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
                onTap: () => context.push('/_debug/game-board'),
              ),
              const SizedBox(height: 16),
              // Resizable Game Board Button
              _buildFeatureButton(
                context,
                title: 'Game Board (Resizable)',
                description: 'Test the game board with size controls',
                icon: Icons.aspect_ratio,
                onTap: () => context.push('/_debug/resizable-game-board'),
              ),
              const SizedBox(height: 16),
              // Counter Button
              _buildFeatureButton(
                context,
                title: 'Counter',
                description: 'The original counter demo screen',
                icon: Icons.add_circle_outline,
                onTap: () => context.push('/_debug/counter'),
              ),
              const SizedBox(height: 16),
              // Main Page Prototype Button
              _buildFeatureButton(
                context,
                title: 'Main Page Prototype',
                description: 'Prototype of the main page UI design',
                icon: Icons.dashboard,
                onTap: () => context.push('/_debug/main-page-prototype'),
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
          padding: const EdgeInsets.all(16),
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
