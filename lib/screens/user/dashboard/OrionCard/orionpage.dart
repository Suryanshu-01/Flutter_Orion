import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../authentication/select_user.dart';
import '../dashboard_screen.dart';
import '../drawer/aboutus.dart';
import '../drawer/settings.dart';

class Orionpage extends StatefulWidget {
  const Orionpage({super.key});

  @override
  State<Orionpage> createState() => _OrionpageState();
}

class _OrionpageState extends State<Orionpage> {
  String? userName = '';
  double? balance = 0.0;

  final List<String> cardImages = [
    'assets/images/Grain_Cyan.png',
    'assets/images/purple_gradient.png',
    'assets/images/star_card.png',
    'assets/images/toji_fushigiro.png',
    'assets/images/gojo_card.png',
    'assets/images/guts_card.png',
    'assets/images/power_card.png',
    'assets/images/wall_titan.png',
  ];

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      setState(() {
        userName = doc['name'] ?? 'User';
        balance = doc['walletBalance'] ?? 0.0;
      });
    }
  }

  Future<void> _selectCard(String imagePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Save selected card in Firestore immediately
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'selectedCard': imagePath,
      }, SetOptions(merge: true));
    }
    Navigator.pop(context, imagePath);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan[800],
        elevation: 0,
        title: const Text(
          "Choose Your Orion Card",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
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
              child: const Text(
                "Profile",
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text("Home"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const DashboardScreen()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Profile Manager"),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.admin_panel_settings),
              title: const Text("Admin/User"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SelectUser()),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text("Settings"),
              onTap: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => SettingsUser()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text("About Us"),
              onTap: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const AboutUs()),
              ),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color.fromARGB(255, 1, 182, 185),
              Colors.cyan.shade100,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Name & balance wrapped nicely
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  189,
                  223,
                  239,
                ).withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Hi, $userName",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 1, 64, 113),
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    "Balance: ₹${balance?.toStringAsFixed(2) ?? '0.00'}",
                    style: const TextStyle(
                      color: Color.fromARGB(255, 1, 64, 113),
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const Text(
              "Select a card to use",
              style: TextStyle(
                color: Color.fromARGB(255, 0, 37, 85),
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            // ✅ Cards in vertical scroll with slight shadow container
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    245,
                    244,
                    244,
                  ).withOpacity(0.05),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  itemCount: cardImages.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _selectCard(cardImages[index]),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          cardImages[index],
                          height: 180, // smaller height for column
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            const Text(
              "Tap a card to set it as your active OrionPay card.",
              style: TextStyle(
                color: Color.fromARGB(179, 47, 4, 203),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
