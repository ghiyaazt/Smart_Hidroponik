import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/monitoring_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/settings_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const MonitoringPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _navBarItems = const [
    Icon(Icons.analytics, size: 30, color: Colors.white),
    Icon(Icons.monitor_heart, size: 30, color: Colors.white),
    Icon(Icons.settings, size: 30, color: Colors.white),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hidroponik Pintar',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: CurvedNavigationBar(
          index: _selectedIndex,
          height: 60.0,
          color: Colors.green,
          buttonBackgroundColor: Colors.greenAccent,
          backgroundColor: Colors.white,
          animationCurve: Curves.easeInOut,
          animationDuration: const Duration(milliseconds: 300),
          items: _navBarItems,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}