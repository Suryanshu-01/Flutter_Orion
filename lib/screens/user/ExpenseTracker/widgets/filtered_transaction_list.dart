import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FilteredTransactionList extends StatelessWidget {
  final DateTime startDate;
  final DateTime endDate;

  const FilteredTransactionList({
    super.key,
    required this.startDate,
    required this.endDate,
  });

  Future<List<Map<String, dynamic>>> _fetchFilteredTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];

    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('participants', arrayContains: uid)
        .where('status', isEqualTo: 'success')
        .get();

    final tx = snapshot.docs.map((doc) => doc.data()).toList();

    final filtered = tx.where((t) {
      final dateStr = t['date'] ?? '';
      final timeStr = t['time'] ?? '00:00';
      final fullDate = DateTime.tryParse('$dateStr $timeStr');
      if (fullDate == null) return false;
      return fullDate.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             fullDate.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();

    filtered.sort((a, b) {
      final dateA = DateTime.tryParse('${a['date'] ?? ''} ${a['time'] ?? '00:00'}') ?? DateTime.now();
      final dateB = DateTime.tryParse('${b['date'] ?? ''} ${b['time'] ?? '00:00'}') ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return filtered;
  }

  Future<Map<String, String>> _fetchUserNames(List<Map<String, dynamic>> transactions) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    Set<String> userIds = {};
    for (var data in transactions) {
      final isSender = data['from'] == currentUserId;
      final otherUserId = isSender ? data['to'] : data['from'];
      if (otherUserId != null) userIds.add(otherUserId);
    }
    Map<String, String> nameMap = {};
    for (final id in userIds) {
      final doc = await FirebaseFirestore.instance.collection('users').doc(id).get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        nameMap[id] = userData['name'] ?? userData['phone'] ?? 'Unknown';
      }
    }
    return nameMap;
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _fetchFilteredTransactions(),
      builder: (context, txSnapshot) {
        if (txSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!txSnapshot.hasData || txSnapshot.data!.isEmpty) {
          return const Center(child: Text("No transactions in this period."));
        }

        final transactions = txSnapshot.data!;
        return FutureBuilder<Map<String, String>>(
          future: _fetchUserNames(transactions),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final names = userSnapshot.data!;
            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final data = transactions[index];
                final isSender = data['from'] == currentUserId;
                final otherUserId = isSender ? data['to'] : data['from'];
                final amount = (data['amount'] ?? 0.0) as num;
                final date = data['date'] ?? '';
                final time = data['time'] ?? '';
                final category = data['category'] ?? 'Miscellaneous';
                final name = names[otherUserId] ?? 'Unknown';
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                  child: ListTile(
                    leading: Icon(
                      isSender ? Icons.arrow_upward : Icons.arrow_downward,
                      color: isSender ? Colors.red : Colors.green,
                    ),
                    title: Text('${isSender ? 'Paid to' : 'Received from'} $name'),
                    subtitle: Text('$category • $date • $time'),
                    trailing: Text(
                      '₹${amount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSender ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
