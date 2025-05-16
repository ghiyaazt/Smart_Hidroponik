import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'iot_pages/iot_monitoring_page.dart';
import 'iot_pages/iot_controlling_page.dart';

class IotPage extends StatelessWidget {
  const IotPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF8DAA6D), Color(0xFF728C5A)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween(begin: 0.0, end: 1.0),
                    builder: (context, value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.scale(
                          scale: value,
                          child: Hero(
                            tag: 'iot-icon',
                            child: const Icon(
                              Icons.devices_other,
                              size: 100,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Smart IoT System',
                    style: GoogleFonts.poppins(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Pantau & kontrol sistem hidroponikmu di sini.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 40),
                  _buildAnimatedButton(
                    context,
                    icon: Icons.monitor_heart,
                    label: 'Monitoring',
                    page: const IotMonitoringPage(),
                  ),
                  const SizedBox(height: 20),
                  _buildAnimatedButton(
                    context,
                    icon: Icons.settings_remote,
                    label: 'Controlling',
                    page: const IotControllingPage(),
                    useCustomTransition: true, // <-- ini untuk animasi khusus
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton(BuildContext context,
      {required IconData icon,
      required String label,
      required Widget page,
      bool useCustomTransition = false}) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.0, end: 1.0),
      builder: (context, value, child) => Opacity(
        opacity: value,
        child: Transform.translate(
          offset: Offset(0, (1 - value) * 30),
          child: child,
        ),
      ),
      child: ElevatedButton.icon(
        icon: Icon(icon, color: const Color(0xFF728C5A)),
        label: Text(
          label,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: const Color(0xFF728C5A),
          ),
        ),
        onPressed: () {
          if (useCustomTransition) {
            Navigator.push(context, _createRoute(page));
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => page),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  Route _createRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Slide from right + fade
        const beginOffset = Offset(1.0, 0.0);
        const endOffset = Offset.zero;
        final tweenOffset = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: Curves.easeOut));

        final fadeTween = Tween(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(tweenOffset),
          child: FadeTransition(
            opacity: animation.drive(fadeTween),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 400),
    );
  }
}