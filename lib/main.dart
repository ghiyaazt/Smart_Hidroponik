import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'pages/monitoring_page.dart';
import 'pages/dashboard_page.dart';
import 'pages/settings_page.dart';

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
    const DashboardPage(),  // Dashboard Page
    const MonitoringPage(), // Monitoring Page
    const SettingsPage(),   // Settings Page
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Hidroponik Pintar',
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: Colors.grey[50],
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          elevation: 10,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal),
        ),
      ),
      home: Scaffold(
        body: _pages[_selectedIndex],
        bottomNavigationBar: _buildFancyNavBar(),
      ),
    );
  }

  Widget _buildFancyNavBar() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          iconSize: 26,
          selectedItemColor: Colors.green[700],
          unselectedItemColor: Colors.grey[600],
          backgroundColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.analytics, 0),
              activeIcon: _buildActiveIcon(Icons.analytics, 0),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.monitor_heart, 1),
              activeIcon: _buildActiveIcon(Icons.monitor_heart, 1),
              label: 'Monitoring',
            ),
            BottomNavigationBarItem(
              icon: _buildAnimatedIcon(Icons.settings, 2),
              activeIcon: _buildActiveIcon(Icons.settings, 2),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedIcon(IconData icon, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon),
        const SizedBox(height: 2),
        Container(
          height: 2,
          width: _selectedIndex == index ? 20 : 0,
          decoration: BoxDecoration(
            color: _selectedIndex == index ? Colors.green[700] : Colors.transparent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  Widget _buildActiveIcon(IconData icon, int index) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          padding: const EdgeInsets.all(6),
          child: Icon(icon, color: Colors.green[700]),
        ),
        const SizedBox(height: 2),
        Container(
          height: 3,
          width: 20,
          decoration: BoxDecoration(
            color: Colors.green[700],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}