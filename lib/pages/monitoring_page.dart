import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Hidroponik',
      theme: ThemeData(
        primarySwatch: Colors.green,
        fontFamily: 'Poppins',
      ),
      home: const MonitoringPage(),
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
  DateTime? lastUpdate;
  bool pompa1Nyala = false;
  bool pompa2Nyala = false;


  String selectedPlant = "Bayam Merah";
  final Map<String, Map<String, dynamic>> plantDetails = {
    "Bayam Merah": {
      "instructions": "1. Siapkan benih bayam merah.\n2. Rendam benih selama 24 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.0-7.0 dan suhu 20-25°C.",
      "ppm_min": 800,
      "ppm_max": 1200,
      "color": Colors.redAccent,
    },
    "Sawi": {
      "instructions": "1. Siapkan benih sawi.\n2. Rendam benih selama 12 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.0-6.5 dan suhu 18-24°C.",
      "ppm_min": 1000,
      "ppm_max": 1400,
      "color": Colors.green,
    },
    "Kangkung": {
      "instructions": "1. Siapkan benih kangkung.\n2. Rendam benih selama 8 jam.\n3. Pindahkan ke media tanam hidroponik.\n4. Pastikan pH air 6.5-7.5 dan suhu 25-30°C.",
      "ppm_min": 600,
      "ppm_max": 1000,
      "color": Colors.lightGreen,
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
        pompa1Nyala = data["pompa_nutrisi_1"] ?? false;
        pompa2Nyala = data["pompa_nutrisi_2"] ?? false;
        lastUpdate = DateTime.now();
      });
    }
  });
}


    @override
  Widget build(BuildContext context) {
    final selectedPlantDetails = plantDetails[selectedPlant];
    final isNutrisiWarning = selectedPlantDetails != null &&
        (nutrisi < selectedPlantDetails["ppm_min"] || nutrisi > selectedPlantDetails["ppm_max"]);
    final plantColor = selectedPlantDetails?["color"] ?? Colors.green;

    return Scaffold(
      appBar: AppBar(
        title: const Text("HydroMonitor"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: ambilData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Status Card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Status Sistem",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        if (lastUpdate != null)
                          Text(
                            "Terakhir update: ${DateFormat('HH:mm:ss').format(lastUpdate!)}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade500,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatusCard(
                            icon: Icons.water_drop,
                            value: "$tinggiAir%",
                            label: "Tinggi Air",
                            color: Colors.blue,
                          ).animate().fadeIn(duration: 500.ms).slideX(begin: -01),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildStatusCard(
                            icon: Icons.eco,
                            value: "$nutrisi ppm",
                            label: "Nutrisi",
                            color: isNutrisiWarning ? Colors.orange : plantColor,
                            isWarning: isNutrisiWarning,
                          ).animate().fadeIn(duration: 600.ms).slideX(begin: 0.1),
                        ),
                      ],
                    ),const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPompaStatusCard(
                            label: "Pompa Nutrisi 1",
                            isOn: pompa1Nyala,
                            color: Colors.green,
                          ).animate().fadeIn(duration: 700.ms).slideX(begin: -0.1),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildPompaStatusCard(
                            label: "Pompa Nutrisi 2",
                            isOn: pompa2Nyala,
                            color: Colors.purple,
                          ).animate().fadeIn(duration: 800.ms).slideX(begin: 0.1),
                        ),
                      ],
                    ),

                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
    bool isWarning = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isWarning ? Colors.orange.shade300 : Colors.grey.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isWarning ? Colors.orange : color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 12,
            ),
          ),
        ],
      ),
      
    );
  }
  Widget _buildPompaStatusCard({
  required String label,
  required bool isOn,
  required Color color,
}) {
  return Container(
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: isOn ? color.withOpacity(0.5) : Colors.grey.shade300,
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isOn ? color.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.local_drink,
            color: isOn ? color : Colors.grey,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isOn ? "Nyala" : "Mati",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isOn ? color : Colors.grey,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    ),
  );
}}