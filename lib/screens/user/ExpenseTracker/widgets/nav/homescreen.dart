import 'package:flutter/material.dart';
import 'package:orion/screens/user/dashboard/dashboard_screen.dart';
import 'package:orion/screens/user/ExpenseTracker/expense_tracker_screen.dart';
import 'package:orion/screens/user/ExpenseTracker/set_target_screen.dart';
import 'package:orion/screens/user/dashboard/QR/qr_scan.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/animated_bottom_navbar.dart';
import 'package:orion/widgets/notification_permission_dialog.dart';
import 'package:orion/services/notification_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  bool _hasShownNotificationDialog = false;

  final List<Widget> _screens = const [
    DashboardScreen(),      // index 0
    ExpenseTrackerScreen(), // index 1
  ];

  @override
  void initState() {
    super.initState();
    // Show notification permission dialog after a short delay
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndShowNotificationDialog();
    });
  }

  Future<void> _checkAndShowNotificationDialog() async {
    if (_hasShownNotificationDialog) return;

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // Check if user has already been asked about notifications
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      final userData = userDoc.data();
      final hasBeenAsked = userData?['notificationPermissionAsked'] ?? false;

      if (!hasBeenAsked) {
        // Show the dialog
        _hasShownNotificationDialog = true;
        
        // Mark as asked
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({
          'notificationPermissionAsked': true,
        });

        // Show dialog after a short delay to let the screen load
        await Future.delayed(const Duration(milliseconds: 500));
        
        if (mounted) {
          await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (context) => const NotificationPermissionDialog(),
          );
        }
      }
    } catch (e) {
      print('Error checking notification permission: $e');
    }
  }

  void _onItemTapped(int idx) {
    setState(() => _selectedIndex = idx);
  }

  void _onFabPressed() {
    if (_selectedIndex == 0) {
      // Dashboard FAB: QR scan
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const QrScan()),
      );
    } else if (_selectedIndex == 1) {
      // ExpenseTracker FAB: Set target
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const SetTargetScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack( // <-- this keeps screen state persistent
        index: _selectedIndex,
        children: _screens,
      ),
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
