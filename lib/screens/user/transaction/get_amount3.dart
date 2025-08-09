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

  final List<String> _paymentTypes = [
    'Food',
    'Travel',
    'Entertainment',
    'Education',
    'Miscellaneous',
  ];
  String _selectedType = 'Miscellaneous';

  @override
  void initState() {
    super.initState();
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    if (user == null) return;

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .get();
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
      _isValidAmount =
          enteredAmount != null &&
          enteredAmount > 0 &&
          enteredAmount <= _walletBalance;
    });
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
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
          category: _selectedType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Enter Amount",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 33, 33),
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
<<<<<<< HEAD
              Color(0xFF232526),
              Color(0xFF0f2027),
              Color(0xFF000000),
=======
              Color.fromARGB(255, 23, 23, 23), // dark gray
              Color(0xFF0f2027), // almost black
              Color(0xFF000000), // black
>>>>>>> c63ba3e7dd9a8da61b0a4df2ff84d09e7a387fdf
            ],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Container(
              padding: const EdgeInsets.all(24),
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Wallet Balance: ₹$_walletBalance",
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _amountController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: "Enter Amount",
                      labelStyle: const TextStyle(color: Colors.black87),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 0, 0, 0),
                          width: 2,
                        ),
                      ),
                    ),
                    onChanged: _validateAmount,
                  ),
                  const SizedBox(height: 20),
                  DropdownButtonFormField<String>(
                    value: _selectedType,
                    decoration: InputDecoration(
                      labelText: "Payment Type",
                      labelStyle: const TextStyle(color: Colors.black87),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color.fromARGB(255, 46, 46, 46),
                          width: 2,
                        ),
                      ),
                    ),
                    items: _paymentTypes.map((type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Text(
                          type,
                          style: const TextStyle(color: Colors.black),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedType = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: (_isValidAmount && !_isLoading)
                          ? _goToPinVerification
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isValidAmount
                            ? const Color.fromARGB(255, 35, 35, 35)
                            : Colors.grey,
                        padding: const EdgeInsets.symmetric(vertical: 16),
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
                        "Continue",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
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