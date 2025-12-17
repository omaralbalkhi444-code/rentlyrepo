import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:p2/services/firestore_service.dart';

class QrScannerPage extends StatelessWidget {
  final String requestId;

  const QrScannerPage({super.key, required this.requestId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Scan Pickup QR")),
      body: MobileScanner(
        onDetect: (capture) async {
          final qr = capture.barcodes.first.rawValue;
          if (qr == null) return;

          try {
            await FirestoreService.updateRentalRequestStatus(
              requestId,
              "active",
              qrToken: qr,
            );

            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Pickup confirmed")),
              );
              Navigator.pop(context);
            }
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Invalid QR code")),
            );
          }
        },
      ),
    );
  }
}
