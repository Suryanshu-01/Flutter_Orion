import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/homescreen.dart';
import 'package:orion/screens/user/authentication/select_user.dart';
import 'package:orion/screens/user/dashboard/drawer/aboutus.dart';
import 'package:orion/screens/user/dashboard/drawer/profile.dart';
import 'package:orion/screens/user/dashboard/drawer/settings.dart';

class Coupon {
  final String imagePath;
  final int type;

  Coupon({required this.imagePath, required this.type});
}

class Coupons extends StatefulWidget {
  const Coupons({super.key});

  @override
  State<Coupons> createState() => _CouponsState();
}

class _CouponsState extends State<Coupons> {
  List<Coupon> coupons = [];

  final Map<String, Coupon> couponMap = {
    'Boat.jpg': Coupon(
      imagePath: 'assets/coupon/brandcoupon/Boat.jpg',
      type: 1,
    ),
    'Nykaa.jpg': Coupon(
      imagePath: 'assets/coupon/brandcoupon/Nykaa.jpg',
      type: 1,
    ),
    'PVR.jpg': Coupon(imagePath: 'assets/coupon/brandcoupon/PVR.jpg', type: 1),
    'Swiggy.jpg': Coupon(
      imagePath: 'assets/coupon/brandcoupon/Swiggy.jpg',
      type: 1,
    ),
    'itachic.jpg': Coupon(
      imagePath: 'assets/coupon/cardcoupon/itachic.jpg',
      type: 2,
    ),
    'lightc.jpg': Coupon(
      imagePath: 'assets/coupon/cardcoupon/lightc.jpg',
      type: 2,
    ),
    'luffyc.jpg': Coupon(
      imagePath: 'assets/coupon/cardcoupon/luffyc.jpg',
      type: 2,
    ),
    'madarac.jpg': Coupon(
      imagePath: 'assets/coupon/cardcoupon/madarac.jpg',
      type: 2,
    ),
    'shanksc.jpg': Coupon(
      imagePath: 'assets/coupon/cardcoupon/shanksc.jpg',
      type: 2,
    ),
    'vegetac.jpg': Coupon(
      imagePath: 'assets/coupon/cardcoupon/vegetac.jpg',
      type: 2,
    ),
  };

  final Map<String, String> couponToThemeImage = {
    'itachic.jpg': 'assets/coupon/cardcoupon/itachi.png',
    'lightc.jpg': 'assets/coupon/cardcoupon/light.png',
    'luffyc.jpg': 'assets/coupon/cardcoupon/luffy.png',
    'madarac.jpg': 'assets/coupon/cardcoupon/madara.png',
    'shanksc.jpg': 'assets/coupon/cardcoupon/shanks.png',
    'vegetac.jpg': 'assets/coupon/cardcoupon/vegeta.png',
  };

  @override
  void initState() {
    super.initState();
    _loadUserCoupons();
  }

  Future<void> _loadUserCoupons() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get();

      final List<dynamic> userCouponStrings =
          snapshot.data()?['userCoupons'] ?? [];

      setState(() {
        coupons = userCouponStrings
            .map((name) => couponMap[name])
            .where((coupon) => coupon != null)
            .cast<Coupon>()
            .toList();
      });
    }
  }

  Future<void> _onClaim(Coupon coupon) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(userId);

    switch (coupon.type) {
      case 1:
        final code = _generateCouponCode();
        await Clipboard.setData(ClipboardData(text: code));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Coupon Code Copied to your Clipboard")),
        );
        await userDoc.update({
          'userCoupons': FieldValue.arrayRemove([
            coupon.imagePath.split('/').last,
          ]),
        });
        break;

      case 2:
        final couponKey = coupon.imagePath.split('/').last;
        final imageToAdd = couponToThemeImage[couponKey];
        if (imageToAdd != null) {
          await userDoc.update({
            'newThemeCards': FieldValue.arrayUnion([imageToAdd]),
            'userCoupons': FieldValue.arrayRemove([couponKey]),
          });
        }
        break;
    }

    _loadUserCoupons();
  }

  String _generateCouponCode() {
    final random = Random();
    return List.generate(10, (_) => random.nextInt(10).toString()).join();
  }

  void _showImagePopup(String imagePath) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Container(
          padding: const EdgeInsets.all(10),
          child: Image.asset(imagePath),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: const Text(
            "Coupons",
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            },
          ),
        ),
        drawer: _buildDrawer(context),
        body: coupons.isEmpty
            ? const Center(child: Text("No Coupons Available"))
            : Padding(
                padding: const EdgeInsets.all(12.0),
                child: ListView.builder(
                  itemCount: coupons.length,
                  itemBuilder: (context, index) {
                    final coupon = coupons[index];
                    return GestureDetector(
                      onTap: () => _showImagePopup(coupon.imagePath),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.shade200,
                              blurRadius: 5,
                              offset: const Offset(0, 4),
                            ),
                          ],
                          color: Colors.white,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Image.asset(
                              coupon.imagePath,
                              height: 200,
                              width: 200,
                              fit: BoxFit.cover,
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: () => _onClaim(coupon),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(180, 40),
                              ),
                              child: const Text(
                                "Claim",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
      ),
    );
  }
}

Widget _buildDrawer(BuildContext context) {
  return Drawer(
    backgroundColor: Colors.white,
    child: ListView(
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: const Column(
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
        _drawerItem(
          Icons.home,
          'Home',
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const HomeScreen()),
          ),
        ),
        _drawerItem(
          Icons.person,
          'Profile Manager',
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => ProfileManager()),
          ),
        ),
        _drawerItem(
          Icons.admin_panel_settings,
          'Admin/User',
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SelectUser()),
          ),
        ),
        _drawerItem(
          Icons.settings,
          'Settings',
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => SettingsUser()),
          ),
        ),
        _drawerItem(
          Icons.info_outline,
          'About Us',
          () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => AboutUs()),
          ),
        ),
      ],
    ),
  );
}

Widget _drawerItem(IconData icon, String text, VoidCallback onTap) {
  return Container(
    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
    child: ListTile(
      leading: Icon(icon, color: Colors.black),
      title: Text(
        text,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
