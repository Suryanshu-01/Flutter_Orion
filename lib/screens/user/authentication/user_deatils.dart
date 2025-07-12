import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:orion/screens/user/authentication/pinScreen/pin_loginScreen.dart';

class UserDetailsScreen extends StatefulWidget {
  const UserDetailsScreen({super.key});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  DateTime? _dob;
  String? _gender;

  bool _isLoading = false;

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _dob) {
      setState(() {
        _dob = picked;
      });
    }
  }

  Future<bool> _saveDetails() async {
    if (!_formKey.currentState!.validate() || _dob == null || _gender == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fill all fields')));
      return false;
    }

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception("User not logged in");

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
        'dob': _dob!.toIso8601String(),
        'gender': _gender,
        'uid': user.uid,
        'loginPin': null,
        'walletBalance': 1000.0,
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: ${e.toString()}')));
      return false;
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan[50],
      appBar: AppBar(
        title: const Text('User Details'),
        backgroundColor: Colors.cyan[800],
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Name
                TextFormField(
                  controller: _nameController,
                  decoration: _inputDecoration("Name", Icons.person),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter name' : null,
                ),
                const SizedBox(height: 20),
                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _inputDecoration("Email", Icons.email_outlined),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter email' : null,
                ),
                const SizedBox(height: 20),
                // Phone
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: _inputDecoration("Phone", Icons.phone),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter phone' : null,
                ),
                const SizedBox(height: 20),
                // DOB Picker
                ListTile(
                  tileColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  title: Text(
                    _dob == null
                        ? 'Select Date of Birth'
                        : 'DOB: ${_dob!.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 16),
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () => _pickDate(context),
                ),
                const SizedBox(height: 20),
                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: _gender,
                  decoration: _inputDecoration("Gender", Icons.person_outline),
                  items: ['Male', 'Female', 'Other']
                      .map((g) => DropdownMenuItem(value: g, child: Text(g)))
                      .toList(),
                  onChanged: (val) => setState(() => _gender = val),
                  validator: (v) => v == null ? 'Select gender' : null,
                ),
                const SizedBox(height: 40),
                // Next Button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                          onPressed: () async {
                            final success = await _saveDetails();
                            if (success) {
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SetLoginPinScreen(),
                                ),
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyan[800],
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Next',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }
}
