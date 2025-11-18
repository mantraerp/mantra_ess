import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'display_screen.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController cameraController = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
    formats: [BarcodeFormat.qrCode],
    returnImage: false,
  );

  bool isScanned = false;
  bool permissionGranted = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initScanner();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // try to stop before disposing
    try {
      cameraController.stop();
    } catch (_) {}
    cameraController.dispose();
    super.dispose();
  }

  // Restart camera when app resumes to ensure scanner is active
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      // small delay for system to settle
      Future.delayed(const Duration(milliseconds: 300), () async {
        if (permissionGranted && !isScanned) {
          try {
            await cameraController.start();
          } catch (_) {}
        }
      });
    } else if (state == AppLifecycleState.paused) {
      // stop camera to release resources
      try {
        cameraController.stop();
      } catch (_) {}
    }
  }

  Future<void> _initScanner() async {
    setState(() {
      isLoading = true;
    });

    final status = await Permission.camera.request();

    if (status.isGranted) {
      setState(() {
        permissionGranted = true;
        isLoading = false;
      });

      // small delay for MIUI / device quirks
      await Future.delayed(const Duration(milliseconds: 300));
      try {
        await cameraController.start();
      } catch (e) {
        // show helpful dialog and keep isLoading false so user can retry
        setState(() => isLoading = false);
        _showErrorDialog("Failed to start camera: $e");
      }
    } else {
      setState(() {
        permissionGranted = false;
        isLoading = false;
      });
      _showErrorDialog("Camera permission is required to scan QR codes.");
    }
  }

  Future<void> sendScannedData(String scannedValue) async {
    try {
      // parse qr value (guarded)
      final uri = Uri.tryParse(scannedValue);
      final nameValue = uri?.queryParameters['name'];

      if (nameValue == null || nameValue.isEmpty) {
        _showErrorDialog("Invalid QR code: missing 'name' parameter");
        return;
      }

      final apiUrl =
          "http://192.168.11.66:8014/api/method/erp_mobile.api.masterdata.get_qr_details?data=$nameValue";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['data'] == null || data['data'].isEmpty) {
          _showErrorDialog("No label details found for this QR code.");
          return;
        }

        // Navigate to details screen (camera currently stopped)
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataDisplayScreen(data: data),
          ),
        );

        // After returning, allow next scan and restart camera
        if (!mounted) return;
        setState(() => isScanned = false);

        // small delay then restart
        await Future.delayed(const Duration(milliseconds: 300));
        try {
          await cameraController.start();
        } catch (e) {
          // If restart fails, show a dialog with retry option
          _showErrorDialog("Failed to restart scanner: $e");
        }
      } else {
        _showErrorDialog("API Error: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Failed to process QR\n$e");
    }
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(""),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              setState(() => isScanned = false);
              // restart camera when dialog closed
              await Future.delayed(const Duration(milliseconds: 250));
              try {
                await cameraController.start();
              } catch (_) {}
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double boxSize = MediaQuery.of(context).size.width * 0.6;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (!permissionGranted) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Camera permission denied",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _initScanner,
                child: const Text("Retry Permission"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (isScanned) return;

              final barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                final raw = barcode.rawValue;
                if (raw != null && !isScanned) {
                  setState(() => isScanned = true);

                  // stop camera immediately to avoid duplicate detections
                  try {
                    await cameraController.stop();
                  } catch (_) {}

                  await sendScannedData(raw);
                  break;
                }
              }
            },
          ),

          // Scanner box frame
          Center(
            child: Container(
              width: boxSize,
              height: boxSize,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // Dim overlay
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    backgroundBlendMode: BlendMode.dstOut,
                  ),
                ),
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
