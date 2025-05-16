import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'IoT Monitoring Demo',
      theme: ThemeData(primarySwatch: Colors.green),
      home: const HomePage(),
    );
  }
}

// Halaman awal (contoh) untuk navigasi ke IotMonitoringPage dengan animasi slide + fade
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Route createRouteToIotMonitoringPage() {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) =>
          const IotMonitoringPage(),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const beginOffset = Offset(0, 1); // Slide dari bawah
        const endOffset = Offset.zero;
        final tweenSlide = Tween(begin: beginOffset, end: endOffset)
            .chain(CurveTween(curve: Curves.ease));
        final tweenFade = Tween(begin: 0.0, end: 1.0);

        return SlideTransition(
          position: animation.drive(tweenSlide),
          child: FadeTransition(
            opacity: animation.drive(tweenFade),
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(createRouteToIotMonitoringPage());
          },
          child: const Text('Buka IoT Monitoring'),
        ),
      ),
    );
  }
}

// Halaman IoT Monitoring dengan tampilan dan animasi internal (sesuai kode kamu)
class IotMonitoringPage extends StatefulWidget {
  const IotMonitoringPage({super.key});

  @override
  _IotMonitoringPageState createState() => _IotMonitoringPageState();
}

class _IotMonitoringPageState extends State<IotMonitoringPage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String tds = "Loading...";
  String volumeAir = "Loading...";
  String relay1Status = "Loading...";
  String relay2Status = "Loading...";

  @override
  void initState() {
    super.initState();
    fetchTDS();
    fetchVolumeAir();
    listenRelayStatus();
  }

  Future<void> fetchTDS() async {
    final snapshot = await _database.child('/hidroponik/monitoring/tds').get();
    if (snapshot.exists) {
      setState(() {
        tds = snapshot.value.toString();
      });
    }
  }

  Future<void> fetchVolumeAir() async {
    final snapshot =
        await _database.child('/hidroponik/monitoring/volume_air').get();
    if (snapshot.exists) {
      setState(() {
        volumeAir = snapshot.value.toString();
      });
    }
  }

  void listenRelayStatus() {
    _database.child('/hidroponik/monitoring/relay1').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          relay1Status = event.snapshot.value.toString();
        });
      }
    });

    _database.child('/hidroponik/monitoring/relay2').onValue.listen((event) {
      if (event.snapshot.exists) {
        setState(() {
          relay2Status = event.snapshot.value.toString();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102F15)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'IoT Monitoring',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
          child: Column(
            children: [
              Hero(
                tag: 'iot-icon',
                child: Icon(
                  Icons.devices_other,
                  color: Colors.white.withOpacity(0.8),
                  size: 80,
                ),
              ),
              const SizedBox(height: 20),
              TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 600),
                tween: Tween(begin: 0, end: 1),
                builder: (context, value, child) => Opacity(
                  opacity: value,
                  child: Transform.translate(
                    offset: Offset(0, (1 - value) * 30),
                    child: child,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: fetchTDS,
                            child: _buildCard(
                              icon: Icons.science,
                              label: 'TDS',
                              value:
                                  '${double.tryParse(tds)?.toStringAsFixed(1) ?? "--"} ppm',
                              percent: ((double.tryParse(tds) ?? 0.0) / 1600.0)
                                  .clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: GestureDetector(
                            onTap: fetchVolumeAir,
                            child: _buildCard(
                              icon: Icons.water,
                              label: 'Volume',
                              value:
                                  '${double.tryParse(volumeAir)?.toStringAsFixed(1) ?? "--"} L',
                              percent:
                                  ((double.tryParse(volumeAir) ?? 0.0) / 18.0)
                                      .clamp(0.0, 1.0),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: _buildCard(
                            icon: Icons.water_drop,
                            label: 'Nutrisi A',
                            value: relay1Status,
                            percent: relay1Status == "ON" ? 1.0 : 0.0,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildCard(
                            icon: Icons.opacity,
                            label: 'Nutrisi B',
                            value: relay2Status,
                            percent: relay2Status == "ON" ? 1.0 : 0.0,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String label,
    required String value,
    required double percent,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(vertical: 18.0),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: CircularPercentIndicator(
          radius: 70,
          lineWidth: 10,
          percent: percent.clamp(0.0, 1.0),
          center: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: const Color(0xFFEAF1B1), size: 28),
              const SizedBox(height: 6),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFFEAF1B1),
                ),
              ),
            ],
          ),
          progressColor: const Color(0xFF102F15),
          backgroundColor: const Color(0xFFEBFADC),
          circularStrokeCap: CircularStrokeCap.round,
        ),
      ),
    );
  }
}