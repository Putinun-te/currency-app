import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter'),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String fromCurrency = 'USD';
  String toCurrency = 'THB';
  String result = '';
  final amountController = TextEditingController(text: '100');

  final List<Map<String, String>> currencyList = [
    {'code': 'USD', 'name': 'US Dollar'},
    {'code': 'EUR', 'name': 'Euro'},
    {'code': 'THB', 'name': 'Thai Baht'},
    {'code': 'JPY', 'name': 'Japanese Yen'},
    {'code': 'GBP', 'name': 'British Pound'},
    {'code': 'AUD', 'name': 'Australian Dollar'},
    {'code': 'CAD', 'name': 'Canadian Dollar'},
    {'code': 'CHF', 'name': 'Swiss Franc'},
    {'code': 'INR', 'name': 'Indian Rupee'},
    {'code': 'CNY', 'name': 'Chinese Yuan'},
    {'code': 'BRL', 'name': 'Brazilian Real'},
  ];

  Future<void> selectCurrency({required bool isFrom}) async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CurrencySelectionScreen(currencies: currencyList),
      ),
    );

    if (selected != null && selected is String) {
      setState(() {
        if (isFrom) {
          fromCurrency = selected;
        } else {
          toCurrency = selected;
        }
        result = '';
      });
    }
  }

  Future<void> convertCurrency() async {
    final amount = double.tryParse(amountController.text) ?? 0;
    final url =
        'https://api.frankfurter.app/latest?amount=$amount&from=$fromCurrency&to=$toCurrency';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][toCurrency];
        setState(() {
          result = '$rate $toCurrency';
        });
      } else {
        throw Exception('Failed to load rate');
      }
    } catch (e) {
      print('Error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error converting currency")),
      );
    }
  }

  Widget buildCurrencyInput({
    required String label,
    required String currency,
    required bool isFrom,
    Widget? trailing,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE6E6E6),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => selectCurrency(isFrom: isFrom),
                child: Text(
                  currency,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Expanded(child: trailing ?? const SizedBox()),
            ],
          ),
        ),
      ],
    );
  }

  Widget buildButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF3399CC),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        onPressed: onPressed,
        child: Text(text, style: const TextStyle(fontSize: 18)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Currency Converter"),
        centerTitle: true,
        backgroundColor: const Color(0xFFE6E6E6),
        elevation: 0,
        foregroundColor: Colors.black,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              buildCurrencyInput(
                label: 'From Currency',
                currency: fromCurrency,
                isFrom: true,
                trailing: TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Amount',
                    isDense: true,
                    filled: true,
                    fillColor: Colors.white,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              buildCurrencyInput(
                label: 'To Currency',
                currency: toCurrency,
                isFrom: false,
                trailing: Text(result, style: const TextStyle(fontSize: 16)),
              ),
              const SizedBox(height: 32),
              buildButton("Convert", convertCurrency),
              const SizedBox(height: 16),
              buildButton("Add to Favourite", () {}),
              const SizedBox(height: 16),
              buildButton("View Favourite", () {}),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        onTap: (_) {},
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: "History"),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: "Settings",
          ),
        ],
      ),
    );
  }
}

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
    final filtered =
        widget.currencies.where((c) {
          final code = c['code']!.toLowerCase();
          final name = c['name']!.toLowerCase();
          return code.contains(search.toLowerCase()) ||
              name.contains(search.toLowerCase());
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
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              onChanged: (val) => setState(() => search = val),
              decoration: InputDecoration(
                hintText: "Search Currency",
                prefixIcon: const Icon(Icons.search),
                suffixIcon:
                    search.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear),
                          onPressed: () => setState(() => search = ''),
                        )
                        : null,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
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
