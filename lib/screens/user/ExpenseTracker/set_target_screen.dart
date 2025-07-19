import 'package:flutter/material.dart';

class SetTargetScreen extends StatelessWidget {
  const SetTargetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Set Target"),
        backgroundColor: Colors.deepPurple,
      ),
      body: const Center(
        child: Text(
          "Target Set Screen Pressed",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}