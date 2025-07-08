import 'package:flutter/material.dart';

class QrScanner extends StatelessWidget {
  const QrScanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 10, 113, 126),
        title: Text(
          "QR Scanner",
          style: TextStyle(
            color: Colors.lightBlueAccent,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Container(
        child: Text("This page is used to scan QR for UPI Payments."),
      ),
    );
  }
}
