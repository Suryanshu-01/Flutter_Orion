import 'package:flutter/material.dart';

class MonthlyDetailScreen extends StatelessWidget {
  final int month;
  final String monthName;

  const MonthlyDetailScreen({
    super.key,
    required this.month,
    required this.monthName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Month Details'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Text(
          'You clicked on $monthName',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
