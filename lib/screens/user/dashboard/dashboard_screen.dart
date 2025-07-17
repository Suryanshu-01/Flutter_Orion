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
      backgroundColor: Colors.white, // gradient will be applied below
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "OrionPay",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(color: Colors.grey),
              child: const Text(
                'Profile',
                style: TextStyle(color: Colors.black, fontSize: 24),
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
        color: Colors.white,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _buildCard(),
            const SizedBox(height: 20),
            _buildFeatureGrid(),
            const SizedBox(height: 20),
            _buildTransactionHistory(),
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
              color: Colors.black.withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Card image
            selectedImage.isNotEmpty
                ? Image.asset(selectedImage, fit: BoxFit.cover)
                : Container(color: Colors.grey.shade200),
            // Card label and user name
            Container(
              alignment: Alignment.bottomLeft,
              padding: const EdgeInsets.all(16),
              child: FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance
                    .collection('users')
                    .doc(FirebaseAuth.instance.currentUser!.uid)
                    .get(),
                builder: (context, snapshot) {
                  String name = "OrionPay Card";
                  if (snapshot.hasData &&
                      snapshot.data != null &&
                      snapshot.data!.exists) {
                    name = snapshot.data!.get('name') ?? "OrionPay Card";
                  }
                  return Text(
                    name,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureGrid() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center( // <-- Center the row horizontally
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // <-- Center children in the row
          children: [
            _buildFeature(Icons.qr_code_2, "QR Code", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => QrScan()),
              );
            }),
            const SizedBox(width: 20),
            _buildFeature(Icons.send_to_mobile, "Transfer", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GetPhoneNumber()),
              );
            }),
            const SizedBox(width: 20),
            _buildFeature(
              Icons.card_giftcard,
              "Coupons",
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => Coupons()),
              ),
            ),
            const SizedBox(width: 20),
            _buildFeature(
              Icons.request_page,
              "Request",
              () => _handleClick("Request"),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionHistory() {
    final user = FirebaseAuth.instance.currentUser;

    Future<List<Map<String, dynamic>>> _fetchTransactions() async {
      if (user == null) return [];

      final uid = user.uid;

      final snapshot = await FirebaseFirestore.instance
          .collection('transactions')
          .where('participants', arrayContains: uid)
          .get();

      final transactions = snapshot.docs.map((doc) => doc.data()).toList();

      // Sort transactions by datetime
      transactions.sort((a, b) {
        final dateTimeA =
            DateTime.tryParse('${a['date']} ${a['time']}') ?? DateTime.now();
        final dateTimeB =
            DateTime.tryParse('${b['date']} ${b['time']}') ?? DateTime.now();
        return dateTimeB.compareTo(dateTimeA); // Newest first
      });

      return transactions;
    }

    Widget _buildTransactionTile(Map<String, dynamic> data, {bool isModal = false}) {
      final currentUserId = user?.uid;
      final isSender = data['from'] == currentUserId;
      final otherUserId = isSender ? data['to'] : data['from'];
      final amount = data['amount'] ?? 0.0;
      final date = data['date'] ?? '';
      final time = data['time'] ?? '';
      final category = data['category'] ?? 'Miscellaneous';

      return FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get(),
        builder: (context, snapshot) {
          String name = 'Unknown';
          if (snapshot.hasData && snapshot.data!.exists) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;
            name = userData['name'] ?? userData['phone'] ?? 'Unknown';
          }

          final textColor = isModal ? Colors.black : Colors.white;

          return ListTile(
            leading: Icon(
              isSender ? Icons.arrow_upward : Icons.arrow_downward,
              color: isSender ? Colors.red : Colors.green,
            ),
            title: Text(
              '${isSender ? 'Paid to' : 'Received from'} $name',
              style: TextStyle(color: textColor),
            ),
            subtitle: Text(
              '$category • $date • $time',
              style: TextStyle(color: textColor.withOpacity(0.7)),
            ),
            trailing: Text(
              '₹${amount.toString()}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSender ? Colors.red : Colors.green,
                fontSize: 15,
              ),
            ),
          );
        },
      );
    }

    // --- Modal for full-screen transaction history with animation ---
    void _showTransactionHistoryModal() {
      showGeneralDialog(
        context: context,
        barrierDismissible: true,
        barrierLabel: "Transaction History",
        transitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (context, anim1, anim2) {
          return Align(
            alignment: Alignment.center,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                height: MediaQuery.of(context).size.height * 0.7,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Text(
                              "Transaction History",
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: FutureBuilder<List<Map<String, dynamic>>>(
                        future: _fetchTransactions(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          if (snapshot.hasError || !snapshot.hasData) {
                            return const Center(
                              child: Text(
                                "Error fetching transactions",
                                style: TextStyle(color: Colors.black), // Modal is white, so black text
                              ),
                            );
                          }
                          final transactions = snapshot.data!;
                          if (transactions.isEmpty) {
                            return const Center(
                              child: Text(
                                "No transactions yet",
                                style: TextStyle(color: Colors.black), // Modal is white, so black text
                              ),
                            );
                          }
                          return ListView.builder(
                            itemCount: transactions.length,
                            itemBuilder: (context, index) =>
                                _buildTransactionTile(transactions[index], isModal: true),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
        transitionBuilder: (context, anim1, anim2, child) {
          return ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: child,
          );
        },
      );
    }

    // --- Main dashboard container, now tappable ---
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: _showTransactionHistoryModal,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Transaction History",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            SizedBox(
              height: 200,
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _fetchTransactions(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text(
                        "Error fetching transactions",
                        style: TextStyle(color: Colors.white), // <-- White text
                      ),
                    );
                  }
                  final transactions = snapshot.data!;
                  if (transactions.isEmpty) {
                    return const Center(
                      child: Text(
                        "No transactions yet",
                        style: TextStyle(color: Colors.white), // <-- White text
                      ),
                    );
                  }
                  return ListView.builder(
                    itemCount: transactions.length,
                    itemBuilder: (context, index) =>
                        _buildTransactionTile(transactions[index], isModal: false),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String text, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(text, style: const TextStyle(color: Colors.black)),
      onTap: onTap,
    );
  }

  Widget _buildFeature(IconData icon, String label, VoidCallback onTap) {
    return Column(
      children: [
        Material(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(40),
          elevation: 6,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(40),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(icon, size: 30, color: Colors.black),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
