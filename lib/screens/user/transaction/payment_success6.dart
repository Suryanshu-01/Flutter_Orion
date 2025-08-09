import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/homescreen.dart';

class PaymentSuccessScreen extends StatelessWidget {
  final bool isSuccess;

  const PaymentSuccessScreen({super.key, this.isSuccess = true});

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
    final shouldGiveCoupon = random.nextInt(2) == 0; // 50% chance for now

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
      appBar: AppBar(title: const Text("Payment Result")),
      body: Center(
        child: isSuccess
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 100,
                    color: Color.fromARGB(255, 0, 0, 0),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Payment Successful",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () async {
                      final result = await handleCouponReward();
                      final bool wonCoupon = result != 'Better Luck Next Time!';

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
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const HomeScreen(),
                                  ),
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
                  const Icon(Icons.cancel, size: 100, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    "Payment Failed",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Go Back"),
                  ),
                ],
              ),
      ),
    );
  }
}
