import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orion/screens/user/transaction/verify_transactionpin4.dart';

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

  // 🆕 Payment type options
  final List<String> _paymentTypes = ['Food', 'Travel', 'Entertainment', 'Education', 'Miscellaneous'];
  String _selectedType = 'Miscellaneous';

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
        setState(() => _isLoading = false);
      }
    } catch (e) {
      _showSnackBar("Error fetching wallet: $e");
      setState(() => _isLoading = false);
    }
  }

  void _validateAmount(String value) {
    final double? enteredAmount = double.tryParse(value);
    setState(() {
      _isValidAmount = enteredAmount != null &&
          enteredAmount > 0 &&
          enteredAmount <= _walletBalance;
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  void _goToPinVerification() {
    final amountText = _amountController.text.trim();
    final double? amount = double.tryParse(amountText);

    if (amount == null || amount <= 0 || amount > _walletBalance) {
      _showSnackBar("Please enter a valid amount within your balance");
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => VerifyTransactionPinScreen(
          receiverPhone: widget.receiverPhone,
          amount: amount,
          paymentType: _selectedType, // Pass type to next screen
        ),
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
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: "Enter amount",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: _validateAmount,
                  ),
                  const SizedBox(height: 20),

                  // 🆕 Dropdown for payment type
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    items: _paymentTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(type),
                      );
                    }).toList(),
                    decoration: const InputDecoration(
                      labelText: "Payment Type",
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: (_isValidAmount && !_isLoading) ? _goToPinVerification : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isValidAmount ? Colors.blue : Colors.grey,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                    ),
                    child: const Text("Continue", style: TextStyle(fontSize: 18)),
                  )
                ],
              ),
            ),
    );
  }
}
