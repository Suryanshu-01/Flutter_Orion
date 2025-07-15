import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'loginPin': pin,
      }, SetOptions(merge: true));

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
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "Enter PIN",
                labelStyle: const TextStyle(color: Colors.black87),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF018594), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _confirmPinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                labelText: "Confirm PIN",
                labelStyle: const TextStyle(color: Colors.black87),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFF018594), width: 2),
                ),
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _savePin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF018594),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        foregroundColor: Colors.white,
                        elevation: 3,
                      ),
                      child: const Text(
                        "Save and Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
