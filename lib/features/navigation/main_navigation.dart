import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/navigation_provider.dart';

import '../home/home_page.dart';
import '../tickets/tickets_page.dart';
import '../profile/profile_page.dart';
import '../explore/explore_page.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  final List<Widget> pages = const [
    HomePage(),
    ExplorePage(),
    TicketsPage(),
    ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final navProvider = context.watch<NavigationProvider>();
    final currentIndex = navProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(index: currentIndex, children: pages),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  context,
                  currentIndex,
                  0,
                  Icons.home_outlined,
                  Icons.home,
                  'Home',
                ),
                _navItem(
                  context,
                  currentIndex,
                  1,
                  Icons.explore_outlined,
                  Icons.explore,
                  'Explore',
                ),
                _navItem(
                  context,
                  currentIndex,
                  2,
                  Icons.confirmation_number_outlined,
                  Icons.confirmation_number,
                  'Tiket',
                ),
                _navItem(
                  context,
                  currentIndex,
                  3,
                  Icons.person_outline,
                  Icons.person,
                  'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
    BuildContext context,
    int currentIndex,
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        context.read<NavigationProvider>().setIndex(index);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.blue.withValues(alpha: 0.2)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? activeIcon : icon,
              color: isSelected ? Colors.blue : Colors.grey,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: isSelected ? Colors.blue : Colors.grey,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
