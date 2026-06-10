import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/category_provider.dart';

class CategoryList extends StatelessWidget {
  const CategoryList({super.key});

  @override
  Widget build(BuildContext context) {
    // Pantau data dari CategoryProvider
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;
    final isLoading = categoryProvider.isLoading;

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
            child: isLoading && categories.isEmpty
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF1877F2)),
                  )
                : categories.isEmpty
                ? const Center(
                    child: Text(
                      'Kategori kosong',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final catName = categories[index]['name'] ?? 'Kategori';

                      // 🔥 LOGIKA PEMETAAN ICON & WARNA DINAMIS
                      IconData iconData = Icons.label_important;
                      Color iconColor = Colors.grey;

                      final nameLower = catName.toString().toLowerCase();

                      if (nameLower.contains('musik')) {
                        iconData = Icons.music_note;
                        iconColor = Colors.amber;
                      } else if (nameLower.contains('workshop') ||
                          nameLower.contains('seminar')) {
                        iconData = Icons.work_outline;
                        iconColor = Colors.blue;
                      } else if (nameLower.contains('game') ||
                          nameLower.contains('esport')) {
                        iconData = Icons.sports_esports;
                        iconColor = Colors.redAccent;
                      } else if (nameLower.contains('hobi')) {
                        iconData = Icons.palette_outlined;
                        iconColor = Colors.green;
                      } else if (nameLower.contains('festival')) {
                        iconData = Icons.festival_outlined;
                        iconColor = Colors.cyan;
                      } else {
                        iconData = Icons.explore;
                        iconColor = Colors.orange;
                      }

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
                              child: Icon(iconData, color: iconColor, size: 24),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              catName,
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
}
