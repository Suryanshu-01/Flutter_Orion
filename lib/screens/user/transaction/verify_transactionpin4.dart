import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'transfer_screen5.dart'; // Make sure this contains TransferProcessingScreen

class VerifyTransactionPinScreen extends StatefulWidget {
  final String receiverPhone;
  final double amount;
  final String paymentType; // ✅ Added

  const VerifyTransactionPinScreen({
    super.key,
    required this.receiverPhone,
    required this.amount,
    required this.paymentType, // ✅ Added
  });

  @override
  State<VerifyTransactionPinScreen> createState() => _VerifyTransactionPinScreenState();
}

class _VerifyTransactionPinScreenState extends State<VerifyTransactionPinScreen> {
  final TextEditingController _pinController = TextEditingController();
  bool isLoading = false;

  void _verifyPin() async {
    final enteredPin = _pinController.text.trim();
    final user = FirebaseAuth.instance.currentUser;

    if (enteredPin.length != 4) {
      _showError("PIN must be 4 digits");
      return;
    }

    setState(() => isLoading = true);

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final data = doc.data();
      final correctPin = data?['transactionPin'];

      if (enteredPin == correctPin) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => TransferProcessingScreen(
              receiverPhone: widget.receiverPhone,
              amount: widget.amount,
              paymentType: widget.paymentType, // ✅ Pass it here
            ),
          ),
        );
      } else {
        _showError("Incorrect PIN");
      }
    } catch (e) {
      _showError("Something went wrong: $e");
    }

    setState(() => isLoading = false);
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Transaction PIN")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Text(
              "Enter your 4-digit transaction PIN to proceed",
              style: TextStyle(fontSize: 18),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            TextField(
              controller: _pinController,
              keyboardType: TextInputType.number,
              obscureText: true,
              maxLength: 4,
              decoration: const InputDecoration(
                labelText: "Transaction PIN",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: isLoading ? null : _verifyPin,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Pay", style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
