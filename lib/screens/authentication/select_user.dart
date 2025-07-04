import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';
import '../admin/parent_dashboard.dart';

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DashboardScreen(),
                  ),
                );
              },
              child: const Text("Continue as User"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ParentDashboard(),
                  ),
                );
              },
              child: const Text("Continue as Admin"),
            ),
          ],
        ),
      ),
    );
  }
}
