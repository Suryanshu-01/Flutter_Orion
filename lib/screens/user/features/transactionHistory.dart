import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TransactionHistoryScreen extends StatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  State<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends State<TransactionHistoryScreen> {
  final user = FirebaseAuth.instance.currentUser;

  Future<List<Map<String, dynamic>>> _fetchTransactions() async {
    if (user == null) return [];

    final uid = user!.uid;

    final snapshot = await FirebaseFirestore.instance
        .collection('transactions')
        .where('participants', arrayContains: uid)
        .get();

    final transactions = snapshot.docs.map((doc) => doc.data()).toList();

    // Sort transactions by datetime
    transactions.sort((a, b) {
      final dateTimeA = DateTime.tryParse('${a['date']} ${a['time']}') ?? DateTime.now();
      final dateTimeB = DateTime.tryParse('${b['date']} ${b['time']}') ?? DateTime.now();
      return dateTimeB.compareTo(dateTimeA); // Newest first
    });

    return transactions;
  }

  Widget _buildTransactionTile(Map<String, dynamic> data) {
    final currentUserId = user!.uid;
    final isSender = data['from'] == currentUserId;
    final otherUserId = isSender ? data['to'] : data['from'];
    final amount = data['amount'] ?? 0.0;
    final date = data['date'] ?? '';
    final time = data['time'] ?? '';
    final category = data['category'] ?? 'Miscellaneous';

    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('users').doc(otherUserId).get(),
      builder: (context, snapshot) {
        String name = 'Unknown';
        if (snapshot.hasData && snapshot.data!.exists) {
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          name = userData['name'] ?? userData['phone'] ?? 'Unknown';
        }

        return ListTile(
          leading: Icon(
            isSender ? Icons.arrow_upward : Icons.arrow_downward,
            color: isSender ? Colors.red : Colors.green,
          ),
          title: Text('${isSender ? 'Paid to' : 'Received from'} $name'),
          subtitle: Text('$category • $date • $time'),
          trailing: Text(
            '₹${amount.toString()}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isSender ? Colors.red : Colors.green,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Transaction History")),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF232526), // dark gray
              Color(0xFF0f2027), // almost black
              Color(0xFF000000), // black
            ],
          ),
        ),
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _fetchTransactions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError || !snapshot.hasData) {
              return const Center(child: Text("Error fetching transactions"));
            }

            final transactions = snapshot.data!;
            if (transactions.isEmpty) {
              return const Center(child: Text("No transactions yet"));
            }

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) =>
                  _buildTransactionTile(transactions[index]),
            );
          },
        ),
      ),
    );
  }
}
