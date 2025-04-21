import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'pages/home_screen.dart';
import 'pages/history_screen.dart';
import 'pages/settings_screen.dart';
import 'pages/favourite_screen.dart';
import 'dart:convert';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  void loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDark') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  void toggleTheme(bool isDark) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDark', isDark);
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFE6E6E6),
          foregroundColor: Colors.black,
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        fontFamily: 'Inter',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[850],
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.black,
            backgroundColor: const Color(0xFF3399CC),
          ),
        ),
      ),
      home: MainScaffold(
        onThemeToggle: toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class MainScaffold extends StatefulWidget {
  final void Function(bool) onThemeToggle;
  final bool isDarkMode;

  const MainScaffold({
    super.key,
    required this.onThemeToggle,
    required this.isDarkMode,
  });

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  final List<String> conversionHistory = [];
  final List<String> favourites = [];
  final TextEditingController amountController = TextEditingController();

  String? reConversionData;
  String fromCurrency = 'USD';
  String toCurrency = 'THB';
  String defaultFromCurrency = 'USD';
  String defaultToCurrency = 'THB';

  String currentFromCurrency = 'USD';
  String currentToCurrency = 'THB';
List<Map<String, dynamic>> notifications = [];

Future<void> checkFavouriteRateDrops() async {
  final prefs = await SharedPreferences.getInstance();
  final favs = prefs.getStringList('favourites') ?? [];

  List<Map<String, dynamic>> foundNotifications = [];

  for (String fav in favs) {
    try {
      final parts = fav.split(' ');
      if (parts.length >= 4 && parts[2] == "to") {
        final from = parts[1];
        final to = parts[3];

        final url =
            'https://api.frankfurter.app/latest?amount=1&from=$from&to=$to';
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final rate = data['rates'][to];
          if (rate != null && rate < 1.0) {
            foundNotifications.add({
              'message': '$from → $to dropped to ${rate.toStringAsFixed(2)} $to',
              'timestamp': DateTime.now(),
            });
          }
        }
      }
    } catch (e) {
      debugPrint("Error checking $fav: $e");
    }
  }

  setState(() {
    notifications = foundNotifications;
  });
}

  @override
  void initState() {
    super.initState();
    loadFavourites();
    loadDefaultCurrencies();
    checkFavouriteRateDrops();
  }

  void clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Clear all SharedPreferences

    setState(() {
      favourites.clear();
      conversionHistory.clear();
      fromCurrency = 'USD';
      toCurrency = 'THB';
      widget.onThemeToggle(false); // Reset to light mode
      _currentIndex = 0;
    });
  }

  void loadDefaultCurrencies() async {
    final prefs = await SharedPreferences.getInstance();
    final defaultFrom = prefs.getString('defaultFromCurrency') ?? 'USD';
    final defaultTo = prefs.getString('defaultToCurrency') ?? 'THB';

    setState(() {
      defaultFromCurrency = defaultFrom;
      defaultToCurrency = defaultTo;
      currentFromCurrency = defaultFrom; // initialize current from default
      currentToCurrency = defaultTo;
    });
  }

  void loadFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favourites') ?? [];
    setState(() {
      favourites.clear();
      favourites.addAll(favs);
    });
  }

  void saveFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('favourites', favourites);
  }

  void addToHistory(String record) {
    if (!conversionHistory.contains(record)) {
      setState(() => conversionHistory.insert(0, record));
    }
  }

  void addToFavourite(String record) {
    if (!favourites.contains(record)) {
      setState(() {
        favourites.add(record);
        saveFavourites();
      });
    }
  }

  void clearHistory() => setState(() => conversionHistory.clear());

  void clearFavourites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('favourites');
    setState(() => favourites.clear());
  }

  void handleReconvert(String record) {
    setState(() {
      _currentIndex = 0;
      reConversionData = record;
    });
  }

  void openFavourites(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => FavouriteScreen(
              favourites: favourites,
              onClear: clearFavourites,
              onReconvert: handleReconvert,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onAddHistory: addToHistory,
        onAddFavourite: addToFavourite,
        onViewFavourite: () => openFavourites(context),
        reConversionData: reConversionData,
        amountController: amountController,
        fromCurrency: currentFromCurrency,
        toCurrency: currentToCurrency,
        onUpdateFromCurrency:
            (val) => setState(() => currentFromCurrency = val),
        onUpdateToCurrency: (val) => setState(() => currentToCurrency = val),
          notifications: notifications,
      ),

      HistoryScreen(
        history: conversionHistory,
        onClear: clearHistory,
        onReconvert: handleReconvert,
      ),
      SettingsScreen(
        isDarkMode: widget.isDarkMode,
        onToggleTheme: widget.onThemeToggle,
        fromCurrency: defaultFromCurrency,
        toCurrency: defaultToCurrency,
        onFromCurrencyChanged: (val) async {
          if (val != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('defaultFromCurrency', val);
            setState(() => defaultFromCurrency = val);
          }
        },
        onToCurrencyChanged: (val) async {
          if (val != null) {
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('defaultToCurrency', val);
            setState(() => defaultToCurrency = val);
          }
        },
        onClearAll: clearAllData,
      ),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
            if (index != 0) reConversionData = null;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
