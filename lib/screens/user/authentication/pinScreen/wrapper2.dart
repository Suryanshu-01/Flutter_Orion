import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orion/screens/user/authentication/pinScreen/setlogin.dart';
import 'package:orion/screens/user/authentication/pinScreen/getlogin.dart';

class Wrapper2 extends StatefulWidget {
  const Wrapper2({super.key});

  @override
  State<Wrapper2> createState() => _Wrapper2State();
}

class _Wrapper2State extends State<Wrapper2> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authSnapshot.data;

          if (user == null) {
            // If no user is logged in, redirect to signup
            return const Center(
              child: Text(
                "Please login first",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }

          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const Center(
                  child: Text(
                    "User data not found. Please complete user setup first.",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

              if (userData == null || !userData.containsKey('adminLoginPin')) {
                return const SetAdminLoginPinScreen(); // Set admin PIN for first time
              }

              return const AdminLoginPinScreen(); // Verify admin PIN for subsequent access
            },
          );
        },
      ),
    );
  }
}
