import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/providers/event_provider.dart';
import '../../models/event_model.dart';
import '../../core/utils/currency_formatter.dart';
import '../event/event_detail_page.dart';

class ExplorePage extends StatefulWidget {
  const ExplorePage({super.key});

  @override
  State<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends State<ExplorePage> {
  String searchQuery = '';
  String selectedFilter = 'default';

  List<Event> applyFilter(List<Event> events) {
    List<Event> filtered = events
        .where((e) =>
            e.title.toLowerCase().contains(searchQuery.toLowerCase()))
        .toList();

    if (selectedFilter == 'low') {
      filtered.sort((a, b) => a.price.compareTo(b.price));
    } else if (selectedFilter == 'high') {
      filtered.sort((a, b) => b.price.compareTo(a.price));
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    final events = context.watch<EventProvider>().events;
    final filteredEvents = applyFilter(events);

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // 🔥 HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Jelajahi',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.tune, size: 20),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 🔍 SEARCH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) {
                  setState(() => searchQuery = value);
                },
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Cari event...',
                  hintStyle: const TextStyle(color: Colors.grey),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: const Color(0xFF1A1A1A),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // 🔥 FILTER CHIP
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _filterChip('Semua', 'default'),
                  _filterChip('Termurah', 'low'),
                  _filterChip('Termahal', 'high'),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // 📦 GRID
            Expanded(
              child: filteredEvents.isEmpty
                  ? const Center(
                      child: Text(
                        'Tidak ada event ditemukan',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.all(20),
                      itemCount: filteredEvents.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 12,
                        crossAxisSpacing: 12,
                        childAspectRatio: 0.72,
                      ),
                      itemBuilder: (context, index) {
                        final event = filteredEvents[index];
                        return _eventCard(context, event);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔥 FILTER CHIP
  Widget _filterChip(String label, String value) {
    final isSelected = selectedFilter == value;

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontSize: 12,
          ),
        ),
        selected: isSelected,
        selectedColor: Colors.blue,
        backgroundColor: const Color(0xFF1A1A1A),
        onSelected: (_) {
          setState(() => selectedFilter = value);
        },
      ),
    );
  }

  // 🔥 CARD MODERN
  Widget _eventCard(BuildContext context, Event event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EventDetailPage(event: event),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🖼️ IMAGE
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
              child: event.image.isNotEmpty
                  ? Image.network(
                      event.image,
                      height: 100,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 100,
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
                      fontSize: 14,
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    CurrencyFormatter.format(event.price),
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
    