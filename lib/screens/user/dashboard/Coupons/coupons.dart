import 'package:flutter/material.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/homescreen.dart';
import 'package:orion/screens/user/authentication/select_user.dart';
import 'package:orion/screens/user/dashboard/drawer/aboutus.dart';
import 'package:orion/screens/user/dashboard/drawer/profile.dart';
import 'package:orion/screens/user/dashboard/drawer/settings.dart';
// import 'package:coupon_uikit/coupon_uikit.dart';

class Coupon {
  final String imagePath;
  final int type; // 1: Cashback, 2: Card Theme, 3: Brand

  Coupon({required this.imagePath, required this.type});
}

class Coupons extends StatefulWidget {
  const Coupons({super.key});

  @override
  State<Coupons> createState() => _CouponsState();
}

class _CouponsState extends State<Coupons> {
  List<Coupon> coupons = [
    Coupon(imagePath: 'assets/coupon/brandcoupon/PVR.jpg', type: 3),
    Coupon(imagePath: 'assets/coupon/cardcoupon/lightc.jpg', type: 2),
  ];

  void _onClaim(Coupon coupon) {
    switch (coupon.type) {
      case 1:
        // Add money logic
        print("Cashback Claimed");
        break;
      case 2:
        // Unlock card logic
        print("Card Theme Unlocked");
        break;
      case 3:
        // Generate random code logic
        print("Brand Coupon Code: ${_generateCouponCode()}");
        break;
    }
  }

  String _generateCouponCode() {
    return DateTime.now().millisecondsSinceEpoch.toString().substring(6, 12);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
      ),
      drawer: _buildDrawer(context),
      body: Padding(
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
                    Image.asset(coupon.imagePath, height: 150),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => _onClaim(coupon),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text(
                        "Claim",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
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
            MaterialPageRoute(builder: (_) => HomeScreen()),
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
