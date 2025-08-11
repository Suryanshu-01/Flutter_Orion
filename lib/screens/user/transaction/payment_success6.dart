import 'dart:math';
import 'package:animated_check/animated_check.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/homescreen.dart';

class PaymentSuccessScreen extends StatefulWidget {
  final bool isSuccess;

  const PaymentSuccessScreen({super.key, this.isSuccess = true});

  @override
  State<PaymentSuccessScreen> createState() => _PaymentSuccessScreenState();
}

class _PaymentSuccessScreenState extends State<PaymentSuccessScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _checkAnimation;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 1));

    _scaleAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);

    _checkAnimation =
        CurvedAnimation(parent: _controller, curve: Curves.easeOutCirc);

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<String> handleCouponReward() async {
    final List<String> brandCoupons = [
      'Boat.jpg',
      'Nykaa.jpg',
      'PVR.jpg',
      'Swiggy.jpg',
    ];
    final List<String> themeCoupons = [
      'itachic.jpg',
      'lightc.jpg',
      'luffyc.jpg',
      'madarac.jpg',
      'shanksc.jpg',
      'vegetac.jpg',
    ];

    final random = Random();
    final shouldGiveCoupon = random.nextInt(2) == 0; // 50% chance

    if (!shouldGiveCoupon) return 'Better Luck Next Time!';

    final allCoupons = [...brandCoupons, ...themeCoupons];
    final selectedCoupon = allCoupons[random.nextInt(allCoupons.length)];

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'userCoupons': FieldValue.arrayUnion([selectedCoupon]),
      });
    }

    return selectedCoupon;
  }

  bool isBrandCoupon(String filename) {
    return [
      'Boat.jpg',
      'Nykaa.jpg',
      'PVR.jpg',
      'Swiggy.jpg',
    ].contains(filename);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Payment Result"),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: widget.isSuccess
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: AnimatedCheck(
                      progress: _checkAnimation,
                      size: 220, 
                      color: Colors.green,
                      strokeWidth: 10,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Payment Successful",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await handleCouponReward();
                      final bool wonCoupon =
                          result != 'Better Luck Next Time!';

                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text(
                            wonCoupon
                                ? "🎉 Coupon Won!"
                                : "No Coupon This Time",
                          ),
                          content: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                wonCoupon
                                    ? "Coupon added to your Coupons Section!"
                                    : "Better Luck Next Time!",
                              ),
                              const SizedBox(height: 16),
                              if (wonCoupon)
                                Image.asset(
                                  'assets/coupon/${isBrandCoupon(result) ? 'brandcoupon' : 'cardcoupon'}/$result',
                                  height: 240,
                                  errorBuilder: (context, error, stackTrace) =>
                                      const Text(
                                        "❌ Unable to load coupon image.",
                                      ),
                                ),
                            ],
                          ),
                          actions: [
                            TextButton(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                              ),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => const HomeScreen()),
                                  (Route<dynamic> route) => false,
                                );
                              },
                              child: const Text("Continue"),
                            ),
                          ],
                        ),
                      );
                    },
                    child: const Text("Continue"),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: _scaleAnimation,
                    child: Icon(
                      Icons.close_rounded,
                      size:220 , 
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Payment Failed",
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const HomeScreen()),
                        (Route<dynamic> route) => false,
                      );
                    },
                    child: const Text("Go Back"),
                  ),
                ],
              ),
      ),
    );
  }
}
