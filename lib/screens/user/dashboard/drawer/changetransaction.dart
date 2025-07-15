import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../dashboard_screen.dart';
import 'settings.dart';
import '../../authentication/select_user.dart';
import 'aboutus.dart';

class Changetransaction extends StatefulWidget {
  const Changetransaction({super.key});

  @override
  State<Changetransaction> createState() => _ChangetransactionState();
}

class _ChangetransactionState extends State<Changetransaction> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _showNewPinFields = false;
  bool _isLoading = false;

  final user = FirebaseAuth.instance.currentUser;

  void _checkCurrentPin() async {
    final enteredPin = _currentPinController.text.trim();
    if (enteredPin.length != 4) {
      _showMessage("PIN must be 4 digits");
      return;
    }

    if (user == null) {
      _showMessage("User not logged in");
      return;
    }

    setState(() => _isLoading = true);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final data = doc.data();
    final storedPin = data?['transactionPin'];

    if (enteredPin == storedPin) {
      setState(() {
        _showNewPinFields = true;
      });
    } else {
      _showMessage("Current PIN is incorrect");
    }

    setState(() => _isLoading = false);
  }

  void _updatePin() async {
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.length != 4) {
      _showMessage("New PIN must be 4 digits");
      return;
    }

    if (newPin != confirmPin) {
      _showMessage("PINs do not match");
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'transactionPin': newPin,
    });

    setState(() => _isLoading = false);

    _showMessage("Transaction PIN updated successfully");
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        title: const Text(
          "Change Transaction PIN",
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan[800]!, Colors.cyan[400]!],
                ),
              ),
              child: const Text(
                "Profile",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile Manager"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text("Admin/User"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SelectUser()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SettingsUser()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Us"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AboutUs()),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF232526), // dark gray
              Color(0xFF0f2027), // almost black
              Color(0xFF000000), // black
            ],
          ),
        ),
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _currentPinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: "Enter Current Transaction PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isLoading ? null : _checkCurrentPin,
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Verify Current PIN"),
            ),
            if (_showNewPinFields) ...[
              const SizedBox(height: 30),
              TextField(
                controller: _newPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: "Enter New PIN",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _confirmPinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                maxLength: 4,
                decoration: const InputDecoration(
                  labelText: "Confirm New PIN",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _updatePin,
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update PIN"),
              ),
              const SizedBox(height: 20),
              OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back to Settings"),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
