import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:techcadd/employeeform.dart';
import 'dart:math';
// <-- apne file ka correct path use karo

class QRScan extends StatefulWidget {
  const QRScan({super.key});

  @override
  State<QRScan> createState() => _QRScanState();
}

class _QRScanState extends State<QRScan> {
  String? scannedCode;
  String? token;

  final MobileScannerController cameraController = MobileScannerController(
    torchEnabled: false,
  );

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final barcode = capture.barcodes.first;
    if (scannedCode != null) return; // prevent duplicate scans

    setState(() {
      scannedCode = barcode.rawValue;
    });

    if (barcode.rawValue == "register_here") {
      final random = Random();
      token =
          "T-${DateTime.now().millisecondsSinceEpoch}-${random.nextInt(9999)}";

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const EmployeeFormPage()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Scan Successful! TokenID: $token")),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Invalid QR Code")));
      // reset after delay so user can scan again
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() => scannedCode = null);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF282C5C),
      body: Stack(
        children: [
          Column(
            children: [
              // --- Scanner area ---
              Expanded(
                flex: 3,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: _onBarcodeDetected,
                    ),

                    // Scanner overlay
                    Center(
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        height: MediaQuery.of(context).size.width * 0.7,
                        child: CustomPaint(
                          painter: ScannerOverlayPainter(
                            boxColor: Colors.white,
                            borderRadius: 15.0,
                            cornerLength: 30.0,
                            cornerThickness: 4.0,
                          ),
                        ),
                      ),
                    ),

                    // Flashlight button
                    Positioned(
                      bottom: 20,
                      child: ValueListenableBuilder<MobileScannerState>(
                        valueListenable: cameraController,
                        builder: (context, state, child) {
                          final bool isOn = state.torchState == TorchState.on;
                          return FloatingActionButton(
                            heroTag: "flashButton",
                            backgroundColor: Colors.white,
                            onPressed: () async {
                              try {
                                await cameraController.toggleTorch();
                              } catch (e) {
                                debugPrint("Torch toggle error: $e");
                              }
                            },
                            child: Icon(
                              isOn ? Icons.flashlight_on : Icons.flashlight_off,
                              color: const Color(0xFF282C5C),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              // --- Info area ---
              Expanded(
                flex: 1,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child:
                        // scannedCode == null?
                        const Text(
                          "SCAN QR TO REGISTER",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                    // : Text(
                    //     "Your Token: $token",
                    //     style: const TextStyle(
                    //       fontSize: 18,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w600,
                    //     ),
                    //   ),
                  ),
                ),
              ),
            ],
          ),

          // --- Close button top right ---
          Positioned(
            top: 40,
            left: 20,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF1D1D1D),
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// CustomPainter to draw the four L-shaped corners for the scanner overlay
class ScannerOverlayPainter extends CustomPainter {
  final Color boxColor;
  final double cornerLength;
  final double cornerThickness;
  final double borderRadius;

  ScannerOverlayPainter({
    required this.boxColor,
    required this.cornerLength,
    required this.cornerThickness,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = boxColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = cornerThickness
      ..strokeCap = StrokeCap.round; // Use round cap for nice corner tips

    final double width = size.width;
    final double height = size.height;

    // --- Top Left Corner ---
    // Horizontal line segment (starting after the radius)
    canvas.drawLine(Offset(borderRadius, 0), Offset(cornerLength, 0), paint);
    // Vertical line segment (starting after the radius)
    canvas.drawLine(Offset(0, borderRadius), Offset(0, cornerLength), paint);
    // Arc for the round corner
    canvas.drawArc(
      Rect.fromLTWH(0, 0, borderRadius * 2, borderRadius * 2),
      pi, // Start angle (270 degrees in radians, pointing up)
      pi / 2, // Sweep angle (90 degrees)
      false,
      paint,
    );

    // --- Top Right Corner ---
    // Horizontal line segment
    canvas.drawLine(
      Offset(width - cornerLength, 0),
      Offset(width - borderRadius, 0),
      paint,
    );
    // Vertical line segment
    canvas.drawLine(
      Offset(width, borderRadius),
      Offset(width, cornerLength),
      paint,
    );
    // Arc for the round corner
    canvas.drawArc(
      Rect.fromLTWH(
        width - borderRadius * 2,
        0,
        borderRadius * 2,
        borderRadius * 2,
      ),
      -pi / 2, // Start angle (360 degrees, pointing right)
      pi / 2, // Sweep angle (90 degrees)
      false,
      paint,
    );

    // --- Bottom Left Corner ---
    // Horizontal line segment
    canvas.drawLine(
      Offset(borderRadius, height),
      Offset(cornerLength, height),
      paint,
    );
    // Vertical line segment
    canvas.drawLine(
      Offset(0, height - cornerLength),
      Offset(0, height - borderRadius),
      paint,
    );
    // Arc for the round corner
    canvas.drawArc(
      Rect.fromLTWH(
        0,
        height - borderRadius * 2,
        borderRadius * 2,
        borderRadius * 2,
      ),
      pi / 2, // Start angle (90 degrees, pointing down)
      pi / 2, // Sweep angle (90 degrees)
      false,
      paint,
    );

    // --- Bottom Right Corner ---
    // Horizontal line segment
    canvas.drawLine(
      Offset(width - cornerLength, height),
      Offset(width - borderRadius, height),
      paint,
    );
    // Vertical line segment
    canvas.drawLine(
      Offset(width, height - cornerLength),
      Offset(width, height - borderRadius),
      paint,
    );
    // Arc for the round corner
    canvas.drawArc(
      Rect.fromLTWH(
        width - borderRadius * 2,
        height - borderRadius * 2,
        borderRadius * 2,
        borderRadius * 2,
      ),
      0, // Start angle (0 degrees, pointing left)
      pi / 2, // Sweep angle (90 degrees)
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class QRScreen extends StatelessWidget {
  const QRScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const String qrContent = "register_here"; // fixed QR content

    return Scaffold(
      appBar: AppBar(title: const Text("Staff Screen - Registration QR")),
      body: Center(
        child: QrImageView(
          data: qrContent,
          version: QrVersions.auto,
          size: 250.0,
        ),
      ),
    );
  }
}
