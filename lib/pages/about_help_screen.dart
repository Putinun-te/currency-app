import 'package:flutter/material.dart';

class AboutHelpScreen extends StatelessWidget {
  const AboutHelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Help'),
        backgroundColor: theme.appBarTheme.backgroundColor ?? theme.cardColor,
        foregroundColor:
            theme.appBarTheme.foregroundColor ?? theme.colorScheme.onBackground,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        children: [
          ListTile(
            title: const Text('Support'),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Support"),
                      content: const Text(
                        "For help, contact:\nPutinun.tac@student.mahidol.edu\nPanaiyakorn.pha@student.mahidol.edu",
                      ),
                      backgroundColor: theme.dialogBackgroundColor,
                      titleTextStyle: theme.textTheme.titleLarge,
                      contentTextStyle: theme.textTheme.bodyMedium,
                    ),
              );
            },
          ),
          ListTile(
            title: const Text('API Usage'),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("API Usage"),
                      content: const Text(
                        "This app uses the Frankfurter API to fetch live exchange rates.",
                      ),
                      backgroundColor: theme.dialogBackgroundColor,
                      titleTextStyle: theme.textTheme.titleLarge,
                      contentTextStyle: theme.textTheme.bodyMedium,
                    ),
              );
            },
          ),
          ListTile(
            title: const Text('Policy'),
            onTap: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Policy"),
                      content: const Text(
                        "We do not store personal data. Settings and preferences are saved locally on your device.",
                      ),
                      backgroundColor: theme.dialogBackgroundColor,
                      titleTextStyle: theme.textTheme.titleLarge,
                      contentTextStyle: theme.textTheme.bodyMedium,
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
