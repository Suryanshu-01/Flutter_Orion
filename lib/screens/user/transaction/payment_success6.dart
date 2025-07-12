import 'package:flutter/material.dart';
import '../dashboard/dashboard_screen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final bool isSuccess;

  const PaymentSuccessScreen({super.key, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final Color iconColor = isSuccess ? Colors.green : Colors.red;
    final String statusText = isSuccess
        ? "Payment Successful!"
        : "Payment Failed!";
    final String buttonText = isSuccess ? "Back to Home" : "Try Again";

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Payment Status",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              padding: const EdgeInsets.all(32),
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
                children: [
                  Icon(
                    isSuccess
                        ? Icons.check_circle_outline
                        : Icons.cancel_outlined,
                    size: 100,
                    color: iconColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    statusText,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isSuccess) {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const DashboardScreen(),
                            ),
                          );
                        } else {
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 18,
                          color: Colors.white,
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
