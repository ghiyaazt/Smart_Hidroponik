import 'package:flutter/material.dart';

class IotControllingPage extends StatelessWidget {
  const IotControllingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IoT Controlling'),
      ),
      body: const Center(
        child: Text(
          'Halaman Controlling IoT',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
