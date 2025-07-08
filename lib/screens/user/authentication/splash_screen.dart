import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'select_user.dart';
import 'dart:math';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Align(
        alignment: Alignment.center,
        child: Transform.rotate(
          angle: pi, // Rotate 180 degrees
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: Lottie.asset(
              'assets/animations/Flow_1.json',
              fit: BoxFit.contain,
              repeat: false,
              onLoaded: (composition) {
                // Navigate after animation finishes
                Future.delayed(composition.duration, () {
                  if (mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SelectUser(),
                      ),
                    );
                  }
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
