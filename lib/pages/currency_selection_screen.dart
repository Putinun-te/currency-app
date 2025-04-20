import 'package:flutter/material.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final List<Map<String, String>> currencies;
  const CurrencySelectionScreen({super.key, required this.currencies});

  @override
  State<CurrencySelectionScreen> createState() => _CurrencySelectionScreenState();
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
        backgroundColor: const Color(0xFFE6E6E6),
        title: const Text('Select Currency'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => search = val),
              decoration: InputDecoration(
                hintText: "Search Currency",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: search.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => search = ''),
                      )
                    : null,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
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
              itemBuilder: (_, index) {
                final currency = filtered[index];
                return ListTile(
                  title: Text(currency['code']!),
                  subtitle: Text(currency['name']!),
                  onTap: () => Navigator.pop(context, currency['code']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
