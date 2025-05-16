import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  String? selectedCategory;
  bool isExpanded = false; // New state to track expansion

  // Daftar kategori yang valid
  final List<String> categories = ['selada', 'bayam'];
  
  // Informasi tanaman
  final Map<String, Map<String, dynamic>> plantInfo = {
    'selada': {
      'title': 'Selada Hidroponik',
      'description': 'Selada (Lactuca sativa) adalah tanaman sayuran daun yang cocok untuk sistem hidroponik karena pertumbuhannya yang cepat dan perawatan yang relatif mudah.',
      'growth': '30-45 hari',
      'ph': '5.5-6.5',
      'ec': '1.2-2.0 mS/cm',
      'temperature': '15-22°C',
      'tips': [
        'Gunakan larutan nutrisi seimbang dengan kandungan nitrogen tinggi',
        'Pastikan sirkulasi udara baik untuk mencegah penyakit jamur',
        'Panen di pagi hari ketika daun paling segar',
        'Jaga jarak tanam minimal 20cm untuk pertumbuhan optimal'
      ],
    },
    'bayam': {
      'title': 'Bayam Hidroponik',
      'description': 'Bayam (Amaranthus spp.) adalah tanaman kaya nutrisi yang tumbuh baik dalam sistem hidroponik dengan hasil panen yang melimpah.',
      'growth': '25-35 hari',
      'ph': '6.0-7.0',
      'ec': '1.8-2.3 mS/cm',
      'temperature': '18-25°C',
      'tips': [
        'Nutrisi tinggi nitrogen dan kalium untuk pertumbuhan daun',
        'Pencahayaan cukup 12-14 jam/hari',
        'Periksa akar secara berkala untuk kesehatan tanaman',
        'Panen dengan memetik daun terluar terlebih dahulu'
      ],
    },
  };

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _setupDatabaseListener();
  }

  bool isValidCategory(String? category) {
    return category != null && categories.contains(category);
  }

  void _loadCategories() async {
    DataSnapshot snapshot = await _database.child('hidroponik/jenisTanaman').get();
    if (snapshot.exists) {
      final value = snapshot.value.toString();
      if (isValidCategory(value)) {
        setState(() {
          selectedCategory = value;
        });
      } else {
        setState(() {
          selectedCategory = null;
        });
      }
    } else {
      setState(() {
        selectedCategory = null;
      });
    }
  }

  void _setupDatabaseListener() {
    _database.child('hidroponik/jenisTanaman').onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final value = event.snapshot.value.toString();
        if (isValidCategory(value)) {
          setState(() {
            selectedCategory = value;
            isExpanded = true; // Auto-expand when category is selected
          });
        } else {
          setState(() {
            selectedCategory = null;
            isExpanded = false;
          });
        }
      }
    });
  }

  void _updateCategory(String? newValue) {
    if (newValue != null) {
      _database.child('hidroponik/jenisTanaman').set(newValue);
      setState(() {
        isExpanded = true; // Auto-expand when selecting a new category
      });
    }
  }

  Widget _buildPlantInfo() {
    if (!isValidCategory(selectedCategory)) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 40),
          child: Text(
            'Pilih jenis tanaman untuk melihat informasi',
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      );
    }

    final info = plantInfo[selectedCategory]!;
    final primaryColor = const Color(0xFF728C5A);
    final lighterGreen = const Color(0xFF8BA888);
    final darkerGreen = const Color(0xFF5A7248);

    return Container(
      margin: const EdgeInsets.only(top: 20),
      decoration: BoxDecoration(
        color: lighterGreen.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with expand/collapse functionality
          InkWell(
            onTap: () {
              setState(() {
                isExpanded = !isExpanded;
              });
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  Icon(Icons.spa, color: Colors.white),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      info['title'] as String,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Icon(
                    isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                    color: Colors.white,
                    size: 30,
                  ),
                ],
              ),
            ),
          ),
          
          // Collapsible content
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: isExpanded ? CrossFadeState.showFirst : CrossFadeState.showSecond,
            firstChild: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    info['description'] as String,
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Spesifikasi teknis
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: darkerGreen.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        _buildSpecRow('Waktu Tumbuh', info['growth'] as String, Icons.timer),
                        const Divider(color: Colors.white54, height: 20),
                        _buildSpecRow('pH Optimal', info['ph'] as String, Icons.bloodtype),
                        const Divider(color: Colors.white54, height: 20),
                        _buildSpecRow('EC Nutrisi', info['ec'] as String, Icons.eco),
                        const Divider(color: Colors.white54, height: 20),
                        _buildSpecRow('Suhu Ideal', info['temperature'] as String, Icons.thermostat),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  
                  // Tips perawatan
                  Text(
                    'Tips Perawatan:',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  
                  const SizedBox(height: 10),
                  
                  Column(
                    children: (info['tips'] as List<String>).map((tip) => 
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check_circle, color: Colors.white, size: 18),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                tip,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ),
                ],
              ),
            ),
            secondChild: Container(),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecRow(String title, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.white),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Text(
            value,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Home',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 26,
          ),
        ),
        backgroundColor: const Color(0xFF728C5A),
      ),
      backgroundColor: const Color(0xFF728C5A),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: DropdownButtonFormField2<String>(
                  isExpanded: true,
                  value: isValidCategory(selectedCategory) ? selectedCategory : null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    filled: false,
                    border: InputBorder.none,
                  ),
                  hint: Text(
                    'Pilih kategori sayuran',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                  items: categories
                      .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item[0].toUpperCase() + item.substring(1),
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ))
                      .toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Silakan pilih jenis tanaman.';
                    }
                    return null;
                  },
                  onChanged: _updateCategory,
                  onSaved: (value) {
                    selectedCategory = value;
                  },
                  buttonStyleData: const ButtonStyleData(
                    padding: EdgeInsets.only(right: 8),
                  ),
                  iconStyleData: const IconStyleData(
                    icon: Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    iconSize: 24,
                  ),
                  dropdownStyleData: DropdownStyleData(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                  menuItemStyleData: const MenuItemStyleData(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                  ),
                ),
              ),
              
              // Menampilkan informasi tanaman
              _buildPlantInfo(),
            ],
          ),
        ),
      ),
    );
  }
}