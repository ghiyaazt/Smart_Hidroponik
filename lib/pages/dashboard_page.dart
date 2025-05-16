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

  // Daftar kategori yang valid
  final List<String> categories = ['selada', 'bayam'];

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _setupDatabaseListener();
  }

  // Fungsi untuk cek apakah kategori valid
  bool isValidCategory(String? category) {
    return category != null && categories.contains(category);
  }

  // Memuat kategori awal dari Firebase
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
          selectedCategory = null; // Atau beri default seperti 'selada'
        });
      }
    } else {
      setState(() {
        selectedCategory = null; // Atau beri default seperti 'selada'
      });
    }
  }

  // Mendengarkan perubahan nilai di Firebase
  void _setupDatabaseListener() {
    _database.child('hidroponik/jenisTanaman').onValue.listen((event) {
      if (event.snapshot.exists && mounted) {
        final value = event.snapshot.value.toString();
        if (isValidCategory(value)) {
          setState(() {
            selectedCategory = value;
          });
        } else {
          setState(() {
            selectedCategory = null; // Atau default
          });
        }
      }
    });
  }

  // Mengupdate nilai di Firebase saat dropdown berubah
  void _updateCategory(String? newValue) {
    if (newValue != null) {
      _database.child('hidroponik/jenisTanaman').set(newValue);
      // Tidak perlu setState di sini karena listener Firebase akan mengupdate
    }
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
                  color: Colors.white.withOpacity(0.2), // putih transparan
                  borderRadius: BorderRadius.circular(15), // bulat sesuai keinginan
                ),
                child: DropdownButtonFormField2<String>(
                  isExpanded: true,
                  value: isValidCategory(selectedCategory) ? selectedCategory : null,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    filled: false,              // jangan isi background di sini, sudah di Container
                    border: InputBorder.none,   // hilangkan border
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
              )
            ],
          ),
        ),
      ),
    );
  }
}
