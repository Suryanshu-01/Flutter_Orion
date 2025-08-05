import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class TransactionTile extends StatelessWidget {
  final Map<String, dynamic> data;
  final Map<String, String> userMap;

  const TransactionTile({super.key, required this.data, required this.userMap});

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isSender = data['from'] == currentUserId;
    final otherUserId = isSender ? data['to'] : data['from'];
    final amount = (data['amount'] ?? 0.0) as num;
    final date = data['date'] ?? '';
    final time = data['time'] ?? '';
    final category = data['category'] ?? 'Miscellaneous';
    final name = userMap[otherUserId] ?? 'Unknown';

    return ListTile(
      leading: Icon(
        isSender ? Icons.arrow_upward : Icons.arrow_downward,
        color: isSender ? Colors.redAccent : Colors.greenAccent,
      ),
      title: Text(
        '${isSender ? 'Paid to' : 'Received from'} $name',
        style: const TextStyle(color: Colors.white),
      ),
      subtitle: Text(
        '$category • $date • $time',
        style: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      trailing: Text(
        '₹${amount.toStringAsFixed(2)}',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: isSender ? Colors.redAccent : Colors.greenAccent,
        ),
      ),
    );
  }
}
