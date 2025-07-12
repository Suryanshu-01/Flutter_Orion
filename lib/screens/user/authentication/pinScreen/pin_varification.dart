import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinput/pinput.dart';
import '../../dashboard/dashboard_screen.dart';

class LoginPinScreen extends StatefulWidget {
  const LoginPinScreen({super.key});

  @override
  State<LoginPinScreen> createState() => _LoginPinScreenState();
}

class _LoginPinScreenState extends State<LoginPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool _isError = false;

  Future<void> _verifyPin(String enteredPin) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _showError("User not logged in.");
        return;
      }

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final data = userDoc.data();

      if (data == null || !data.containsKey('loginPin')) {
        _showError("No login PIN found. Please register again.");
        return;
      }

      final storedPin = data['loginPin'];

      if (enteredPin == storedPin) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        setState(() => _isError = true);
      }
    } catch (e) {
      _showError("Error verifying PIN: ${e.toString()}");
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login PIN", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.cyan.shade700,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.cyan.shade700, Colors.cyan.shade100],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Enter your 4-digit PIN",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Pinput(
                    controller: _pinController,
                    length: 4,
                    obscureText: true,
                    defaultPinTheme: PinTheme(
                      width: 56,
                      height: 56,
                      textStyle: const TextStyle(
                        fontSize: 20,
                        color: Colors.black,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.cyan.shade50,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.cyan.shade700),
                      ),
                    ),
                    onCompleted: (pin) => _verifyPin(pin),
                  ),
                  const SizedBox(height: 20),
                  if (_isError)
                    const Text(
                      'Incorrect PIN. Try again.',
                      style: TextStyle(color: Colors.red),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
