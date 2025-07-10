import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:orion/screens/user/authentication/signup_screen.dart';
import 'package:orion/screens/user/authentication/user_deatils.dart';
import 'package:orion/screens/user/authentication/pinScreen/pin_loginScreen.dart';
import 'package:orion/screens/user/authentication/pinScreen/pin_varification.dart'; // ✅ Rename for clarity

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
        builder: (context, authSnapshot) {
          if (authSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = authSnapshot.data;

          // ✅ Not logged in → go to Signup
          if (user == null) return const SignupScreen();

          // ✅ User logged in → check Firestore document
          return FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance.collection('users').doc(user.uid).get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return const UserDetailsScreen(); // 🔹 No profile found
              }

              final userData = userSnapshot.data!.data() as Map<String, dynamic>?;

              if (userData == null || !userData.containsKey('loginPin')) {
                return const SetLoginPinScreen(); // 🔹 User hasn't set login PIN yet
              }

              return const LoginPinScreen(); // 🔹 All good — verify login PIN
            },
          );
        },
      ),
    );
  }
}
