import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/transaction/payment_success.dart';
import 'package:orion/screens/user/transaction/payment.dart'; // transferAmount function

class EnterAmountScreen extends StatefulWidget {
  final String receiverPhone;
  const EnterAmountScreen({super.key, required this.receiverPhone});

  @override
  State<EnterAmountScreen> createState() => _EnterAmountScreenState();
}

class _EnterAmountScreenState extends State<EnterAmountScreen> {
  final TextEditingController _amountController = TextEditingController();
  double _walletBalance = 0.0;
  bool _isLoading = true;
  bool _isValidAmount = false;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user!.uid).get();
      final data = doc.data();
      if (data != null && data['walletBalance'] != null) {
        setState(() {
          _walletBalance = (data['walletBalance'] as num).toDouble();
          _isLoading = false;
        });
      } else {
        _showSnackBar("Wallet balance not found.");
      }
    } catch (e) {
      _showSnackBar("Error fetching wallet: $e");
    }
  }

  void _validateAmount(String value) {
    final double? enteredAmount = double.tryParse(value);
    setState(() {
      _isValidAmount = enteredAmount != null && enteredAmount > 0 && enteredAmount <= _walletBalance;
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  Future<void> _payAmount() async {
    final double amount = double.parse(_amountController.text.trim());

    bool result = await transferAmount(
      context,
      receiverPhone: widget.receiverPhone,
      amount: amount,
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => PaymentSuccessScreen(isSuccess: result),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter Amount")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  Text(
                    "Wallet Balance: ₹$_walletBalance",
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Enter amount",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _validateAmount,
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: _isValidAmount ? _payAmount : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValidAmount ? Colors.blue : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text("Pay", style: TextStyle(fontSize: 18)),
                  )
                ],
              ),
            ),
    );
  }
}
