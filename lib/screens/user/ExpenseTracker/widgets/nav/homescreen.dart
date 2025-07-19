import 'package:flutter/material.dart';
import 'package:orion/screens/user/dashboard/dashboard_screen.dart';
import 'package:orion/screens/user/ExpenseTracker/expense_tracker_screen.dart';
import 'package:orion/screens/user/ExpenseTracker/set_target_screen.dart';
import 'package:orion/screens/user/dashboard/QR/qr_scan.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/animated_bottom_navbar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),      // index 0
    ExpenseTrackerScreen(), // index 1
  ];

  void _onItemTapped(int idx) {
    setState(() => _selectedIndex = idx);
  }

  void _onFabPressed() {
    if (_selectedIndex == 0) {
      // Dashboard FAB: QR scan
      Navigator.push(context, MaterialPageRoute(builder: (_) => const QrScan()));
    } else if (_selectedIndex == 1) {
      // ExpenseTracker FAB: Set target
      Navigator.push(context, MaterialPageRoute(builder: (_) => const SetTargetScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _onFabPressed,
        child: Icon(
          _selectedIndex == 0 ? Icons.qr_code_scanner : Icons.track_changes,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: AnimatedBottomNavBar(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
