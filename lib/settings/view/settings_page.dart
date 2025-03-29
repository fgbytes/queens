import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('Appearance'),
            leading: const Icon(Icons.palette),
            onTap: () {
              // TODO: Implement Appearance settings
            },
          ),
          ListTile(
            title: const Text('Account'),
            leading: const Icon(Icons.account_circle),
            onTap: () {
              // TODO: Implement Account settings
            },
          ),
          const Divider(),
          ListTile(
            title: const Text('Developer Options'),
            subtitle: const Text('Access debug tools and prototypes'),
            leading: const Icon(Icons.developer_mode),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () => context.push('/_debugPlayground'), // Navigate to debug
          ),
        ],
      ),
    );
  }
}
