import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/ticket_provider.dart';
import '../../core/providers/auth_provider.dart'; // 🔥 Tambahkan import ini
import '../../core/utils/currency_formatter.dart';

import '../auth/login_page.dart'; // 🔥 Tambahkan import ini
import 'ticket_detail_page.dart';

class TicketsPage extends StatefulWidget {
  const TicketsPage({super.key});

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      // 🔥 Hanya panggil API tiket JIKA user sudah login
      final isLoggedIn = context.read<AuthProvider>().isLoggedIn;
      if (isLoggedIn) {
        context.read<TicketProvider>().listenTickets();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // 🔥 Pantau status login
    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;

    // Jika belum login, tampilkan layar ajakan login
    if (!isLoggedIn) {
      return Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              Expanded(child: _unauthenticatedState(context)),
            ],
          ),
        ),
      );
    }

    // Jika sudah login, jalankan logika tiket seperti biasa
    final tickets = context.watch<TicketProvider>().tickets;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),

            // 📋 CONTENT
            Expanded(
              child: tickets.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: tickets.length,
                      itemBuilder: (context, index) {
                        final ticket = tickets[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: _ticketCard(context, ticket),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // Pisahkan Header agar kodingan lebih rapi dan bisa dipakai berulang
  Widget _buildHeader() {
    return const Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Text(
        'Tiket Saya',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }

  // 🔥 TAMPILAN JIKA BELUM LOGIN
  // 🔥 TAMPILAN JIKA BELUM LOGIN (UX Friendly)
  Widget _unauthenticatedState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ikon dibuat lebih soft menggunakan warna tema
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.blue.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons
                  .local_activity_outlined, // Menggunakan ikon tiket alih-alih gembok
              size: 50,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Yuk, Masuk Dulu! 👋',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          // Penjelasan benefit (kenapa harus login)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              'Masuk atau daftar sekarang buat lihat dan simpan semua tiket event favoritmu di sini.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14, height: 1.5),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1877F2), // Warna biru tema web
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
              ).then((_) {
                if (context.read<AuthProvider>().isLoggedIn && mounted) {
                  context.read<TicketProvider>().listenTickets();
                }
              });
            },
            child: const Text(
              'Masuk ke Akun',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1A1A1A),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.confirmation_number_outlined,
              size: 50,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada tiket',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Pesan ticket event favoritmu',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _ticketCard(BuildContext context, ticket) {
    final isUsed = ticket.checkedIn;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => TicketDetailPage(ticket: ticket)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUsed ? Colors.grey : Colors.blue.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            // 🔝 HEADER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // 🎫 ICON
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isUsed
                          ? Colors.grey.withValues(alpha: 0.2)
                          : Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      Icons.confirmation_number,
                      color: isUsed ? Colors.grey : Colors.blue,
                    ),
                  ),

                  const SizedBox(width: 12),

                  // 📄 INFO
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          ticket.event.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Jumlah: ${ticket.quantity} tiket',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // 🔥 STATUS
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isUsed
                          ? Colors.red.withValues(alpha: 0.2)
                          : Colors.green.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      isUsed ? 'Terpakai' : 'Aktif',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isUsed ? Colors.red : Colors.green,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ✂️ DASH LINE
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: List.generate(
                  30,
                  (index) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 1),
                      height: 1,
                      color: Colors.white12,
                    ),
                  ),
                ),
              ),
            ),

            // 🔻 FOOTER
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 💰 TOTAL
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Pembayaran',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        CurrencyFormatter.format(ticket.total),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),

                  // 🔍 CTA
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      children: [
                        Text(
                          'Lihat',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.blue,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
