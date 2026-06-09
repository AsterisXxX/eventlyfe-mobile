import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';

import '../../core/providers/ticket_provider.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController();

  bool isProcessing = false;
  String statusMessage = 'Arahkan kamera ke QR tiket';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
    super.dispose();
  }

  // 🔄 handle lifecycle (biar kamera stabil)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      controller.start();
    } else if (state == AppLifecycleState.paused) {
      controller.stop();
    }
  }

  Future<void> handleScan(String ticketId) async {
    setState(() {
      isProcessing = true;
      statusMessage = 'Memproses tiket...';
    });

    controller.stop();

    final success =
        await context.read<TicketProvider>().checkInTicket(ticketId);

    if (!mounted) return;

    setState(() {
      statusMessage = success
          ? '✅ Tiket valid (Check-in berhasil)'
          : '❌ Tiket tidak valid / sudah digunakan';
    });

    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? 'Berhasil' : 'Gagal'),
        content: Text(statusMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          )
        ],
      ),
    );

    if (!mounted) return;

    setState(() {
      isProcessing = false;
      statusMessage = 'Arahkan kamera ke QR tiket';
    });

    controller.start();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Tiket')),
      body: Stack(
        children: [
          // 📷 CAMERA
          MobileScanner(
            controller: controller,
            onDetect: (capture) {
              if (isProcessing) return;

              final List<Barcode> barcodes = capture.barcodes;

              if (barcodes.isEmpty) return;

              final String? ticketId = barcodes.first.rawValue;

              if (ticketId == null) return;

              handleScan(ticketId);
            },
          ),

          // 🎯 SCAN BOX
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),

          // 📢 STATUS
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                statusMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}