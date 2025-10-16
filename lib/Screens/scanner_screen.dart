import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'display_screen.dart'; // Screen to show API response

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final MobileScannerController cameraController = MobileScannerController();
  bool isScanned = false; // Prevent multiple scans

  @override
  void dispose() {
    cameraController.dispose();
    super.dispose();
  }

  // ✅ Send scanned QR value to API after extracting 'name'
  Future<void> sendScannedData(String scannedValue) async {
    try {
      // Parse scanned URL
      final uri = Uri.parse(scannedValue);
      final nameValue = uri.queryParameters['name'];

      if (nameValue == null || nameValue.isEmpty) {
        _showErrorDialog("Invalid QR code: missing 'name' parameter");
        return;
      }

      // Call API with extracted 'name'
      final String apiUrl =
          "http://192.168.11.66:8014/api/method/erp_mobile.api.masterdata.get_qr_details?data=$nameValue";

      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);


        // Check if data contains valid label details
        if (data['data'] == null || data['data'].isEmpty) {
          _showErrorDialog("No label details found for this QR code.");
          return;
        }

        // Navigate to display screen and wait for return
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DataDisplayScreen(data: data),
          ),
        );

        // Reset scanner so it can scan again when coming back
        setState(() {
          isScanned = false;
        });
      } else {
        _showErrorDialog("API Error: ${response.statusCode}");
      }
    } catch (e) {
      _showErrorDialog("Failed to call API\n$e");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(""),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isScanned = false; // ✅ allow scanning again after error
              });
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

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // ✅ Fullscreen camera
          MobileScanner(
            controller: cameraController,
            onDetect: (capture) async {
              if (isScanned) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  setState(() => isScanned = true);
                  final scannedValue = barcode.rawValue!;
                  await sendScannedData(scannedValue);
                  break;
                }
              }
            },
          ),

          // ✅ Center scanner box
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

          // ✅ Optional dimmed overlay around scanner box
          ColorFiltered(
            colorFilter: ColorFilter.mode(
              Colors.black.withOpacity(0.6),
              BlendMode.srcOut,
            ),
            child: Stack(
              fit: StackFit.expand,
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
