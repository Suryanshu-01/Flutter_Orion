import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orion/screens/user/authentication/signup_screen.dart';
import 'package:orion/screens/user/authentication/pinScreen/pin_loginScreen.dart';
import 'package:orion/screens/user/authentication/user_deatils.dart';
import 'package:orion/screens/user/transaction/get_phoneNumber.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // User is NOT signed in
          if (!snapshot.hasData) {
            return const SignupScreen();
          }

          final user = snapshot.data;

          // User is signed in → check Firestore
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user!.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const UserDetailsScreen(); // ✅ go here if doc missing
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

              if (userData != null && userData.containsKey('loginPin')) {
                return const GetPhoneNumber(); // ✅ Go to PIN verification
              } else {
                return const SetLoginPinScreen(); // ✅ Go to PIN setup
              }
            },
          );
        },
      ),
    );
  }
}
