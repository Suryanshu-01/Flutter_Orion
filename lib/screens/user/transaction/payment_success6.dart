import 'package:flutter/material.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final bool isSuccess;

  const PaymentSuccessScreen({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final Color bgColor = isSuccess ? Colors.green.shade100 : Colors.red.shade100;
    final Color iconColor = isSuccess ? Colors.green : Colors.red;
    final String statusText = isSuccess ? "Payment Successful!" : "Payment Failed!";
    final String buttonText = isSuccess ? "Back to Home" : "Try Again";

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text("Payment Status"),
        backgroundColor: bgColor,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline : Icons.cancel_outlined,
                size: 100,
                color: iconColor,
              ),
              const SizedBox(height: 20),
              Text(
                statusText,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: iconColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  if (isSuccess) {
                    Navigator.popUntil(context, (route) => route.isFirst);
                  } else {
                    Navigator.pop(context); // Back to EnterAmountScreen
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
