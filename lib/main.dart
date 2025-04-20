import 'package:flutter/material.dart';
import 'pages/home_screen.dart';
import 'pages/history_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(fontFamily: 'Inter'),
      home: const MainScaffold(),
    );
  }
}

class MainScaffold extends StatefulWidget {
  const MainScaffold({super.key});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;
  final List<String> conversionHistory = [];
  String? reConversionData;

  void addToHistory(String record) {
    setState(() {
      conversionHistory.insert(0, record);
    });
  }

  void clearHistory() {
    setState(() {
      conversionHistory.clear();
    });
  }

  void handleReconvert(String record) {
    setState(() {
      _currentIndex = 0;
      reConversionData = record;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      HomeScreen(
        onAddHistory: addToHistory,
        reConversionData: reConversionData,
      ),
      HistoryScreen(
        history: conversionHistory,
        onClear: clearHistory,
        onReconvert: handleReconvert,
      ),
      const Center(child: Text("Settings Coming Soon")),
    ];

    return Scaffold(
      body: screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap:
            (index) => setState(() {
              
              _currentIndex = index;
              if (index != 0) reConversionData = null;
            }),
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
