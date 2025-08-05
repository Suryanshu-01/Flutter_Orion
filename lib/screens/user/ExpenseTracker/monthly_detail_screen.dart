import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/transaction_tile.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/charts/category_bar_chart.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/charts/category_pie_chart.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/animated_total_counter.dart';

class MonthlyDetailScreen extends StatefulWidget {
  final String monthName;
  final List<Map<String, dynamic>> transactions;
  final Map<String, String> userMap; // userId:name

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
  late List<Map<String, dynamic>> monthlyTransactions;

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
    _filterMonthlyTransactions();
  }

  void _filterMonthlyTransactions() {
    final selectedMonth = _getMonthNumber(widget.monthName);
    final currentYear = DateTime.now().year;

    monthlyTransactions = widget.transactions.where((tx) {
      final timestamp = tx['timestamp'] ?? tx['parsedDate'];
      DateTime? date;

      if (timestamp is DateTime) {
        date = timestamp;
      } else if (timestamp is Timestamp) {
        date = timestamp.toDate();
      } else if (timestamp is String) {
        try {
          date = DateTime.parse(timestamp);
        } catch (_) {
          return false;
        }
      }

      return date != null &&
          date.month == selectedMonth &&
          date.year == currentYear;
    }).toList();
  }

  int _getMonthNumber(String monthName) {
    const monthNames = {
      'January': 1,
      'February': 2,
      'March': 3,
      'April': 4,
      'May': 5,
      'June': 6,
      'July': 7,
      'August': 8,
      'September': 9,
      'October': 10,
      'November': 11,
      'December': 12,
      'Jan': 1,
      'Feb': 2,
      'Mar': 3,
      'Apr': 4,
      'Jun': 6,
      'Jul': 7,
      'Aug': 8,
      'Sep': 9,
      'Oct': 10,
      'Nov': 11,
      'Dec': 12,
    };
    return monthNames[monthName] ?? DateTime.now().month;
  }

  double _calculateTotalExpense() {
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

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          '${widget.monthName} Details',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity != null) {
            setState(() => showBarChart = !showBarChart);
          }
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
                    ? CategoryBarChart(
                        data: categoryData,
                      )
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
                child: monthlyTransactions.isEmpty
                    ? const Center(
                        child: Text(
                          'No transactions this month',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: monthlyTransactions.length,
                        itemBuilder: (context, index) {
                          final tx = monthlyTransactions[index];
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
    );
  }
}
