// lib/screens/scanner_screen.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_scan/screens/result_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

// --- NEW: Data model for a single twinkling particle ---
class Particle {
  late Offset position;
  late Color color;
  late double speed;
  late double radius;
  late double alpha;

  Particle(Size bounds) {
    position = Offset(
      Random().nextDouble() * bounds.width,
      Random().nextDouble() * bounds.height,
    );
    color = const Color.fromARGB(255, 255, 255, 255);
    speed = Random().nextDouble() * 0.5 + 0.2;
    radius = Random().nextDouble() * 2.0 + 1.0;
    alpha = Random().nextDouble() * 0.8 + 0.1;
  }

  void update() {
    alpha -= 0.01; // Fade out
  }
}

// --- NEW: Custom painter for the twinkling dots animation ---
class _ScannerOverlay extends CustomPainter {
  const _ScannerOverlay(this.animation, this.particles)
    : super(repaint: animation);

  final Animation<double> animation;
  final List<Particle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (final particle in particles) {
      if (particle.alpha > 0) {
        paint.color = particle.color;
        canvas.drawCircle(particle.position, particle.radius, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _ScannerScreenState extends State<ScannerScreen>
    with SingleTickerProviderStateMixin {
  bool _isScanCompleted = false;
  bool _isPermissionGranted = false;
  bool _isTorchOn = false;
  double _zoomScale = 0.5;
  double _zoomSensitivity = 0.5;

  late final AnimationController _animationController;
  // --- NEW: List to hold the particles for animation ---
  final List<Particle> _particles = [];
  final Random _random = Random();

  final MobileScannerController _scannerController = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
  );

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
    _loadSensitivity();

    _animationController =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 100),
        )..addListener(() {
          _updateParticles();
        });

    _animationController.repeat();
  }

  // --- NEW: Logic to manage the particle animation ---
  void _updateParticles() {
    if (!mounted) return;
    // Add a new particle on some frames
    if (_random.nextInt(5) == 0) {
      _particles.add(Particle(const Size(250, 250))); // Scan window size
    }

    // Update and remove faded-out particles
    _particles.removeWhere((p) {
      p.update();
      return p.alpha <= 0;
    });
  }

  Future<void> _loadSensitivity() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _zoomSensitivity = prefs.getDouble('zoom_sensitivity') ?? 0.5;
      });
    }
  }

  Future<void> _requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (status.isDenied) {
      status = await Permission.camera.request();
    }
    if (mounted) {
      setState(() {
        _isPermissionGranted = status.isGranted;
      });
    }
  }

  void _resetScanState() {
    if (mounted) {
      setState(() {
        _isScanCompleted = false;
      });
    }
  }

  Future<void> _saveScanToHistory(String code) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> history = prefs.getStringList('scan_history') ?? [];
    history.insert(0, code);
    await prefs.setStringList('scan_history', history);
  }

  Future<void> _scanFromGallery() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      final BarcodeCapture? capture = await _scannerController.analyzeImage(
        image.path,
      );

      if (capture != null && capture.barcodes.isNotEmpty && mounted) {
        final String? code = capture.barcodes.first.rawValue;
        if (code != null) {
          _handleDetection(code);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No QR code found in the image.')),
        );
      }
    }
  }

  void _handleDetection(String code) {
    if (!_isScanCompleted) {
      setState(() {
        _isScanCompleted = true;
      });
      HapticFeedback.heavyImpact();
      _saveScanToHistory(code);

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ResultScreen(scannedCode: code, onClose: _resetScanState),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isPermissionGranted) {
      return Scaffold(
        appBar: AppBar(title: const Text("QR Scan")),
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

    final scanWindow = Rect.fromCenter(
      center: MediaQuery.of(context).size.center(Offset.zero),
      width: 250,
      height: 250,
    );

    double startZoom = _zoomScale;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: GestureDetector(
          onScaleStart: (details) {
            startZoom = _zoomScale;
          },
          onScaleUpdate: (details) {
            final newZoom =
                (startZoom + (details.scale - 1.0) * _zoomSensitivity).clamp(
                  0.0,
                  1.0,
                );
            _scannerController.setZoomScale(newZoom);
            setState(() {
              _zoomScale = newZoom;
            });
          },
          child: Stack(
            children: [
              MobileScanner(
                controller: _scannerController,
                scanWindow: scanWindow,
                onDetect: (capture) {
                  final String? code = capture.barcodes.first.rawValue;
                  if (code != null) {
                    _handleDetection(code);
                  }
                },
              ),
              ColorFiltered(
                colorFilter: ColorFilter.mode(
                  Colors.black.withOpacity(0.5),
                  BlendMode.srcOut,
                ),
                child: Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: scanWindow.width,
                        height: scanWindow.height,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // --- Render the twinkling dots animation ---
              Align(
                alignment: Alignment.center,
                child: SizedBox(
                  width: scanWindow.width,
                  height: scanWindow.height,
                  child: CustomPaint(
                    painter: _ScannerOverlay(_animationController, _particles),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 60.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "QR Scan",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        "Place the QR code in the area",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          shadows: [
                            Shadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 80),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextButton.icon(
                        onPressed: () {
                          _scannerController.toggleTorch();
                          setState(() {
                            _isTorchOn = !_isTorchOn;
                          });
                        },
                        icon: Icon(
                          _isTorchOn ? Icons.flash_on : Icons.flash_off,
                        ),
                        label: Text(_isTorchOn ? 'Flash On' : 'Flash Off'),
                        style: TextButton.styleFrom(
                          foregroundColor: _isTorchOn
                              ? Colors.yellow.shade700
                              : Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const SizedBox(
                        height: 24,
                        child: VerticalDivider(color: Colors.white30),
                      ),
                      const SizedBox(width: 8),
                      TextButton.icon(
                        onPressed: _scanFromGallery,
                        icon: const Icon(Icons.image),
                        label: const Text('Gallery'),
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scannerController.dispose();
    super.dispose();
  }
}
