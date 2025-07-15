import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:orion/screens/user/dashboard/QR/qr_transaction1.dart';

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
  // Add controller as a class variable
  MobileScannerController? _scannerController;

  @override
  void initState() {
    super.initState();
    // Initialize the scanner controller
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
    );
  }

  @override
  void dispose() {
    // Dispose the scanner controller when widget is disposed
    _scannerController?.dispose();
    super.dispose();
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
            'Not a Valid QR',
            style: TextStyle(fontSize: 16, fontFamily: 'Poppins'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text(
                'OK',
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

  bool _isValidPhoneNumber(String? data) {
    if (data == null || data.isEmpty) return false;

    // Remove any non-digit characters
    String cleanData = data.replaceAll(RegExp(r'[^0-9]'), '');

    // Check if it's exactly 10 digits
    return cleanData.length == 10 && int.tryParse(cleanData) != null;
  }

  void _handleQrCode(String? scannedData) async {
    if (_isValidPhoneNumber(scannedData)) {
      // Stop the camera before navigating
      await _scannerController?.stop();

      // Extract only digits from the scanned data
      String cleanPhoneNumber = scannedData!.replaceAll(RegExp(r'[^0-9]'), '');

      setState(() {
        phoneNumber = cleanPhoneNumber;
      });

      // Navigate to transaction page with the phone number
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => VerifyPhoneDetailsQR(
            phoneNumber: phoneNumber!,
            phone: phoneNumber!,
          ),
        ),
      );
    } else {
      _showErrorDialog();
    }
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
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: const BorderRadius.only(
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
      body: Stack(
        children: [
          // Scanner container with black card design
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
                controller: _scannerController!, // Use the stored controller
                onDetect: (Capture) {
                  final List<Barcode> barcodes = Capture.barcodes;
                  for (final barcode in barcodes) {
                    print('Barcode Found! ${barcode.rawValue}');
                    _handleQrCode(barcode.rawValue);
                    break; // Process only the first barcode
                  }
                },
              ),
            ),
          ),
          // Scanning frame overlay
          Positioned.fill(
            child: Container(
              margin: const EdgeInsets.all(20),
              child: CustomPaint(painter: ScannerFramePainter()),
            ),
          ),
          // Instructions card at bottom
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
    );
  }
}

// Custom painter for scanning frame
class ScannerFramePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    const cornerLength = 40.0;
    const frameSize = 250.0;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final frameLeft = centerX - frameSize / 2;
    final frameTop = centerY - frameSize / 2;
    final frameRight = centerX + frameSize / 2;
    final frameBottom = centerY + frameSize / 2;

    // Draw corner lines
    // Top-left corner
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

    // Top-right corner
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

    // Bottom-left corner
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

    // Bottom-right corner
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
