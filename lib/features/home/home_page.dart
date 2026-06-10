import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../core/providers/event_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/providers/category_provider.dart';
import '../../core/utils/currency_formatter.dart';

import 'widgets/category_list.dart';
import 'widgets/search_bar_widget.dart';
import 'widgets/event_card.dart';

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
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  Future<void> _onRefresh() async {
    await context.read<EventProvider>().fetchEvents();
    await context.read<CategoryProvider>().fetchCategories();
  }

  @override
  Widget build(BuildContext context) {
    final eventProvider = context.watch<EventProvider>();
    final events = eventProvider.events;
    final isLoading = eventProvider.isLoading;

    final auth = context.watch<AuthProvider>();
    final isLoggedIn = auth.isLoggedIn;

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          color: const Color(0xFF1877F2),
          backgroundColor: const Color(0xFF1A1A1A),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Image.asset(
                            'assets/images/logo.png',
                            height: 35,
                            fit: BoxFit.contain,
                          ),
                        ],
                      ),
                      !isLoggedIn
                          ? _buildLoginButton()
                          : _buildUserAvatar(auth),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(child: SearchBarWidget()),
              SliverToBoxAdapter(child: CategoryList()),

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
                                child: EventCard(event: events[index]),
                              );
                            },
                          ),
                        ),
                ),
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
