import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/transaction/get_amount.dart';

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

    if (phoneNumber.length != 10) {
      setState(() {
        errorText = "Phone number must be exactly 10 digits.";
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
      appBar: AppBar(title: const Text("Verify Phone Details")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Phone number: ${widget.phone}",
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  if (userFound)
                    Text(
                      "User Name: $userName",
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  if (errorText.isNotEmpty)
                    Text(
                      errorText,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: userFound ? _goToNextScreen : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: userFound ? Colors.blue : Colors.white,
                      ),
                      child: const Text("Pay"),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
