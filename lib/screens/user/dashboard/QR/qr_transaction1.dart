import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/transaction/get_amount3.dart';

class VerifyPhoneDetailsQR extends StatefulWidget {
  final String phone;
  const VerifyPhoneDetailsQR({
    super.key,
    required this.phone,
    required String phoneNumber,
  });

  @override
  State<VerifyPhoneDetailsQR> createState() => _VerifyPhoneDetailsQRState();
}

class _VerifyPhoneDetailsQRState extends State<VerifyPhoneDetailsQR> {
  String? userName;
  bool isLoading = false;
  bool userFound = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    _verifyPhone(widget.phone);
  }

  Future<void> _verifyPhone(String phoneNumber) async {
    setState(() {
      isLoading = true;
      userFound = false;
      userName = null;
      errorText = '';
    });

    if (phoneNumber.length != 10 ||
        !RegExp(r'^\d{10}$').hasMatch(phoneNumber)) {
      setState(() {
        errorText = "Please enter a valid 10-digit phone number.";
        isLoading = false;
      });
      return;
    }

    try {
      QuerySnapshot result = await FirebaseFirestore.instance
          .collection('users')
          .where('phone', isEqualTo: phoneNumber)
          .get();

      if (result.docs.isNotEmpty) {
        setState(() {
          userFound = true;
          userName = result.docs.first['name'];
          isLoading = false;
        });
      } else {
        setState(() {
          errorText = "User does not exist.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorText = "Something went wrong: ${e.toString()}";
        isLoading = false;
      });
    }
  }

  void _goToNextScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EnterAmountScreen(receiverPhone: widget.phone),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Registered Number: ",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 3,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black),
      ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.black)
                : Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.black, // Black card/container
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recipient Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // White text on black card
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Phone number: ${widget.phone}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (userFound)
                          Text(
                            "User Name: $userName",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        if (errorText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              errorText,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: userFound ? _goToNextScreen : null,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: userFound
                                      ? Colors.white
                                      : Colors.grey,
                                  foregroundColor: Colors.black,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 2,
                                ),
                                child: const Text(
                                  "Pay",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            TextButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.white,
                              ),
                              child: const Text(
                                "Edit",
                                style: TextStyle(fontSize: 16),
                              ),
                            ),
                          ],
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
