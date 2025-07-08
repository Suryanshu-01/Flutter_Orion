import 'package:flutter/material.dart';
import '../authentication/select_user.dart';
import 'qr_scanner.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  void _handleClick(String label) {
    print('Clicked on $label!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: const Color.fromARGB(255, 4, 129, 201),
      appBar: AppBar(
        title: Text(
          "OrionPay",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 3, 63, 116),
        elevation: 5,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(
                Icons.notification_add,
                color: Colors.white,
                size: 25,
              ),
            ),
          ),
          Builder(
            builder: (context) => IconButton(
              onPressed: () {
                Scaffold.of(context).openDrawer();
              },
              icon: const Icon(Icons.search, color: Colors.white, size: 25),
            ),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 1, 47, 85),
              ),
              child: const Text(
                'Profile',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                Navigator.of(context).pop();
                // You can navigate here
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: const Text("Profile Manager"),
              onTap: () {
                print('Tapped Profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.admin_panel_settings),
              title: const Text("Admin/User"),
              onTap: () {
                print('Tapped Admin');
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SelectUser()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                print('Tapped Settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.handshake),
              title: const Text("About Us"),
              onTap: () {
                print('Tapped About Us');
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 4, 129, 201), // cyan
              Colors.white, // white
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.2, 1.0],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: 600,
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(
                      (0.2 * 255).toInt(),
                    ), // shadow color
                    spreadRadius: 2, // how wide the shadow spreads
                    blurRadius: 8, // how blurry the shadow is
                    offset: const Offset(0, 4), // x,y offset
                  ),
                ],
              ),
              padding: EdgeInsets.all(25),
              margin: EdgeInsets.all(20),
              child: Column(
                children: [
                  Image.network(
                    'https://cdn-icons-png.flaticon.com/512/1087/1087117.png',
                    width: 60,
                    alignment: Alignment.center,
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    "OrionPay Card",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color.fromARGB(255, 2, 1, 85),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: 600,
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(
                      (0.2 * 255).toInt(),
                    ), // shadow color
                    spreadRadius: 2, // how wide the shadow spreads
                    blurRadius: 8, // how blurry the shadow is
                    offset: const Offset(0, 4), // x,y offset
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //QR Code
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior:
                            Clip.antiAlias, // clips ripple to rounded shape
                        child: InkWell(
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QrScanner(),
                            ),
                          ),
                          child: Icon(
                            Icons.qr_code_2,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                          // Image.network(
                          //   'https://static.vecteezy.com/system/resources/previews/047/759/339/non_2x/icon-qr-code-symbol-barcode-and-qr-code-elements-icons-in-glyph-style-good-for-prints-posters-logo-advertisement-infographics-etc-vector.jpg',
                          //   width: 80,
                          //   height: 80,
                          // ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "QR Code",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 2, 1, 85),
                        ),
                      ),
                    ],
                  ),
                  //Recharge
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior:
                            Clip.antiAlias, // clips ripple to rounded shape
                        child: InkWell(
                          onTap: () => _handleClick('Image 2'),
                          child: Icon(
                            Icons.phone_android,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                          // Image.network(
                          //   'https://i0.wp.com/www.justrechargenow.com/wp-content/uploads/2019/05/jrn-logo-box.jpg?ssl=1',
                          //   width: 80,
                          //   height: 80,
                          // ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Recharge",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 2, 1, 85),
                        ),
                      ),
                    ],
                  ),
                  //Balance and History
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior:
                            Clip.antiAlias, // clips ripple to rounded shape
                        child: InkWell(
                          onTap: () => _handleClick("Image 3"),
                          child: Icon(
                            Icons.balance,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                          // Image.network(
                          //   'https://png.pngtree.com/png-vector/20220810/ourmid/pngtree-banknote-icon-cash-balance-pay-vector-png-image_19467352.jpg',
                          //   width: 80,
                          //   height: 80,
                          // ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        "Balance",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 2, 1, 85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            Container(
              height: 200,
              width: 600,
              decoration: BoxDecoration(
                color: Colors.cyanAccent,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(
                      (0.2 * 255).toInt(),
                    ), // shadow color
                    spreadRadius: 2, // how wide the shadow spreads
                    blurRadius: 8, // how blurry the shadow is
                    offset: const Offset(0, 4), // x,y offset
                  ),
                ],
              ),
              padding: EdgeInsets.all(20),
              margin: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Coupons
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior:
                            Clip.antiAlias, // clips ripple to rounded shape
                        child: InkWell(
                          onTap: () => _handleClick('Image 4'),
                          child: Icon(
                            Icons.card_giftcard_outlined,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                          // Image.network(
                          //   'https://static.vecteezy.com/system/resources/thumbnails/010/577/363/small_2x/coupon-icon-logo-illustration-discount-coupon-symbol-template-for-graphic-and-web-design-collection-free-vector.jpg',
                          //   width: 80,
                          //   height: 80,
                          // ),
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        "Coupons",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 2, 1, 85),
                        ),
                      ),
                    ],
                  ),
                  //Recharge
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior:
                            Clip.antiAlias, // clips ripple to rounded shape
                        child: InkWell(
                          onTap: () => _handleClick('Image 5'),
                          child: Icon(
                            Icons.request_quote,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                          // Image.network(
                          //   'https://static.thenounproject.com/png/3883426-200.png',
                          //   width: 80,
                          //   height: 80,
                          // ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "Request",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 2, 1, 85),
                        ),
                      ),
                    ],
                  ),
                  //Balance and History
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        elevation: 6,
                        borderRadius: BorderRadius.circular(12),
                        clipBehavior:
                            Clip.antiAlias, // clips ripple to rounded shape
                        child: InkWell(
                          onTap: () => _handleClick("Image 6"),
                          child: Icon(
                            Icons.settings_applications,
                            size: 60,
                            color: Colors.blueAccent,
                          ),
                          // Image.network(
                          //   'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSFYtb7hHCOAeoAcOftVLvMDr2D9_cvGZrsvg&s',
                          // width: 80,
                          // height: 80,
                        ),
                      ),

                      const SizedBox(height: 8),
                      const Text(
                        "Theme",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.normal,
                          color: Color.fromARGB(255, 2, 1, 85),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// body
