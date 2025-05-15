import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage>
    with SingleTickerProviderStateMixin {
  final DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  double tds = 0;
  double volumeAir = 0;
  String relay1Status = 'OFF';
  String relay2Status = 'OFF';

  late AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _glowController.repeat(reverse: true);
    _listenRealtimeData();
  }

  @override
  void dispose() {
    _glowController.dispose();
    super.dispose();
  }

  void _listenRealtimeData() {
    dbRef.child('hidroponik/monitoring').onValue.listen((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;

      if (data != null) {
        setState(() {
          tds = (data['tds'] != null)
              ? double.tryParse(data['tds'].toString()) ?? 0
              : 0;
          volumeAir = (data['volume_air'] != null)
              ? double.tryParse(data['volume_air'].toString()) ?? 0
              : 0;
          relay1Status = (data['relay1'] ?? 'OFF').toString();
          relay2Status = (data['relay2'] ?? 'OFF').toString();
        });
      }
    });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF2E7D32)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
        ),
      ),
      title: Text(
        'Monitoring',
        style:
            GoogleFonts.robotoSlab(fontWeight: FontWeight.bold, fontSize: 22),
      ),
      centerTitle: true,
      elevation: 4,
    );
  }

  Widget _buildCircularIndicator({
    required String label,
    required double value,
    required String unit,
    required Color color,
    required IconData icon,
    double maxValue = 100,
  }) {
    double progress = (value / maxValue).clamp(0.0, 1.0);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 18),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.2),
              ),
              padding: const EdgeInsets.all(18),
              child: Icon(icon, size: 42, color: color),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: GoogleFonts.openSans(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: Colors.black87)),
                  const SizedBox(height: 8),
                  Text(
                    '${value.toStringAsFixed(label == "TDS" ? 1 : 2)} $unit',
                    style: GoogleFonts.openSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 26,
                        color: Colors.black87),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      color: color,
                      backgroundColor: color.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildPumpCard(String label, String status) {
    bool isOn = status.toUpperCase() == 'ON';

    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 700),
        margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: isOn
              ? RadialGradient(
                  colors: [
                    Colors.green.shade700.withOpacity(0.9),
                    Colors.green.shade400
                  ],
                  center: const Alignment(-0.8, -0.8),
                  radius: 1.2)
              : null,
          color: isOn ? null : const Color.fromARGB(255, 255, 255, 255),
          boxShadow: isOn
              ? [
                  BoxShadow(
                      color: Colors.green.shade600.withOpacity(0.7),
                      blurRadius: 12,
                      spreadRadius: 1)
                ]
              : [
                  BoxShadow(
                      color: Colors.grey.shade400,
                      blurRadius: 4,
                      spreadRadius: 0.4,
                      offset: const Offset(0, 2))
                ],
        ),
        padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _glowController,
              builder: (context, child) {
                return FaIcon(
                  FontAwesomeIcons.tint,
                  size: 44,
                  color: isOn
                      ? Colors.green.shade50.withOpacity(
                          0.6 + 0.4 * _glowController.value)
                      : Colors.grey.shade600,
                  shadows: isOn
                      ? [
                          Shadow(
                            color: Colors.green.shade400.withOpacity(0.7),
                            blurRadius: 18 * _glowController.value,
                            offset: const Offset(0, 0),
                          )
                        ]
                      : null,
                );
              },
            ),
            const SizedBox(height: 14),
            Text(
              label,
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                  color: isOn ? Colors.green.shade900 : Colors.grey[800]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              status.toUpperCase(),
              style: GoogleFonts.openSans(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: isOn ? Colors.green.shade900 : Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      children: [
        _buildCircularIndicator(
          label: 'Volume Air',
          value: volumeAir,
          unit: 'liter',
          color: Colors.green.shade600,
          icon: Icons.opacity,
          maxValue: 20,
        ),
        _buildCircularIndicator(
          label: 'TDS',
          value: tds,
          unit: 'ppm',
          color: Colors.green.shade800,
          icon: Icons.water_drop_outlined,
          maxValue: 1000,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              _buildPumpCard('Pompa Nutrisi 1', relay1Status),
              _buildPumpCard('Pompa Nutrisi 2', relay2Status),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: GoogleFonts.openSans().fontFamily,
        scaffoldBackgroundColor: Colors.grey[50],
        primaryColor: const Color(0xFF388E3C),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.green.shade700,
          foregroundColor: const Color.fromRGBO(255, 255, 255, 1),
          elevation: 3,
        ),
      ),
      home: Scaffold(
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }
}
