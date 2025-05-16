import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';

class IotControllingPage extends StatefulWidget {
  const IotControllingPage({super.key});

  @override
  State<IotControllingPage> createState() => _IotControllingPageState();
}

class _IotControllingPageState extends State<IotControllingPage> {
  final DatabaseReference _dbRef =
      FirebaseDatabase.instance.ref('hidroponik/control');

  String _mode = 'otomatis'; // default
  bool _relay1 = false;
  bool _relay2 = false;

  @override
  void initState() {
    super.initState();
    _listenToFirebase();
  }

  void _listenToFirebase() {
    _dbRef.child('mode').onValue.listen((event) {
      final newMode = event.snapshot.value.toString();
      setState(() => _mode = newMode);
    });

    _dbRef.child('relay1').onValue.listen((event) {
      setState(() => _relay1 = event.snapshot.value == 'ON');
    });

    _dbRef.child('relay2').onValue.listen((event) {
      setState(() => _relay2 = event.snapshot.value == 'ON');
    });
  }

  Future<void> _updateMode(String newMode) async {
    await _dbRef.child('mode').set(newMode);
  }

  Future<void> _updateRelayState(int relayNumber, bool isOn) async {
    final path = relayNumber == 1 ? 'relay1' : 'relay2';
    await _dbRef.child(path).set(isOn ? 'ON' : 'OFF');
  }

  @override
  Widget build(BuildContext context) {
    final isManual = _mode == 'manual';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF102F15)),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'IoT Controlling',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(milliseconds: 600),
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, (1 - value) * 30),
                child: child,
              ),
            );
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Hero(
                  tag: 'iot-icon',
                  child: Icon(
                    Icons.devices_other,
                    size: 100,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              Row(
                children: [
                  const Icon(Icons.settings_remote, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Mode Kontrol',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: ToggleButtons(
                  isSelected: [_mode == 'manual', _mode == 'otomatis'],
                  onPressed: (index) {
                    final selectedMode = index == 0 ? 'manual' : 'otomatis';
                    _updateMode(selectedMode);
                  },
                  color: Colors.white,
                  selectedColor: Colors.black,
                  fillColor: const Color(0xFFEAF1B1),
                  borderRadius: BorderRadius.circular(10),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Manual',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Otomatis',
                        style: GoogleFonts.poppins(),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Icon(Icons.opacity, color: Colors.white),
                  const SizedBox(width: 8),
                  Text(
                    'Kontrol Nutrisi',
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'Nutrisi A',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    secondary: const Icon(Icons.water_drop, color: Colors.white),
                    value: _relay1,
                    onChanged:
                        isManual ? (value) => _updateRelayState(1, value) : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    tileColor: Colors.transparent,
                  ),
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Theme(
                  data: Theme.of(context).copyWith(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                  ),
                  child: SwitchListTile(
                    title: Text(
                      'Nutrisi B',
                      style: GoogleFonts.poppins(color: Colors.white),
                    ),
                    secondary: const Icon(Icons.water_drop, color: Colors.white),
                    value: _relay2,
                    onChanged:
                        isManual ? (value) => _updateRelayState(2, value) : null,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    tileColor: Colors.transparent,
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