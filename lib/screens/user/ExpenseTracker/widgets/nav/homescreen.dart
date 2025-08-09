// home_screen.dart (or wherever your bottom nav + FAB is)

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/ExpenseTracker/monthly_detail_screen.dart';
import 'package:orion/screens/user/dashboard/QR/qr_scan.dart';
import 'package:orion/screens/user/ExpenseTracker/expense_tracker_screen.dart';
import 'package:orion/screens/user/dashboard/dashboard_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  final List<Widget> _screens = const [
    DashboardScreen(),
    ExpenseTrackerScreen(),
  ];

  Future<void> _navigateFromFab() async {
    if (_currentIndex == 0) {
      // Dashboard tab → QR Scanner
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QrScan()),
      );
    } else if (_currentIndex == 1) {
      // Expense Manager tab → Monthly Detail Screen
      try {
        final uid = _auth.currentUser?.uid;
        if (uid == null) return;

        // Get all users for userMap
        final usersSnap = await _firestore.collection('users').get();
        final Map<String, String> userMap = {
          for (var doc in usersSnap.docs)
            doc.id: (doc.data()['name'] ?? 'Unknown').toString()
        };

        // Get current month transactions
        final now = DateTime.now();
        final monthName = _monthName(now.month);

        final startOfMonth = DateTime(now.year, now.month, 1);
        final endOfMonth =
            DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));

        final txSnap = await _firestore
            .collection('transactions')
            .where('timestamp', isGreaterThanOrEqualTo: startOfMonth)
            .where('timestamp', isLessThanOrEqualTo: endOfMonth)
            .orderBy('timestamp', descending: true)
            .get();

        final transactions = txSnap.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MonthlyDetailScreen(
              monthName: monthName,
              transactions: transactions,
              userMap: userMap,
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error navigating to MonthlyDetailScreen: $e');
      }
    }
  }

  String _monthName(int month) {
    const months = [
      '',
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: Icon(
                Icons.dashboard,
                color: _currentIndex == 0 ? Colors.blue : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 0),
            ),
            const SizedBox(width: 40), // space for FAB
            IconButton(
              icon: Icon(
                Icons.bar_chart,
                color: _currentIndex == 1 ? Colors.blue : Colors.grey,
              ),
              onPressed: () => setState(() => _currentIndex = 1),
            ),
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateFromFab,
        backgroundColor: Colors.blue,
        child: Icon(_currentIndex == 0 ? Icons.qr_code : Icons.calendar_month),
      ),
    );
  }
}
