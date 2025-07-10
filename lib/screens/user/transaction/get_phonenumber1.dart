import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:orion/screens/user/transaction/varify_phone_details2.dart';

class GetPhoneNumber extends StatefulWidget {
  const GetPhoneNumber({super.key});

  @override
  State<GetPhoneNumber> createState() => _GetPhoneNumberState();
}

class _GetPhoneNumberState extends State<GetPhoneNumber> {
  final TextEditingController _phoneController = TextEditingController();
  bool _isValid = false;

  void _validatePhone(String value) {
    setState(() {
      _isValid = value.length == 10 && RegExp(r'^[0-9]+$').hasMatch(value);
    });
  }

  void _goToNextScreen() {
    final phoneNumber = _phoneController.text.trim();
    if (_isValid) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyPhoneDetails(phone: phoneNumber),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a valid 10-digit phone number')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor, // ✅ Respect theme
        title: const Text("Phone Transfer"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Enter recipient's phone number",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(10),
                ],
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "Phone Number",
                  hintText: "Enter 10-digit phone number",
                ),
                onChanged: _validatePhone,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isValid ? _goToNextScreen : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isValid ? Colors.blue : Colors.grey,
                  ),
                  child: const Text("Continue"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
