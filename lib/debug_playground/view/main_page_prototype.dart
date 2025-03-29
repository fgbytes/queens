import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import for SystemUiOverlayStyle

class MainPagePrototype extends StatelessWidget {
  const MainPagePrototype({super.key});

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
              // Gradient that is transparent at the top, opaque below
              // Adjust stops to control the fade height (e.g., 0.05 means top 5%)
              return LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent, // Start transparent
                  Colors.black, // Fade to opaque
                  Colors.black, // Stay opaque
                ],
                stops: const [
                  0.0,
                  0.05,
                  1.0,
                ], // Adjust 0.05 to control fade distance
                tileMode: TileMode.clamp,
              ).createShader(
                // Create shader bounds slightly offset to avoid fading the very top pixel if not desired
                // Rect.fromLTRB(bounds.left, bounds.top + 1, bounds.right, bounds.bottom),
                // Or use full bounds:
                bounds,
              );
            },
            blendMode: BlendMode.dstIn,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
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
                        const SizedBox(height: 34),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: theme.colorScheme.surface, // Or surfaceContainerHighest
      padding: const EdgeInsets.only(
        left: 16.0,
        right: 16.0,
        bottom: 12.0,
      ),
      height: 100, // Example fixed height for the header area
      // Use a Stack for independent positioning
      child: Stack(
        children: [
          // Center the logo
          Center(
            child: Image.asset(
              'assets/images/logo.png', // Use the actual logo file
              height: 80, // Increased logo size further
              semanticLabel: 'App Logo',
            ),
          ),
          // Align the icon to the right
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Implement settings action
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Settings Tapped')),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountryItem(BuildContext context, String name, String levels) {
    final theme = Theme.of(context);

    // Select appropriate icon based on country name
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
          // Circular avatar for country illustration
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

    // Select appropriate icon based on difficulty
    IconData difficultyIcon;
    switch (difficulty) {
      case 'Easy':
        difficultyIcon = Icons.emoji_emotions; // Happy face
        break;
      case 'Medium':
        difficultyIcon = Icons.sentiment_neutral; // Neutral face
        break;
      case 'Hard':
        difficultyIcon = Icons.sentiment_very_dissatisfied; // Sad face
        break;
      default:
        difficultyIcon = Icons.person;
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          // Placeholder for difficulty level illustration
          CircleAvatar(
            radius: 32,
            backgroundColor: Colors.white,
            child: Icon(
              difficultyIcon,
              size: 40,
              color: accentColor,
            ),
          ),
          const SizedBox(width: 20),
          Text(
            difficulty,
            style: theme.textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 28,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const Spacer(),
          Text(
            progress,
            style: TextStyle(
              color: accentColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
