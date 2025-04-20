import 'package:flutter/material.dart';

class CurrencySelectionScreen extends StatefulWidget {
  final List<Map<String, String>> currencies;

  const CurrencySelectionScreen({super.key, required this.currencies});

  @override
  State<CurrencySelectionScreen> createState() =>
      _CurrencySelectionScreenState();
}

class _CurrencySelectionScreenState extends State<CurrencySelectionScreen> {
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final filteredCurrencies =
        widget.currencies.where((currency) {
          final code = currency['code']!.toLowerCase();
          final name = currency['name']!.toLowerCase();
          return code.contains(searchQuery.toLowerCase()) ||
              name.contains(searchQuery.toLowerCase());
        }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFE6E6E6),
        title: const Text('Exchange Rates'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          /// Search field
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (value) => setState(() => searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search Currency',
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    searchQuery.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => searchQuery = ''),
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(40),
                  borderSide: const BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),

          /// Currency list
          Expanded(
            child: ListView.separated(
              itemCount: filteredCurrencies.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final currency = filteredCurrencies[index];
                return ListTile(
                  title: Text(currency['code']!),
                  subtitle: Text(currency['name']!),
                  onTap: () {
                    Navigator.pop(context, currency['code']);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
