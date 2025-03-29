import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:queens/app/router/app_routes.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;

    // Apply dark status bar icons for better contrast on light background
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark, // Use dark icons
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          bottom: false,
          child: ShaderMask(
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black,
                  Colors.black,
                ],
                stops: const [0.0, 0.05, 1.0],
                tileMode: TileMode.clamp,
              ).createShader(bounds);
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section (from prototype)
                  _buildHeader(context),

                  // Daily Challenge Section (from prototype)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 4),
                    child: Text(
                      'Daily Challenge',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '14,525 joined',
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 160,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      children: [
                        _buildCountryItem(context, 'Egypt', '25 lvls'),
                        _buildCountryItem(context, 'Russia', '35 lvls'),
                        _buildCountryItem(context, 'UK', '70 lvls'),
                        _buildCountryItem(context, 'France', '45 lvls'),
                      ],
                    ),
                  ),

                  // Levels Section (from prototype)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 30, 16, 4),
                    child: Text(
                      'Levels',
                      style: textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 36,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      '14,525 joined',
                      style: textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildDifficultyCard(
                          context,
                          'Easy',
                          '1459/2000',
                          Colors.green.shade100,
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(
                          context,
                          'Medium',
                          '134/2000',
                          Colors.amber.shade100,
                          Colors.amber.shade700,
                        ),
                        const SizedBox(height: 16),
                        _buildDifficultyCard(
                          context,
                          'Hard',
                          '4/2000',
                          Colors.red.shade100,
                          Colors.red.shade700,
                        ),
                        const SizedBox(height: 34), // Bottom padding
                      ],
                    ),
                  ),

                  // TODO: Consider adding Achievements/other links here if needed
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- Helper Methods Copied from MainPagePrototype ---

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 12.0,
      ),
      height: 100,
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              'assets/images/logo.png',
              height: 80,
              semanticLabel: 'App Logo',
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // Navigate to actual Settings page
                context.push(AppRoutes.settings);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryItem(BuildContext context, String name, String levels) {
    final theme = Theme.of(context);
    IconData countryIcon;
    switch (name) {
      case 'Egypt':
        countryIcon = Icons.temple_hindu;
        break;
      case 'Russia':
        countryIcon = Icons.church;
        break;
      case 'UK':
        countryIcon = Icons.castle;
        break;
      case 'France':
        countryIcon = Icons.tour;
        break;
      default:
        countryIcon = Icons.location_city;
    }

    return Padding(
      padding: const EdgeInsets.only(right: 24.0),
      child: Column(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: Icon(
              countryIcon,
              size: 40,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 18,
            ),
          ),
          Text(
            levels,
            style: TextStyle(
              color: Colors.amber.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard(BuildContext context, String difficulty,
      String progress, Color backgroundColor, Color accentColor) {
    final theme = Theme.of(context);
    IconData difficultyIcon;
    switch (difficulty) {
      case 'Easy':
        difficultyIcon = Icons.emoji_emotions;
        break;
      case 'Medium':
        difficultyIcon = Icons.sentiment_neutral;
        break;
      case 'Hard':
        difficultyIcon = Icons.sentiment_very_dissatisfied;
        break;
      default:
        difficultyIcon = Icons.star_border;
    }

    return InkWell(
      onTap: () {
        // Navigate to the GamePage when any difficulty is tapped
        context.push(AppRoutes.game);
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('$difficulty Levels Tapped')),
        // );
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(difficultyIcon, size: 40, color: accentColor),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    difficulty,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      fontSize: 24, // Match prototype style
                    ),
                  ),
                  Text(
                    progress,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: accentColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: accentColor),
          ],
        ),
      ),
    );
  }
}
