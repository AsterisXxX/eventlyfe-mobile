import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/navigation_provider.dart';

class SearchBarWidget extends StatefulWidget {
  const SearchBarWidget({super.key});

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 🔥 Fungsi Eksekusi Pencarian
  void _submitSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      // Simpan kata kunci ke provider dan otomatis pindah ke Explore
      context.read<NavigationProvider>().searchAndNavigate(query);
      // Kosongkan search bar di home agar bersih saat user kembali
      _searchController.clear();
    } else {
      // Walau kosong, tetap pindahkan ke Explore jika tombol dipencet
      context.read<NavigationProvider>().setIndex(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Temukan pengalaman\ntak terlupakan!',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 20),

          // 🔥 Search Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              onSubmitted: (_) =>
                  _submitSearch(), // Menangkap aksi tombol 'Enter/Search' di keyboard HP
              decoration: const InputDecoration(
                hintText: 'Konser, Webinar, dll...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 🔥 Cari Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1877F2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _submitSearch, // Panggil fungsi di atas
              child: const Text(
                'Cari Event',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
