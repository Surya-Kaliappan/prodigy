import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scan/screens/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  bool _isScanCompleted = false;
  bool _isPermissionGranted = false;

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }

    if (status.isGranted) {
      setState(() {
        _isPermissionGranted = true;
      });
    }
  }

  void _resetScanState() {
    setState(() {
      _isScanCompleted = false;
    });
  }

  Future<void> _saveScanToHistory(String code) async {
    final prefs = await SharedPreferences.getInstance();
    // Get existing history, or create a new list if it doesn't exist
    final List<String> history = prefs.getStringList('scan_history') ?? [];
    // Add the new scan to the top of the list
    history.insert(0, code);
    // Save the updated list back to shared_preferences
    await prefs.setStringList('scan_history', history);
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text("Quantum Scan")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Camera permission is required to scan QR codes."),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _requestCameraPermission,
                child: const Text("Grant Permission"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Quantum Scan",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              "Place the QR code in the area",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: MobileScanner(
                  controller: MobileScannerController(
                    detectionSpeed: DetectionSpeed.normal,
                  ),
                  onDetect: (capture) {
                    if (!_isScanCompleted) {
                      setState(() {
                        _isScanCompleted = true;
                      });
                      final String code =
                          capture.barcodes.first.rawValue ?? "---";

                      HapticFeedback.heavyImpact();
                      _saveScanToHistory(code);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ResultScreen(
                            scannedCode: code,
                            onClose: _resetScanState,
                          ),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Scanning will start automatically",
              style: TextStyle(color: Colors.white54, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
