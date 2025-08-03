import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MoneyAddPage extends StatefulWidget {
  const MoneyAddPage({super.key});

  @override
  State<MoneyAddPage> createState() => _MoneyAddPageState();
}

class _MoneyAddPageState extends State<MoneyAddPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoading = false;

  Future<void> _addMoney() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final amount = double.tryParse(_amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Enter a valid amount')));
      return;
    }

    setState(() => _isLoading = true);

    final userDoc = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid);

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      final snapshot = await transaction.get(userDoc);
      final currentBalance = (snapshot.data()?['walletBalance'] ?? 0)
          .toDouble();
      transaction.update(userDoc, {'walletBalance': currentBalance + amount});
    });

    setState(() => _isLoading = false);
    _amountController.clear();

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Money added successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('Add Money'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _amountController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Enter amount',
                labelStyle: const TextStyle(color: Colors.white54),
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white54),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : ElevatedButton(
                    onPressed: _addMoney,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    child: const Text('Add Money'),
                  ),
          ],
        ),
      ),
    );
  }
}
