import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'NotificationScreen.dart';
import 'currency_selection_screen.dart';

class HomeScreen extends StatefulWidget {
  final void Function(String) onAddHistory;
  final void Function(String) onAddFavourite;
  final VoidCallback onViewFavourite;
  final String? reConversionData;
  final TextEditingController amountController;
  final String fromCurrency;
  final String toCurrency;
  final void Function(String) onUpdateFromCurrency;
  final void Function(String) onUpdateToCurrency;
  final List<Map<String, dynamic>> notifications;

  const HomeScreen({
    super.key,
    required this.onAddHistory,
    required this.onAddFavourite,
    required this.onViewFavourite,
    required this.amountController,
    required this.fromCurrency,
    required this.toCurrency,
    required this.onUpdateFromCurrency,
    required this.onUpdateToCurrency,
    this.reConversionData,
    required this.notifications,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String result = '';
  bool isConverting = false;

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

  @override
  void initState() {
    super.initState();
    if (widget.reConversionData != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        handleReconversion(widget.reConversionData!);
      });
    }
  }

  void swapCurrencies() {
    widget.onUpdateFromCurrency(widget.toCurrency);
    widget.onUpdateToCurrency(widget.fromCurrency);
    setState(() => result = '');
  }

  void handleReconversion(String data) {
    final parts = data.split(' ');
    if (parts.length == 4 && parts[2] == 'to') {
      final parsedAmount = double.tryParse(parts[0]);
      final from = parts[1];
      final to = parts[3];
      if (parsedAmount != null) {
        widget.onUpdateFromCurrency(from);
        widget.onUpdateToCurrency(to);
        widget.amountController.text = parsedAmount.toString();
        convertCurrency();
      }
    }
  }

  Future<void> selectCurrency({required bool isFrom}) async {
    final selected = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CurrencySelectionScreen(currencies: currencyList),
      ),
    );

    if (selected != null && selected is String) {
      if (isFrom) {
        widget.onUpdateFromCurrency(selected);
      } else {
        widget.onUpdateToCurrency(selected);
      }
      setState(() => result = '');
    }
  }

  Future<void> convertCurrency() async {
    setState(() => isConverting = true);
    final amount = double.tryParse(widget.amountController.text) ?? 0;

    final url =
        'https://api.frankfurter.app/latest?amount=1&from=${widget.fromCurrency}&to=${widget.toCurrency}';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rate = data['rates'][widget.toCurrency];
        final calculated = amount * rate;
        final formatted = calculated.toStringAsFixed(2);

        setState(() {
          result = '$formatted ${widget.toCurrency}';
        });

        widget.onAddHistory(
          '$amount ${widget.fromCurrency} to ${widget.toCurrency}',
        );
      } else {
        throw Exception('Failed to load rate');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error converting currency")),
      );
    } finally {
      setState(() => isConverting = false);
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
        Text(label, style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => selectCurrency(isFrom: isFrom),
                child: Text(
                  currency,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
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
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isDark ? Colors.teal[300] : const Color(0xFF3399CC),
          foregroundColor: isDark ? Colors.black : Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.black : Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Currency Converter"),
        centerTitle: true,
        backgroundColor:
            Theme.of(context).appBarTheme.backgroundColor ?? Colors.transparent,
        foregroundColor:
            Theme.of(context).appBarTheme.foregroundColor ??
            Theme.of(context).colorScheme.onBackground,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (_) => NotificationScreen(
                        notifications: widget.notifications,
                      ),
                ),
              );
            },
          ),
        ],
      ),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    buildCurrencyInput(
                      label: 'From Currency',
                      currency: widget.fromCurrency,
                      isFrom: true,
                      trailing: TextField(
                        controller: widget.amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Amount',
                          isDense: true,
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
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
                      currency: widget.toCurrency,
                      isFrom: false,
                      trailing: Text(
                        result,
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    buildButton(
                      isConverting ? "Converting..." : "Convert",
                      convertCurrency,
                    ),
                    const SizedBox(height: 16),
                    buildButton("Add to Favourite", () async {
                      final amount = widget.amountController.text;
                      if (amount.isNotEmpty && result.isNotEmpty) {
                        final fav =
                            "$amount ${widget.fromCurrency} to ${widget.toCurrency}";
                        widget.onAddFavourite(fav);
                        widget.onViewFavourite();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "Please convert before adding to favourites",
                            ),
                          ),
                        );
                      }
                    }),
                    const SizedBox(height: 16),
                    buildButton("View Favourite", widget.onViewFavourite),
                  ],
                ),
              ),
              Positioned(
                top: 105,
                right: 0,
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.swap_vert,
                      color:
                          isDark ? Colors.tealAccent : const Color(0xFF3399CC),
                    ),
                    onPressed: swapCurrencies,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
