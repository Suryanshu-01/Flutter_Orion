import 'package:flutter/material.dart';

class SelectUser extends StatelessWidget {
  const SelectUser({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select User"),
        backgroundColor: const Color(0xFF0F2027),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // TODO: Go to user screen
              },
              child: const Text("Continue as User"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Go to admin screen
              },
              child: const Text("Continue as Admin"),
            ),
          ],
        ),
      ),
    );
  }
}
