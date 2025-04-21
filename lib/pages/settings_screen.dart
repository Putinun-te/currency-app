import 'package:flutter/material.dart';
import 'about_help_screen.dart';

class SettingsScreen extends StatelessWidget {
  final bool isDarkMode;
  final void Function(bool) onToggleTheme;
  final String fromCurrency;
  final String toCurrency;
  final ValueChanged<String?> onFromCurrencyChanged;
  final ValueChanged<String?> onToCurrencyChanged;
  final VoidCallback onClearAll;

  const SettingsScreen({
    super.key,
    required this.isDarkMode,
    required this.onToggleTheme,
    required this.fromCurrency,
    required this.toCurrency,
    required this.onFromCurrencyChanged,
    required this.onToCurrencyChanged,
    required this.onClearAll,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> currencyCodes = [
      'USD',
      'EUR',
      'THB',
      'JPY',
      'GBP',
      'AUD',
      'CAD',
      'CHF',
      'INR',
      'CNY',
      'BRL',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text("Settings"), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Dark Mode", style: TextStyle(fontSize: 18)),
              Switch(value: isDarkMode, onChanged: onToggleTheme),
            ],
          ),
          const SizedBox(height: 20),
          const Text("Default From Currency", style: TextStyle(fontSize: 16)),
          DropdownButton<String>(
            value: fromCurrency,
            isExpanded: true,
            items:
                currencyCodes
                    .map(
                      (code) =>
                          DropdownMenuItem(value: code, child: Text(code)),
                    )
                    .toList(),
            onChanged: onFromCurrencyChanged,
          ),
          const SizedBox(height: 20),
          const Text("Default To Currency", style: TextStyle(fontSize: 16)),
          DropdownButton<String>(
            value: toCurrency,
            isExpanded: true,
            items:
                currencyCodes
                    .map(
                      (code) =>
                          DropdownMenuItem(value: code, child: Text(code)),
                    )
                    .toList(),
            onChanged: onToCurrencyChanged,
          ),
          const SizedBox(height: 30),

          ElevatedButton.icon(
            icon: const Icon(Icons.info_outline),
            label: const Text("About & Help"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutHelpScreen()),
              );
            },
          ),
          const SizedBox(height: 30),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete_forever),
            label: const Text("Clear All Data"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (_) => AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text(
                        "Are you sure you want to reset all settings and data?",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Cancel"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            onClearAll();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("All data cleared")),
                            );
                          },
                          child: const Text("Yes"),
                        ),
                      ],
                    ),
              );
            },
          ),
        ],
      ),
    );
  }
}
