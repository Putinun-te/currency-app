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
    final filtered = widget.currencies.where((c) {
      final code = c['code']!.toLowerCase();
      final name = c['name']!.toLowerCase();
      return code.contains(search.toLowerCase()) ||
          name.contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Select Currency"),
        backgroundColor: const Color(0xFFE6E6E6),
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => search = val),
              decoration: InputDecoration(
                hintText: "Search currency",
                prefixIcon: const Icon(Icons.search),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final c = filtered[i];
                return ListTile(
                  title: Text(c['code']!),
                  subtitle: Text(c['name']!),
                  onTap: () => Navigator.pop(context, c['code']),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
