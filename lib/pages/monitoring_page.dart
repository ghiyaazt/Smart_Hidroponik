import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Inisialisasi Firebase
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MonitoringPage(),
    );
  }
}

class MonitoringPage extends StatefulWidget {
  const MonitoringPage({super.key});

  @override
  State<MonitoringPage> createState() => _MonitoringPageState();
}

class _MonitoringPageState extends State<MonitoringPage> {
  final firestore = FirebaseFirestore.instance;
  double suhu = 0;
  double ph = 0;
  int tinggiAir = 0;
  int nutrisi = 0;
  bool isAuto = false;

  String selectedPlant = "Bayam Merah"; // Default pilihan tanaman
  final Map<String, Map<String, dynamic>> plantDetails = {
    "Bayam Merah": {
      "instructions": "1. Siapkan benih bayam merah.\n2. Rendam benih selama 24 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.0-7.0 dan suhu 20-25°C.",
      "ppm_min": 800,
      "ppm_max": 1200,
    },
    "Sawi": {
      "instructions": "1. Siapkan benih sawi.\n2. Rendam benih selama 12 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.0-6.5 dan suhu 18-24°C.",
      "ppm_min": 1000,
      "ppm_max": 1400,
    },
    "Kangkung": {
      "instructions": "1. Siapkan benih kangkung.\n2. Rendam benih selama 8 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.5-7.5 dan suhu 25-30°C.",
      "ppm_min": 600,
      "ppm_max": 1000,
    },
  };

  @override
  void initState() {
    super.initState();
    ambilData();
  }

  void ambilData() {
    firestore.collection("hidroponik").doc("latest").snapshots().listen((docSnapshot) {
      final data = docSnapshot.data();
      if (data != null) {
        setState(() {
          tinggiAir = data["tinggi_air"] ?? 0;
          ph = (data["ph"] ?? 0).toDouble();
          nutrisi = data["nutrisi"] ?? 0;
          suhu = (data["suhu"] ?? 0).toDouble();
          isAuto = data["otomatis"] ?? false;
        });
      }
    });
  }

  void updateOtomatis(bool value) {
    firestore.collection("monitoring").doc("data").update({"otomatis": value});
  }

  void showPlantInstructions(String plant) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Petunjuk Menanam $plant"),
          content: Text(plantDetails[plant]?["instructions"] ?? "Petunjuk tidak tersedia."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedPlantDetails = plantDetails[selectedPlant];

    return Scaffold(
      appBar: AppBar(title: const Text("Menu Monitoring")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.3,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                MonitoringCard(
                  icon: Icons.thermostat,
                  iconColor: Colors.orange,
                  value: "${suhu.toStringAsFixed(1)}°C",
                  label: "Suhu",
                ).animate().fadeIn(duration: 500.ms).scale(),
                MonitoringCard(
                  icon: Icons.science,
                  iconColor: Colors.teal,
                  value: ph.toString(),
                  label: "pH",
                ).animate().fadeIn(duration: 600.ms).scale(),
                MonitoringCard(
                  icon: Icons.water_drop,
                  iconColor: Colors.blue,
                  value: "$tinggiAir%",
                  label: "Tinggi Air",
                ).animate().fadeIn(duration: 700.ms).scale(),
                MonitoringCard(
                  icon: Icons.local_florist,
                  iconColor: Colors.green,
                  value: "$nutrisi ppm",
                  label: "Nutrisi",
                ).animate().fadeIn(duration: 800.ms).scale(),
              ],
            ),
            const SizedBox(height: 20),
            AutomaticFertilizerCard(
              isActive: isAuto,
              onToggle: (value) {
                setState(() {
                  isAuto = value;
                });
                updateOtomatis(value);
              },
            ).animate().fadeIn(duration: 1000.ms).slideY(begin: 0.3),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: selectedPlant,
              decoration: const InputDecoration(
                labelText: "Pilih Tanaman",
                border: OutlineInputBorder(),
              ),
              items: plantDetails.keys.map((plant) {
                return DropdownMenuItem(
                  value: plant,
                  child: Text(plant),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedPlant = value;
                  });
                  showPlantInstructions(value);
                }
              },
            ),
            const SizedBox(height: 20),
            if (selectedPlantDetails != null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Informasi Nutrisi untuk $selectedPlant",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "PPM Minimum: ${selectedPlantDetails["ppm_min"]} ppm",
                      style: const TextStyle(fontSize: 14),
                    ),
                    Text(
                      "PPM Maksimum: ${selectedPlantDetails["ppm_max"]} ppm",
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MonitoringCard extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const MonitoringCard({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: iconColor),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            label,
            style: TextStyle(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class AutomaticFertilizerCard extends StatelessWidget {
  final bool isActive;
  final ValueChanged<bool> onToggle;

  const AutomaticFertilizerCard({
    super.key,
    required this.isActive,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.greenAccent, Colors.green],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.spa_outlined, color: Colors.white, size: 36),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mode Otomatis Pupuk",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isActive
                        ? "Pemberian pupuk berjalan otomatis"
                        : "Mode otomatis nonaktif",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Switch.adaptive(
            value: isActive,
            activeColor: Colors.white,
            onChanged: onToggle,
          ),
        ],
      ),
    );
  }
}