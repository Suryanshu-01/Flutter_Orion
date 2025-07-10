import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pinput/pinput.dart';
import 'package:orion/screens/user/transaction/get_phonenumber1.dart';

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

      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
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
          MaterialPageRoute(builder: (context) => const GetPhoneNumber()),
        );
      } else {
        setState(() => _isError = true);
      }
    } catch (e) {
      _showError("Error verifying PIN: ${e.toString()}");
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
      appBar: AppBar(title: const Text("Enter Login PIN")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Enter your 4-digit PIN",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              Pinput(
                controller: _pinController,
                length: 4,
                obscureText: true,
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
    );
  }
}
