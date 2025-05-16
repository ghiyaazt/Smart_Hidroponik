import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:hidroponiktkkc/firebase_options.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:hidroponiktkkc/pages/dashboard_page.dart';
import 'package:hidroponiktkkc/pages/monitoring_page.dart';
import 'package:hidroponiktkkc/pages/settings_page.dart';
import 'package:hidroponiktkkc/pages/login_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Aplikasi Hidroponik',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FutureBuilder(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return snapshot.data ?? const LoginPage();
          }
        },
      ),
      debugShowCheckedModeBanner: false,
      routes: {
        '/main': (context) => const MainPage(),
      },
    );
  }

  static Future<Widget?> _checkLoginStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      
      if (isLoggedIn) {
        final user = FirebaseAuth.instance.currentUser;
        if (user != null) {
          return const MainPage();
        } else {
          await prefs.setBool('isLoggedIn', false);
          return null;
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _pageIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    IotPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_pageIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _pageIndex,
        backgroundColor: const Color(0xFF728C5A),
        color: const Color(0xFFEBFADC),
        buttonBackgroundColor: const Color(0xFFEBFADC),
        height: 60,
        items: const [
          Icon(Icons.home, size: 30, color: Color(0xFF102F15)),
          Icon(Icons.sensor_window, size: 30, color: Color(0xFF102F15)),
          Icon(Icons.settings, size: 30, color: Color(0xFF102F15)),
        ],
        onTap: (index) {
          setState(() {
            _pageIndex = index;
          });
        },
      ),
    );
  }
}