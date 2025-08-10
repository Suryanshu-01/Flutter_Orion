import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/homescreen.dart';
import 'package:orion/screens/user/authentication/select_user.dart';
import 'package:orion/screens/user/dashboard/drawer/aboutus.dart';
import 'package:orion/screens/user/dashboard/drawer/profile.dart';

class ParentRequest extends StatefulWidget {
  const ParentRequest({super.key});

  @override
  State<ParentRequest> createState() => _ParentRequestState();
}

class _ParentRequestState extends State<ParentRequest> {
  final TextEditingController _amountController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  double requestedMoney = 0;

  @override
  void initState() {
    super.initState();
    fetchRequestedMoney();
  }

  Future<void> fetchRequestedMoney() async {
    String uid = _auth.currentUser!.uid;
    DocumentSnapshot userDoc = await _firestore.collection('users').doc(uid).get();

    setState(() {
      requestedMoney = (userDoc.data() as Map<String, dynamic>)['RequestedMoney']?.toDouble() ?? 0.0;
    });
  }

  Future<void> sendRequest(double amount) async {
    if (requestedMoney != 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "Can't request more money. Please cancel the existing request.",
          ),
        ),
      );
      return;
    }

    String uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'RequestedMoney': amount,
    });

    setState(() {
      requestedMoney = amount;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Request of ₹${amount.toStringAsFixed(2)} sent.")),
    );
  }

  Future<void> cancelRequest() async {
    String uid = _auth.currentUser!.uid;
    await _firestore.collection('users').doc(uid).update({
      'RequestedMoney': 0.0,
    });

    setState(() {
      requestedMoney = 0;
      _amountController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Request cancelled.")));
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
    return false; // Prevent default back navigation
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop, // Override system back button
      child: Scaffold(
        backgroundColor: Colors.black, // Black background
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          title: const Text(
            "Request",
            style: TextStyle(
              color: Colors.white, // White text
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ),
        drawer: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            children: [
              const DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, size: 40, color: Colors.black),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
              _drawerItem(Icons.home, 'Home', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }),
              _drawerItem(Icons.person, 'Profile Manager', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileManager()),
                );
              }),
              _drawerItem(Icons.admin_panel_settings, 'Admin/User', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SelectUser()),
                );
              }),
              _drawerItem(Icons.info_outline, 'About Us', () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const AboutUs()),
                );
              }),
            ],
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              TextField(
                style: const TextStyle(color: Colors.white), // White text
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(
                  labelText: "Enter amount to request",
                  labelStyle: const TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white54),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Colors.white),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white, // White button
                  foregroundColor: Colors.black, // Black text
                ),
                onPressed: () {
                  if (_amountController.text.trim().isEmpty) return;

                  double amount = double.tryParse(_amountController.text.trim()) ?? 0;
                  if (amount <= 0) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please enter a valid amount."),
                      ),
                    );
                    return;
                  }
                  sendRequest(amount);
                },
                child: const Text(
                  "Request Money",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              if (requestedMoney != 0)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 75, 74, 74),
                    foregroundColor: Colors.white,
                  ),
                  onPressed: cancelRequest,
                  child: const Text(
                    "Cancel Request",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                "Current Requested Amount: ₹${requestedMoney.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String text, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.white),
        title: Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontFamily: 'Poppins',
          ),
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
