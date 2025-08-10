import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AnimatedTotalCounter extends StatelessWidget {
  final double totalAmount;
  final String label;
  final TextStyle? textStyle;
  final TextStyle? labelStyle;

  const AnimatedTotalCounter({
    super.key,
    required this.totalAmount,
    required this.label,
    this.textStyle,
    this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: labelStyle ??
              GoogleFonts.staatliches(
                textStyle: const TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
        ),
        const SizedBox(height: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: totalAmount),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Text(
              "₹${value.toStringAsFixed(2)}",
              style: textStyle ??
                  GoogleFonts.staatliches(
                    textStyle: const TextStyle(
                      fontSize: 32,
                      color: Colors.amber,
                    ),
                  ),
            );
          },
        ),
      ],
    );
  }
}
