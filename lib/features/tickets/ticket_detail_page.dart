import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../models/ticket_model.dart';
import '../../core/utils/currency_formatter.dart';

class TicketDetailPage extends StatelessWidget {
  final Ticket ticket;

  const TicketDetailPage({super.key, required this.ticket});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🎫 Banner
            Container(
              height: 180,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(12),
              ),
            ),

            const SizedBox(height: 20),

            // 🎤 Judul Event
            Text(
              ticket.event.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text('Jumlah Tiket: ${ticket.quantity}'),

            const SizedBox(height: 10),

            Text(
              'Total: ${CurrencyFormatter.format(ticket.total)}',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            const Divider(),

            const SizedBox(height: 20),

            // 🔳 QR TITLE
            const Center(
              child: Text(
                'QR Tiket',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),

            const SizedBox(height: 10),

            // 🔥 QR CODE (FINAL FIX)
            Center(
              child: QrImageView(
                data: ticket.id, // 🔥 PENTING
                size: 200,
                backgroundColor: Colors.white,
              ),
            ),

            const SizedBox(height: 20),

            // 🔥 STATUS TIKET
            Center(
              child: Text(
                ticket.checkedIn
                    ? 'SUDAH DIGUNAKAN'
                    : 'BELUM DIGUNAKAN',
                style: TextStyle(
                  fontSize: 14,
                  color: ticket.checkedIn ? Colors.red : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Center(
              child: Text(
                'Tunjukkan QR ini saat masuk event',
                style: TextStyle(fontSize: 12),
              ),
            ),

            const Spacer(),

            // 🔘 BUTTON (OPSIONAL NAVIGATE SCANNER)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Gunakan scanner di halaman admin'),
                    ),
                  );
                },
                child: const Text('Validasi Tiket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}