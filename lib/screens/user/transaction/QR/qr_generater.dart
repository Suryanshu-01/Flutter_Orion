import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pretty_qr_code/pretty_qr_code.dart';

class GenerateQrCodeScreen extends StatelessWidget {
  const GenerateQrCodeScreen({super.key});

  Future<String?> _getUsername(String uid) async {
    try {
      final snapshot =
          await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final data = snapshot.data();
      return data?['name'] ?? 'User';
    } catch (e) {
      return 'User';
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null || user.phoneNumber == null) {
      return const Scaffold(
        body: Center(child: Text("User not logged in or missing phone number")),
      );
    }

    final uid = user.uid;
    final phoneNumber = user.phoneNumber!;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Your QR Code"),
        centerTitle: true,
        backgroundColor: Colors.deepPurpleAccent,
      ),
      body: FutureBuilder<String?>(
        future: _getUsername(uid),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final username = snapshot.data!;

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 250,
                        height: 250,
                        child: PrettyQrView.data(
                          data: phoneNumber,
                          errorCorrectLevel: QrErrorCorrectLevel.M,
                          decoration:const PrettyQrDecoration(
                            shape: PrettyQrSmoothSymbol(),
                            background: Color.fromARGB(255, 63, 203, 245),)
                          ),
                        ),
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: Image.asset(
                          'assets/images/icon.png', // ✅ Update to your logo path
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  "Scan to pay\n$username",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
