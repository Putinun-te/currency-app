import 'package:flutter/material.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final List<Map<String, String>> currencies;
  const CurrencySelectionScreen({super.key, required this.currencies});

  @override
  State<CurrencySelectionScreen> createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filtered =
        widget.currencies.where((c) {
          final code = c['code']!.toLowerCase();
          final name = c['name']!.toLowerCase();
          return code.contains(search.toLowerCase()) ||
              name.contains(search.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Currency"),
        centerTitle: true,
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => search = val),
              style: TextStyle(color: isDark ? Colors.white : Colors.black),
              decoration: InputDecoration(
                filled: true,
                fillColor: isDark ? Colors.grey[850] : Colors.grey[200],
                hintText: "Search currency",
                hintStyle: TextStyle(
                  color: isDark ? Colors.grey[400] : Colors.grey[700],
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: isDark ? Colors.grey[400] : Colors.black,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder:
                  (_, __) =>
                      Divider(height: 1, color: Theme.of(context).dividerColor),
              itemBuilder: (_, i) {
                final c = filtered[i];
                return ListTile(
                  title: Text(
                    c['code']!,
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                  subtitle: Text(
                    c['name']!,
                    style: TextStyle(
                      color: isDark ? Colors.grey[400] : Colors.grey[700],
                    ),
                  ),
                  onTap: () => Navigator.pop(context, c['code']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
