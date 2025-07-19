import 'package:flutter/material.dart';

class AnimatedTotalCounter extends StatelessWidget {
  final double totalAmount;
  final TextStyle? textStyle;

  const AnimatedTotalCounter({
    super.key,
    required this.totalAmount,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: totalAmount),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Text(
          "Total this year: ₹${value.toStringAsFixed(2)}",
          style: textStyle ??
              const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.amber, 
              ),
        );
      },
    );
  }
}
