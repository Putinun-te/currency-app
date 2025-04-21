import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'pages/home_screen.dart';
import 'pages/history_screen.dart';
import 'pages/settings_screen.dart';
import 'pages/favourite_screen.dart';
import 'dart:convert';

void main() async {
  runApp(MyApp());
}

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
    if (!allowNotification) return;

    final prefs = await SharedPreferences.getInstance();
    final favs = prefs.getStringList('favourites') ?? [];

    List<Map<String, dynamic>> foundNotifications = [];

    for (String fav in favs) {
      if (!fav.contains(" to ")) continue;

      final parts = fav.split(" to ");
      final from = parts[0];
      final to = parts[1];

      final url =
          'https://api.frankfurter.app/latest?amount=1&from=$from&to=$to';
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final rate = data['rates'][to];
          if (rate != null && rate < 35) {
            foundNotifications.add({
              'message': '1 $from reached ${rate.toStringAsFixed(2)} $to',
              'timestamp': DateTime.now(),
            });
          }
        }
      } catch (e) {
        debugPrint("Notification error: $e");
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
    loadNotificationSetting();
    checkFavouriteRateDrops();
  }

  void clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // 🔥 ล้างทุกอย่าง

    setState(() {
      conversionHistory.clear();
      favourites.clear();

      // 🔁 รีเซ็ต theme
      widget.onThemeToggle(false);

      // ✅ รีเซ็ตค่า currency ทั้ง default และ current
      fromCurrency = 'THB';
      toCurrency = 'USD';
      defaultFromCurrency = 'THB';
      defaultToCurrency = 'USD';
      currentFromCurrency = 'THB';
      currentToCurrency = 'USD';

      reConversionData = null;
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

  bool allowNotification = true;

  void loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      allowNotification = prefs.getBool('allowNotification') ?? true;
    });
  }

  void toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('allowNotification', value);
    setState(() {
      allowNotification = value;
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

  void openFavourites(BuildContext context) async {
    final selected = await Navigator.push<String>(
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

    if (selected != null && selected.contains(" to ")) {
      final parts = selected.split(" to ");
      if (parts.length == 2) {
        setState(() {
          currentFromCurrency = parts[0];
          currentToCurrency = parts[1];
          _currentIndex = 0;
        });
      }
    }
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
        allowNotification: allowNotification,
        onToggleTheme: widget.onThemeToggle,
        onToggleNotification: toggleNotification,
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
        onPickNotifyTime: () {},
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
