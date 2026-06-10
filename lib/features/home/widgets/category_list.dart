import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/category_provider.dart'; // Sesuaikan path importnya

class CategoryList extends StatefulWidget {
  const CategoryList({super.key});

  @override
  State<CategoryList> createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryList> {
  @override
  void initState() {
    super.initState();
    // Tarik data dari API Laravel saat widget pertama kali dirender
    Future.microtask(() {
      context.read<CategoryProvider>().fetchCategories();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pantau perubahan data dari provider
    final categoryProvider = context.watch<CategoryProvider>();
    final categories = categoryProvider.categories;
    final isLoading = categoryProvider.isLoading;

    // Jika sedang loading, tampilkan indikator loading
    if (isLoading && categories.isEmpty) {
      return const SizedBox(
        height: 40,
        child: Center(
          child: SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              color: Colors.blue,
              strokeWidth: 2,
            ),
          ),
        ),
      );
    }

    // Jika tidak ada data dari database
    if (categories.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        itemBuilder: (context, index) {
          // Asumsi field nama kategori di database Laravel adalah 'name'
          final categoryName = categories[index]['name'] ?? 'Unknown';

          return Container(
            margin: const EdgeInsets.only(right: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(
                0xFF1877F2,
              ), // Warna biru disamakan dengan tema web
              borderRadius: BorderRadius.circular(20),
            ),
            alignment: Alignment.center,
            child: Text(
              categoryName,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        },
      ),
    );
  }
}
