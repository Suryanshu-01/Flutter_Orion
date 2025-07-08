import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pin_transaction.dart'; // import your next screen

class SetLoginPinScreen extends StatefulWidget {
  const SetLoginPinScreen({super.key});

  @override
  State<SetLoginPinScreen> createState() => _SetLoginPinScreenState();
}

class _SetLoginPinScreenState extends State<SetLoginPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmPinController = TextEditingController();

  bool _isLoading = false;

  Future<void> _savePin() async {
    final pin = _pinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (pin.length != 4 || confirmPin.length != 4) {
      _showError("PIN must be exactly 4 digits.");
      return;
    }

    if (pin != confirmPin) {
      _showError("PINs do not match.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      // Save to Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'loginPin': pin,
      }, SetOptions(merge: true));

      // Optional: Save locally
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('loginPin', pin);

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SetTransactionPinScreen()),
      );
    } catch (e) {
      _showError("Failed to save PIN: ${e.toString()}");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Set Login PIN")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              "Enter a 4-digit PIN to secure app login.",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: "Enter PIN"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(labelText: "Confirm PIN"),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _savePin,
                    child: const Text("Save and Continue"),
                  ),
          ],
        ),
      ),
    );
  }
}
