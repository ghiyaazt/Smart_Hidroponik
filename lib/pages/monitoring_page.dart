import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_animate/flutter_animate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  final dbRef = FirebaseDatabase.instance.ref();
  int tinggiAir = 0;
  int nutrisi = 0;
  bool isAuto = false;

  String selectedPlant = "Bayam Merah";
  final Map<String, Map<String, dynamic>> plantDetails = {
    "Bayam Merah": {
      "instructions":
          "1. Siapkan benih bayam merah.\n2. Rendam benih selama 24 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.0-7.0 dan suhu 20-25°C.",
      "ppm_min": 800,
      "ppm_max": 1200,
    },
    "Sawi": {
      "instructions":
          "1. Siapkan benih sawi.\n2. Rendam benih selama 12 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.0-6.5 dan suhu 18-24°C.",
      "ppm_min": 1000,
      "ppm_max": 1400,
    },
    "Kangkung": {
      "instructions":
          "1. Siapkn benih kangkung.\n2. Rendam benih selama 8 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.5-7.5 dan suhu 25-30°C.",
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
    dbRef.onValue.listen((event) {
      final data = event.snapshot.value as Map?;
      if (data != null) {
        setState(() {
          tinggiAir = data["tinggi_air"] ?? 0;
          nutrisi = data["nutrisi"] ?? 0;
          isAuto = data["otomatis"] ?? false;
        });
      }
    });
  }

  void tambahNutrisiSecaraManual() {
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Tambah Nutrisi Manual"),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: "Jumlah nutrisi (ppm)",
              hintText: "Contoh: 100",
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Batal"),
            ),
            ElevatedButton(
              onPressed: () async {
                final input = int.tryParse(controller.text);
                if (input != null && input > 0) {
                  final latestRef = dbRef.child("hidroponik/latest");
                  final snapshot = await latestRef.get();

                  if (snapshot.exists) {
                    final currentData = snapshot.value as Map?;
                    final currentNutrisi = currentData?["nutrisi"] ?? 0;
                    await latestRef.update({
                      "nutrisi": currentNutrisi + input,
                    });
                  }
                  Navigator.of(context).pop();
                }
              },
              child: const Text("Tambah"),
            ),
          ],
        );
      },
    );
  }

  void updateOtomatis(bool value) {
    dbRef.child("hidroponik/latest").update({"otomatis": value});
  }

  void showPlantInstructions(String plant) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Petunjuk Menanam $plant"),
          content:
              Text(plantDetails[plant]?["instructions"] ?? "Petunjuk tidak tersedia."),
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
                  icon: Icons.water_drop,
                  iconColor: Colors.blue,
                  value: "$tinggiAir%",
                  label: "Tinggi Air",
                ).animate().fadeIn(duration: 500.ms).scale(),
                MonitoringCard(
                  icon: Icons.local_florist,
                  iconColor: Colors.green,
                  value: "$nutrisi ppm",
                  label: "Nutrisi",
                ).animate().fadeIn(duration: 600.ms).scale(),
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
            ).animate().fadeIn(duration: 800.ms).slideY(begin: 0.3),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: tambahNutrisiSecaraManual,
              icon: const Icon(Icons.add),
              label: const Text("Tambah Nutrisi Manual"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
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
