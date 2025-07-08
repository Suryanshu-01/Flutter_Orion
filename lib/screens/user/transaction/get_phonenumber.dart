import 'package:flutter/material.dart';
import 'package:orion/screens/user/transaction/varify_phone_details.dart';

class GetPhoneNumber extends StatefulWidget {
  const GetPhoneNumber({super.key});

  @override
  State<GetPhoneNumber> createState() => _GetPhoneNumberState();
}

class _GetPhoneNumberState extends State<GetPhoneNumber> {
  final TextEditingController _phoneController = TextEditingController();
  String phoneNumber = ''; // 🔹 This stores the user's input

  void _goToNextScreen() {
    phoneNumber = _phoneController.text.trim();

    if (phoneNumber.isNotEmpty) {
      // Example: Navigate and pass the phone number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyPhoneDetails(phone: phoneNumber),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a phone number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.cyanAccent),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter your phone number",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Phone Number",
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _goToNextScreen,
                child: const Text("Continue"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}