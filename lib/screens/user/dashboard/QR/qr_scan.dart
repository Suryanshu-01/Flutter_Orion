import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:orion/screens/user/ExpenseTracker/widgets/nav/homescreen.dart';
import 'package:orion/screens/user/transaction/varify_phone_details2.dart';
import '../../authentication/select_user.dart' show SelectUser;
import '../drawer/aboutus.dart';
import '../drawer/profile.dart';
import '../drawer/settings.dart';

class QrScan extends StatefulWidget {
  const QrScan({super.key});

  @override
  State<QrScan> createState() => _QrScanState();
}

class _QrScanState extends State<QrScan> {
  String? phoneNumber;
  late final MobileScannerController _scannerController;
  bool _hasScanned = false;

  @override
  void initState() {
    super.initState();
    _scannerController = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  bool _isValidPhoneNumber(String? data) {
    if (data == null || data.isEmpty) return false;
    final cleaned = data.replaceAll(RegExp(r'\D'), '');
    return cleaned.length == 10 && int.tryParse(cleaned) != null;
  }

  void _handleQrCode(String? scannedData) async {
    if (_hasScanned) return;

    if (_isValidPhoneNumber(scannedData)) {
      _hasScanned = true;
      await _scannerController.stop();
      final cleanPhone = scannedData!.replaceAll(RegExp(r'\D'), '');

      if (!mounted) return;

      // Pop current QRScan screen first, then push the details screen
      Navigator.pop(context);
      // Optionally, you can add a slight delay to allow pop animation to finish
      Future.delayed(const Duration(milliseconds: 300), () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                VerifyPhoneDetails(phoneNumber: cleanPhone, phone: cleanPhone),
          ),
        );
      });
    } else {
      _showErrorDialog();
      _hasScanned = false; // Allow retry on error
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Invalid QR Code',
            style: TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
          content: const Text(
            'Not a valid 10-digit phone number.',
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _scannerController.start();
              },
              child: const Text(
                'Try Again',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ],
        );
      },
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
          "QR Scanner",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontFamily: 'Poppins',
          ),
        ),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Drawer(
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
            _drawerItem(Icons.person, 'Profile Manager', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ProfileManager()),
              );
            }),
            _drawerItem(Icons.admin_panel_settings, 'Admin/User', () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => SelectUser()),
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
            colors: [Color(0xFF232526), Color(0xFF0f2027), Color(0xFF000000)],
          ),
        ),
        child: Stack(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final barcodes = capture.barcodes;
                    if (barcodes.isNotEmpty) {
                      _handleQrCode(barcodes.first.rawValue);
                    }
                  },
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(20),
                child: CustomPaint(painter: ScannerFramePainter()),
              ),
            ),
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.qr_code_scanner,
                      color: Colors.white,
                      size: 30,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Point camera at QR code to scan',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      'Make sure the QR code is within the frame',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 12,
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 40.0;
    const frameSize = 250.0;
    final center = Offset(size.width / 2, size.height / 2);
    final frameLeft = center.dx - frameSize / 2;
    final frameTop = center.dy - frameSize / 2;
    final frameRight = center.dx + frameSize / 2;
    final frameBottom = center.dy + frameSize / 2;

    // Top-left
    canvas.drawLine(
      Offset(frameLeft, frameTop + cornerLength),
      Offset(frameLeft, frameTop),
      paint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameTop),
      Offset(frameLeft + cornerLength, frameTop),
      paint,
    );

    // Top-right
    canvas.drawLine(
      Offset(frameRight - cornerLength, frameTop),
      Offset(frameRight, frameTop),
      paint,
    );
    canvas.drawLine(
      Offset(frameRight, frameTop),
      Offset(frameRight, frameTop + cornerLength),
      paint,
    );

    // Bottom-left
    canvas.drawLine(
      Offset(frameLeft, frameBottom - cornerLength),
      Offset(frameLeft, frameBottom),
      paint,
    );
    canvas.drawLine(
      Offset(frameLeft, frameBottom),
      Offset(frameLeft + cornerLength, frameBottom),
      paint,
    );

    // Bottom-right
    canvas.drawLine(
      Offset(frameRight - cornerLength, frameBottom),
      Offset(frameRight, frameBottom),
      paint,
    );
    canvas.drawLine(
      Offset(frameRight, frameBottom),
      Offset(frameRight, frameBottom - cornerLength),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Drawer item widget helper
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
