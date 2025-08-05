import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orion/screens/user/ExpenseTracker/services/firebase_services.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/animated_total_counter.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/charts/monthly_bar_chart.dart';
import 'package:orion/screens/user/features/transactionHistory.dart';
import 'package:orion/screens/user/ExpenseTracker/monthly_detail_screen.dart';

class ExpenseTrackerScreen extends StatefulWidget {
  const ExpenseTrackerScreen({super.key});

  @override
  State<ExpenseTrackerScreen> createState() => _ExpenseTrackerScreenState();
}

class _ExpenseTrackerScreenState extends State<ExpenseTrackerScreen> {
  double _totalYearlyExpense = 0.0;
  bool _isLoading = true;
  String _userName = "";
  List<Map<String, dynamic>> _allTransactions = [];
  Timer? _holdTimer;
  bool _showTransactionOverlay = false;
  Map<String, String> _usersNameMap = {};

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final service = FirebaseService();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _isLoading = true);

    final totalFuture = service.fetchTotalYearlyExpense();
    final txFuture = _fetchAllTransactions();
    final nameFuture = fetchUserName(uid);

    final results = await Future.wait([totalFuture, txFuture, nameFuture]);
    final total = results[0] as double;
    final transactions = results[1] as List<Map<String, dynamic>>;
    final userName = results[2] as String;

    await _prefetchUserNames(transactions);

    setState(() {
      _totalYearlyExpense = total;
      _userName = userName;
      _allTransactions = transactions;
      _isLoading = false;
    });
  }

  Future<String> fetchUserName(String uid) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    if (snapshot.exists) {
      final data = snapshot.data() as Map<String, dynamic>;
      return data['name'] ?? "User";
    }
    return "User";
  }

  Future<List<Map<String, dynamic>>> _fetchAllTransactions() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return [];
    final query = await FirebaseFirestore.instance
        .collection('transactions')
        .where('participants', arrayContains: uid)
        .where('status', isEqualTo: 'success')
        .get();

    final tx = query.docs.map((doc) {
      final data = doc.data();
      final dateStr = data['date'] ?? '';
      final timeStr = data['time'] ?? '00:00';
      final parsed = DateTime.tryParse('$dateStr $timeStr');
      if (parsed != null) {
        data['parsedDate'] = parsed;
      }
      return data;
    }).toList();

    tx.sort((a, b) {
      final dateA = a['parsedDate'] as DateTime? ?? DateTime.now();
      final dateB = b['parsedDate'] as DateTime? ?? DateTime.now();
      return dateB.compareTo(dateA);
    });

    return tx;
  }

  Future<void> _prefetchUserNames(
    List<Map<String, dynamic>> transactions,
  ) async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    Set<String> userIds = {};
    for (var data in transactions) {
      final isSender = data['from'] == currentUserId;
      final otherUserId = isSender ? data['to'] : data['from'];
      if (otherUserId != null) userIds.add(otherUserId);
    }
    Map<String, String> nameMap = {};
    for (final id in userIds) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(id)
          .get();
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>;
        nameMap[id] = userData['name'] ?? userData['phone'] ?? 'Unknown';
      }
    }
    _usersNameMap = nameMap;
  }

  Widget _dashboardStyleTransactionTile(Map<String, dynamic> data) {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    final isSender = data['from'] == currentUserId;
    final otherUserId = isSender ? data['to'] : data['from'];
    final amount = (data['amount'] ?? 0.0) as num;
    final date = data['date'] ?? '';
    final time = data['time'] ?? '';
    final category = data['category'] ?? 'Miscellaneous';
    final name = _usersNameMap[otherUserId] ?? 'Unknown';

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

  void _onBarTapped(int monthIndex, String monthName) {
    final monthTx = _allTransactions.where((tx) {
      final parsed = tx['parsedDate'] as DateTime?;
      return parsed != null && parsed.month == monthIndex;
    }).toList();

    double total = 0;
    Map<String, double> categoryTotals = {};

    for (final tx in monthTx) {
      final amount = (tx['amount'] ?? 0).toDouble();
      final category = tx['category'] ?? 'Miscellaneous';
      total += amount;
      categoryTotals[category] = (categoryTotals[category] ?? 0) + amount;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MonthlyDetailScreen(
          monthName: monthName,
          transactions: monthTx,
          userMap: _usersNameMap,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // You may want to keep track of selectedMonth if you want selection highlighting on MonthlyBarChart
    return Stack(
      children: [
        Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: const Text(
              "Expense Tracker",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            iconTheme: const IconThemeData(color: Colors.black),
          ),
          body: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Hi $_userName 👋",
                      style: GoogleFonts.staatliches(
                        textStyle: const TextStyle(
                          fontSize: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : AnimatedTotalCounter(
                            label: "This Year Expense",
                            totalAmount: _totalYearlyExpense,
                            textStyle: GoogleFonts.staatliches(
                              textStyle: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.amber,
                              ),
                            ),
                            labelStyle: GoogleFonts.staatliches(
                              textStyle: const TextStyle(
                                fontSize: 32,
                                color: Color.fromARGB(179, 212, 31, 31),
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.only(bottom: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Monthly Expenses",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 220,
                      child: MonthlyBarChart(onBarTap: _onBarTapped),
                    ),
                  ],
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Recent Transactions",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _isLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          )
                        : _allTransactions.isEmpty
                        ? const Text(
                            "No transactions found.",
                            style: TextStyle(color: Colors.white70),
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _allTransactions.take(3).length,
                            itemBuilder: (context, index) =>
                                _dashboardStyleTransactionTile(
                                  _allTransactions[index],
                                ),
                          ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_showTransactionOverlay)
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
            child: GestureDetector(
              onTap: () => setState(() => _showTransactionOverlay = false),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: const TransactionHistoryScreen(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
