import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/providers/event_provider.dart';
import '../../core/providers/auth_provider.dart';
// import '../../core/providers/category_provider.dart'; // Import ini
import '../../core/utils/currency_formatter.dart';

import '../auth/login_page.dart';
import '../event/event_detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<EventProvider>().fetchEvents();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<EventProvider>().fetchEvents();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.events;
    final isLoading = eventProvider.isLoading;

    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;

    return Scaffold(
      backgroundColor: const Color(
        0xFF121212,
      ), // Disamakan dengan base background web
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF1877F2),
          backgroundColor: const Color(0xFF1A1A1A),
          child: CustomScrollView(
            slivers: [
              // 🔥 1. HEADER / NAVBAR (Logo EventLyfe)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Logo EventLyfe (Adaptasi teks 2 warna ala Web)
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png', // Sesuaikan nama filenya
                            height:
                                35, // Atur tinggi logo agar pas dengan AppBar
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      // 🔐 AUTH BUTTON
                      !isLoggedIn
                          ? _buildLoginButton()
                          : _buildUserAvatar(auth),
                    ],
                  ),
                ),
              ),

              // 🔥 2. HERO SEARCH SECTION (Solid Dark Grey ala Web)
              SliverToBoxAdapter(child: _buildHeroSearch()),

              // 🔥 3. JELAJAHI KATEGORI
              SliverToBoxAdapter(child: _buildCategories()),

              // 🔥 LOADING INDICATOR
              if (isLoading && events.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1877F2),
                      ),
                    ),
                  ),
                ),

              // 🔥 4. SECTION TITLE: EVENT PILIHAN
              if (!isLoading || events.isNotEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 30, 20, 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Event Pilihan',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          'Lihat Semua',
                          style: TextStyle(fontSize: 12, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ),

              // 🔥 5. HORIZONTAL LIST (Event Pilihan)
              if (!isLoading)
                SliverToBoxAdapter(
                  child: events.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: Text(
                              'Belum ada event tersedia',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        )
                      : SizedBox(
                          height: 220,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            scrollDirection: Axis.horizontal,
                            itemCount: events.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: _eventCard(context, events[index]),
                              );
                            },
                          ),
                        ),
                ),

              // 🔥 6. RECOMMENDED SECTION
              if (!isLoading && events.isNotEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20, 30, 20, 12),
                    child: Text(
                      'Rekomendasi Lainnya',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

              // 🔥 7. VERTICAL LIST
              if (!isLoading && events.isNotEmpty)
                SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    if (index >= events.length) return null;
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 6,
                      ),
                      child: _listTile(context, events[index]),
                    );
                  }, childCount: events.length),
                ),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  // =========================================================================
  // WIDGET COMPONENTS
  // =========================================================================

  // 🔹 HERO SEARCH BANNER
  Widget _buildHeroSearch() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(
          0xFF1A1A1A,
        ), // Mengikuti base dark grey dari web search box
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
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
          // Search Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFF121212),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: const TextField(
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Konser, Webinar, dll...',
                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.grey, size: 20),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Location & Date
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Semua Lokasi',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF121212),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        color: Colors.grey,
                        size: 18,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pilih Waktu',
                          style: TextStyle(color: Colors.grey, fontSize: 13),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Cari Button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(
                  0xFF1877F2,
                ), // Warna biru solid web
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {},
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

  // 🔹 JELAJAHI KATEGORI
  Widget _buildCategories() {
    final categories = [
      {'icon': Icons.music_note, 'title': 'Musik', 'color': Colors.amber},
      {'icon': Icons.work_outline, 'title': 'Workshop', 'color': Colors.blue},
      {
        'icon': Icons.sports_esports,
        'title': 'Game',
        'color': Colors.redAccent,
      },
      {'icon': Icons.palette_outlined, 'title': 'Hobi', 'color': Colors.green},
      {
        'icon': Icons.festival_outlined,
        'title': 'Festival',
        'color': Colors.cyan,
      },
    ];

    return Padding(
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Jelajahi Kategori',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 90,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final cat = categories[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Column(
                    children: [
                      Container(
                        height: 55,
                        width: 55,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF1A1A1A),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.05),
                          ),
                        ),
                        child: Icon(
                          cat['icon'] as IconData,
                          color: cat['color'] as Color,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        cat['title'] as String,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // 🔹 AUTH BUTTONS
  Widget _buildLoginButton() {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: Color(0xFF1877F2), width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      ),
      onPressed: () => _navigateTo(const LoginPage()),
      child: const Text(
        'Masuk',
        style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildUserAvatar(AuthProvider auth) {
    final userMap = auth.user;
    final email = userMap != null ? userMap['email'] : 'User';

    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'logout') await auth.logout();
      },
      offset: const Offset(0, 50),
      color: const Color(0xFF1E1E1E),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'email',
          enabled: false,
          child: Row(
            children: [
              const CircleAvatar(
                radius: 16,
                backgroundColor: Color(0xFF1877F2),
                child: Icon(Icons.person, size: 18, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  email,
                  style: const TextStyle(fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: 'logout',
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: Colors.red),
              SizedBox(width: 12),
              Text('Logout', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
      child: const CircleAvatar(
        radius: 18,
        backgroundColor: Color(0xFF1877F2),
        child: Icon(Icons.person, color: Colors.white, size: 20),
      ),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  // 🔹 CARD EVENT HORIZONTAL
  Widget _eventCard(BuildContext context, event) {
    return GestureDetector(
      onTap: () => _navigateTo(EventDetailPage(event: event)),
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: event.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: event.image,
                      width: double.infinity,
                      height: 110,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      height: 110,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    CurrencyFormatter.format(event.price),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
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

  // 🔹 LIST TILE VERTIKAL
  Widget _listTile(BuildContext context, event) {
    return GestureDetector(
      onTap: () => _navigateTo(EventDetailPage(event: event)),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: event.image.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: event.image,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[900],
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[800],
                        child: const Icon(
                          Icons.broken_image,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[800],
                      child: const Icon(Icons.image, color: Colors.grey),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    CurrencyFormatter.format(event.price),
                    style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
