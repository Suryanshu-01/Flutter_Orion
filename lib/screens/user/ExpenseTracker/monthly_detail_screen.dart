import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/animated_total_counter.dart';
import 'widgets/charts/category_bar_chart.dart';
import 'widgets/charts/category_pie_chart.dart';
import 'widgets/transaction_tile.dart';

class MonthlyDetailScreen extends StatefulWidget {
  final String monthName;
  final List<Map<String, dynamic>> transactions;
  final Map<String, String> userMap;
  const MonthlyDetailScreen({
    super.key,
    required this.monthName,
    required this.transactions,
    required this.userMap,
  });

  @override
  State<MonthlyDetailScreen> createState() => _MonthlyDetailScreenState();
}

class _MonthlyDetailScreenState extends State<MonthlyDetailScreen> {
  bool showBarChart = true;
  late List<Map<String, dynamic>> monthlyTransactions;      // only expenses
  late List<Map<String, dynamic>> monthlyAllTransactions;   // all sent/received
  late String _currentUserId;

  static const List<String> _paymentTypes = [
    'Food',
    'Travel',
    'Entertainment',
    'Education',
    'Miscellaneous',
  ];

  @override
  void initState() {
    super.initState();
    _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _filterMonthlyTransactions();
  }

  int _getMonthNumber(String monthName) {
    const monthNames = {
      'January': 1, 'February': 2, 'March': 3, 'April': 4, 'May': 5,
      'June': 6, 'July': 7, 'August': 8, 'September': 9, 'October': 10,
      'November': 11, 'December': 12, 'Jan': 1, 'Feb': 2, 'Mar': 3,
      'Apr': 4, 'Jun': 6, 'Jul': 7, 'Aug': 8, 'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12
    };
    return monthNames[monthName] ?? DateTime.now().month;
  }

  /// Filters for this month
  void _filterMonthlyTransactions() {
    final selectedMonth = _getMonthNumber(widget.monthName);
    final currentYear = DateTime.now().year;
    final currentUid = _currentUserId;

    // For chart/analytics: only money SENT by you
    monthlyTransactions = widget.transactions.where((tx) {
      final rawDate = tx['timestamp'] ?? tx['parsedDate'] ?? tx['date'];
      DateTime? date;
      if (rawDate is Timestamp) {
        date = rawDate.toDate();
      } else if (rawDate is DateTime) {
        date = rawDate;
      } else if (rawDate is String && rawDate.isNotEmpty) {
        try {
          date = DateTime.parse(rawDate);
        } catch (_) {
          date = null;
        }
      }
      return date != null &&
          date.month == selectedMonth &&
          date.year == currentYear &&
          tx['from'] == currentUid;
    }).toList();

    // For transaction history: ALL transactions you participated (sent or received) that month
    monthlyAllTransactions = widget.transactions.where((tx) {
      final rawDate = tx['timestamp'] ?? tx['parsedDate'] ?? tx['date'];
      DateTime? date;
      if (rawDate is Timestamp) {
        date = rawDate.toDate();
      } else if (rawDate is DateTime) {
        date = rawDate;
      } else if (rawDate is String && rawDate.isNotEmpty) {
        try {
          date = DateTime.parse(rawDate);
        } catch (_) {
          date = null;
        }
      }
      final participants = List<String>.from(tx['participants'] ?? []);
      return date != null &&
          date.month == selectedMonth &&
          date.year == currentYear &&
          participants.contains(currentUid);
    }).toList();
  }

  double _calculateTotalExpense() {
    // Only sum transactions you SENT
    return monthlyTransactions.fold(
      0.0,
      (sum, tx) => sum + (tx['amount'] ?? 0).toDouble(),
    );
  }

  Map<String, double> _computeCategoryData() {
    final Map<String, double> categorySums = {};
    for (final tx in monthlyTransactions) {
      final category = tx['category'] ?? 'Miscellaneous';
      final amount = (tx['amount'] ?? 0).toDouble();
      categorySums[category] = (categorySums[category] ?? 0.0) + amount;
    }
    for (final type in _paymentTypes) {
      categorySums[type] = categorySums[type] ?? 0.0;
    }
    return categorySums;
  }

  @override
  Widget build(BuildContext context) {
    final double totalExpense = _calculateTotalExpense();
    final Map<String, double> categoryData = _computeCategoryData();

    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context);
        return false;
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          title: Text('${widget.monthName} Details'),
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            setState(() => showBarChart = !showBarChart);
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AnimatedTotalCounter(
                  label: "This ${widget.monthName} Expense",
                  totalAmount: totalExpense,
                  textStyle: GoogleFonts.staatliches(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                  ),
                  labelStyle: GoogleFonts.staatliches(
                    textStyle: const TextStyle(
                      fontSize: 28,
                      color: Color.fromARGB(179, 64, 252, 139),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Category Breakdown',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 200,
                  child: showBarChart
                      ? CategoryBarChart(data: categoryData)
                      : CategoryPieChart(data: categoryData),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    showBarChart
                        ? 'Swipe to see Pie chart'
                        : 'Swipe to see Bar chart',
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Transaction History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: monthlyAllTransactions.isEmpty
                      ? const Center(
                          child: Text(
                            'No transactions this month',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ListView.builder(
                          itemCount: monthlyAllTransactions.length,
                          itemBuilder: (context, index) {
                            final tx = monthlyAllTransactions[index];
                            return TransactionTile(
                              data: tx,
                              userMap: widget.userMap,
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
