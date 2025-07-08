import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orion/screens/user/transaction/payment_success.dart';

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

  void _payAmount() async {
    final double amount = double.parse(_amountController.text.trim());

    bool result = await transferAmount(
      context,
      receiverPhone: widget.receiverPhone,
      amount: amount,
    );

    if (!mounted) return;

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
                  Text("Wallet Balance: ₹$_walletBalance",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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

Future<bool> transferAmount(
  BuildContext context, {
  required String receiverPhone,
  required double amount,
}) async {
  final firestore = FirebaseFirestore.instance;
  final auth = FirebaseAuth.instance;
  final sender = auth.currentUser;

  if (sender == null) {
    showMessage(context, "Sender not logged in");
    return false;
  }

  try {
    final senderRef = firestore.collection('users').doc(sender.uid);

    await firestore.runTransaction((transaction) async {
      final senderSnap = await transaction.get(senderRef);
      if (!senderSnap.exists) throw Exception("Sender not found");

      double senderBalance = senderSnap['walletBalance'] ?? 0.0;
      if (senderBalance < amount) throw Exception("Insufficient balance");

      final receiverQuery = await firestore
          .collection('users')
          .where('phone', isEqualTo: receiverPhone)
          .get();

      if (receiverQuery.docs.isEmpty) {
        throw Exception("Receiver not found");
      }

      final receiverDoc = receiverQuery.docs.first;
      final receiverRef = receiverDoc.reference;
      final receiverBalance = receiverDoc['walletBalance'] ?? 0.0;

      transaction.update(senderRef, {
        'walletBalance': senderBalance - amount,
      });

      transaction.update(receiverRef, {
        'walletBalance': receiverBalance + amount,
      });

      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());

      final debitRef = firestore.collection('transactions').doc();
      transaction.set(debitRef, {
        'from': sender.uid,
        'to': receiverDoc.id,
        'amount': amount,
        'date': today,
        'type': 'debit',
      });

      final creditRef = firestore.collection('transactions').doc();
      transaction.set(creditRef, {
        'from': sender.uid,
        'to': receiverDoc.id,
        'amount': amount,
        'date': today,
        'type': 'credit',
      });
    });

    return true;
  } catch (e) {
    return false;
  }
}

void showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message)),
  );
}
