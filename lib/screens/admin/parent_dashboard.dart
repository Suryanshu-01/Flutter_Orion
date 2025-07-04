import 'package:flutter/material.dart';

class ParentDashboard extends StatelessWidget {
  const ParentDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Parent Dashboard"),
        backgroundColor: const Color(0xFF5CE1E6),
      ),
      body: const Center(
        child: Text(
          "This is the Parent Dashboard!",
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
