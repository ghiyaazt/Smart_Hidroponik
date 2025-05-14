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
          lastUpdate = DateTime.now();
        });
      }
    });
  }

  void tambahNutrisiSecaraManual() {
    final controller = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Tambah Nutrisi",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
                const SizedBox(height: 20),
                Form(
                  key: formKey,
                  child: TextFormField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: "Jumlah nutrisi (ppm)",
                      hintText: "Contoh: 100",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      prefixIcon: const Icon(Icons.add_circle_outline),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Masukkan jumlah nutrisi';
                      }
                      final input = int.tryParse(value);
                      if (input == null || input <= 0) {
                        return 'Masukkan angka yang valid (lebih dari 0)';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final input = int.parse(controller.text);
                            final latestRef = dbRef.child("hidroponik/latest");
                            final snapshot = await latestRef.get();

                            if (snapshot.exists) {
                              final currentData = snapshot.value as Map?;
                              final currentNutrisi = currentData?["nutrisi"] ?? 0;
                              await latestRef.update({
                                "nutrisi": currentNutrisi + input,
                              });

                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Berhasil menambahkan $input ppm nutrisi'),
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              }
                            }
                            Navigator.of(context).pop();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: const Text(
                          "Tambah",
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Petunjuk Menanam $plant",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  plantDetails[plant]?["instructions"] ?? "Petunjuk tidak tersedia.",
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("Tutup"),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
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
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Automatic Mode Card
            _buildAutomaticModeCard(),
            const SizedBox(height: 20),

            // Plant Selection
            _buildPlantSelectionCard(plantColor),
            const SizedBox(height: 20),

            // Nutrition Info
            if (selectedPlantDetails != null) _buildNutritionInfoCard(selectedPlantDetails, isNutrisiWarning),
            const SizedBox(height: 20),

            // Quick Actions
            _buildQuickActions(),
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

  Widget _buildAutomaticModeCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Mode Otomatis",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAuto ? "Mode otomatis aktif" : "Mode otomatis nonaktif",
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
                Switch.adaptive(
                  value: isAuto,
                  activeColor: Theme.of(context).primaryColor,
                  onChanged: (value) {
                    setState(() {
                      isAuto = value;
                    });
                    updateOtomatis(value);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlantSelectionCard(Color plantColor) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Pilihan Tanaman",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedPlant,
              decoration: InputDecoration(
                labelText: "Pilih tanaman",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              items: plantDetails.keys.map((plant) {
                return DropdownMenuItem(
                  value: plant,
                  child: Row(
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: plantDetails[plant]?["color"] ?? Colors.green,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(plant, style: const TextStyle(color: Colors.black)),
                    ],
                  ),
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
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionInfoCard(
      Map<String, dynamic> plantDetails, bool isWarning) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.info_outline, size: 20),
                const SizedBox(width: 8),
                Text(
                  "Informasi Nutrisi untuk $selectedPlant",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildNutritionRangeIndicator(
              currentValue: nutrisi.toDouble(),
              minValue: plantDetails["ppm_min"].toDouble(),
              maxValue: plantDetails["ppm_max"].toDouble(),
              isWarning: isWarning,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Minimum: ${plantDetails["ppm_min"]} ppm",
                  style: TextStyle(
                    color: nutrisi < plantDetails["ppm_min"]
                        ? Colors.red
                        : Colors.grey.shade600,
                  ),
                ),
                Text(
                  "Maksimum: ${plantDetails["ppm_max"]} ppm",
                  style: TextStyle(
                    color: nutrisi > plantDetails["ppm_max"]
                        ? Colors.red
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
            if (isWarning)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded,
                        color: Colors.orange, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      "Nutrisi di luar range optimal",
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionRangeIndicator({
    required double currentValue,
    required double minValue,
    required double maxValue,
    required bool isWarning,
  }) {
    final percentage = ((currentValue - minValue) / (maxValue - minValue))
        .clamp(0.0, 1.0)
        .toDouble();

    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 10,
              width: percentage * MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    isWarning ? Colors.orange.shade400 : Colors.green.shade400,
                    isWarning ? Colors.orange.shade600 : Colors.green.shade600,
                  ],
                ),
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            "$currentValue ppm",
            style: TextStyle(
              color: isWarning ? Colors.orange : Colors.green,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: tambahNutrisiSecaraManual,
            icon: const Icon(Icons.add_circle_outline),
            label: const Text("Tambah Nutrisi"),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: ambilData,
            icon: const Icon(Icons.refresh),
            label: const Text("Refresh"),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}