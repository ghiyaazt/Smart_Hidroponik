import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isNotificationEnabled = false; // Status notifikasi

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              'Pengaturan Notifikasi',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              title: const Text('Aktifkan Notifikasi'),
              trailing: Switch(
                value: _isNotificationEnabled,
                onChanged: (bool value) {
                  setState(() {
                    _isNotificationEnabled = value; // Mengubah status notifikasi
                  });
                  // Anda dapat menambahkan logika untuk menyimpan status notifikasi di sini
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Logika untuk menyimpan pengaturan (misalnya, ke Firebase atau SharedPreferences)
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pengaturan disimpan!')),
                );
              },
              child: const Text('Simpan Pengaturan'),
            ),
          ],
        ),
      ),
    );
  }
}
