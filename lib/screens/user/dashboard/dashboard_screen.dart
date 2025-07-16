import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../dashboard/drawer/profile.dart';
import 'package:orion/screens/user/dashboard/drawer/aboutus.dart';
import '../authentication/select_user.dart';
import '../transaction/get_phonenumber1.dart';
import 'package:orion/screens/user/dashboard/drawer/settings.dart';
import 'OrionCard/orionpage.dart';
import 'QR/qr_scan.dart';
import 'Coupons/coupons.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String selectedImage = 'assets/images/purple_gradient.png';

  @override
  void initState() {
    super.initState();
    _fetchSelectedCard();
  }

  Future<void> _fetchSelectedCard() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      final savedImage = doc.data()?['selectedCard'];
      if (savedImage != null && savedImage is String) {
        setState(() {
          selectedImage = savedImage;
        });
      }
    }
  }

  Future<void> _saveSelectedCard(String imagePath) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'selectedCard': imagePath,
      }, SetOptions(merge: true));
    }
  }

  void _handleClick(String label) {
    debugPrint('Clicked on $label!');
  }

  void _openCardSelector() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const Orionpage()),
    );

    if (result != null && result is String) {
      setState(() {
        selectedImage = result;
      });
      await _saveSelectedCard(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.cyan.shade700,
        elevation: 0,
        title: const Text(
          "OrionPay",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.white),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.cyan.shade700),
              child: const Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            _drawerItem(Icons.home, 'Home', () => Navigator.pop(context)),
            _drawerItem(Icons.person, 'Profile Manager', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProfileManager()),
              );
            }),
            _drawerItem(Icons.admin_panel_settings, 'Admin/User', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SelectUser()),
              );
            }),
            _drawerItem(Icons.settings, 'Settings', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SettingsUser()),
              );
            }),
            _drawerItem(Icons.info_outline, 'About Us', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => AboutUs()),
              );
            }),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF232526), // dark gray
              Color(0xFF0f2027), // almost black
              Color(0xFF000000), // black
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildCard(),
            const SizedBox(height: 20),
            _buildGrid(context, [
              _buildFeature(context, Icons.qr_code_2, "QR Code", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => QrScan()),
                );
              }),
              _buildFeature(context, Icons.send_to_mobile, "Transfer", () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const GetPhoneNumber()),
                );
              }),
              _buildFeature(
                context,
                Icons.account_balance_wallet,
                "Balance",
                () => _handleClick("Balance"),
              ),
            ]),
            const SizedBox(height: 20),
            _buildGrid(context, [
              _buildFeature(
                context,
                Icons.card_giftcard,
                "Coupons",
                () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => Coupons()),
                ),
              ),
              _buildFeature(
                context,
                Icons.request_page,
                "Request",
                () => _handleClick("Request"),
              ),
              _buildFeature(
                context,
                Icons.settings,
                "Theme",
                () => _handleClick("Theme"),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCard() {
    return InkWell(
      onTap: _openCardSelector,
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10), // subtle shadow
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
          image: DecorationImage(
            image: AssetImage(selectedImage),
            fit: BoxFit.cover,
          ),
        ),
        alignment: Alignment.bottomLeft,
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            const SizedBox(width: 5),
            FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(FirebaseAuth.instance.currentUser!.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Text(
                    "     Loading...",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }
                if (snapshot.hasError ||
                    !snapshot.hasData ||
                    !snapshot.data!.exists) {
                  return const Text(
                    "     OrionPay Card",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }

                final name = snapshot.data!.get('name') ?? 'User';
                return Text(
                  " $name",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 19, 1, 86),
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(text), onTap: onTap);
  }

  Widget _buildGrid(BuildContext context, List<Widget> children) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: children,
      ),
    );
  }

  Widget _buildFeature(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        Material(
          color: Colors.white,
          borderRadius: BorderRadius.circular(50),
          elevation: 6,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(50),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Icon(icon, size: 40, color: Colors.cyan.shade700),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
