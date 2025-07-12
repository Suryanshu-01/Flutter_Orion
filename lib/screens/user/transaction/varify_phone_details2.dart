import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/transaction/get_amount3.dart';

class VerifyPhoneDetails extends StatefulWidget {
  final String phone;
  const VerifyPhoneDetails({super.key, required this.phone});

  @override
  State<VerifyPhoneDetails> createState() => _VerifyPhoneDetailsState();
}

class _VerifyPhoneDetailsState extends State<VerifyPhoneDetails> {
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
          "Verify Phone Details",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : Container(
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
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Recipient Details",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          "Phone number: ${widget.phone}",
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (userFound)
                          Text(
                            "User Name: $userName",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                        if (errorText.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Text(
                              errorText,
                              style: const TextStyle(
                                color: Colors.red,
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
                                      ? Colors.cyan.shade700
                                      : Colors.grey,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  "Pay",
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white,
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
                                foregroundColor: Colors.cyan.shade700,
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
