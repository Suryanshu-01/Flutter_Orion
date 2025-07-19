import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/homescreen.dart';
import '../../authentication/select_user.dart';
import 'aboutus.dart';

class Changelogin extends StatefulWidget {
  const Changelogin({super.key});

  @override
  State<Changelogin> createState() => _ChangeloginState();
}

class _ChangeloginState extends State<Changelogin> {
  final _currentPinController = TextEditingController();
  final _newPinController = TextEditingController();
  final _confirmPinController = TextEditingController();

  bool _showNewPinFields = false;
  bool _isLoading = false;

  final user = FirebaseAuth.instance.currentUser;

  void _checkCurrentPin() async {
    final enteredPin = _currentPinController.text.trim();
    if (enteredPin.length != 4) {
      _showMessage("PIN must be 4 digits");
      return;
    }

    if (user == null) {
      _showMessage("User not logged in");
      return;
    }

    setState(() => _isLoading = true);

    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(user!.uid)
        .get();
    final data = doc.data();
    final storedPin = data?['loginPin'];

    if (enteredPin == storedPin) {
      setState(() {
        _showNewPinFields = true;
      });
    } else {
      _showMessage("Current Login PIN is incorrect");
    }

    setState(() => _isLoading = false);
  }

  void _updatePin() async {
    final newPin = _newPinController.text.trim();
    final confirmPin = _confirmPinController.text.trim();

    if (newPin.length != 4) {
      _showMessage("New PIN must be 4 digits");
      return;
    }

    if (newPin != confirmPin) {
      _showMessage("PINs do not match");
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).update({
      'loginPin': newPin,
    });

    setState(() => _isLoading = false);

    _showMessage("Login PIN updated successfully");
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Change Login PIN",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.cyan[800]!, Colors.cyan[400]!],
                ),
              ),
              child: Text(
                "Profile",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text("Home"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => HomeScreen()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text("Profile Manager"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: Text("Admin/User"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SelectUser()),
              ),
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text("Settings"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.info_outline),
              title: Text("About Us"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AboutUs()),
              ),
            ),
          ],
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              width: 400,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextField(
                    controller: _currentPinController,
                    obscureText: true,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      labelText: "Enter Current Login PIN",
                      labelStyle: const TextStyle(color: Colors.white70),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white24),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      counterStyle: const TextStyle(color: Colors.white54),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _checkCurrentPin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        elevation: 2,
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.black)
                          : const Text(
                              "Verify Current PIN",
                              style: TextStyle(color: Colors.black),
                            ),
                    ),
                  ),
                  if (_showNewPinFields) ...[
                    const SizedBox(height: 30),
                    TextField(
                      controller: _newPinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: "Enter New PIN",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        counterStyle: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: _confirmPinController,
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      maxLength: 4,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                      decoration: InputDecoration(
                        labelText: "Confirm New PIN",
                        labelStyle: const TextStyle(color: Colors.white70),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Colors.white24),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
                        ),
                        counterStyle: const TextStyle(color: Colors.white54),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updatePin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.black,
                              )
                            : const Text(
                                "Update PIN",
                                style: TextStyle(color: Colors.black),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      child: const Text(
                        "Back to Settings",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
