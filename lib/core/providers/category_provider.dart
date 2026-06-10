import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class CategoryProvider with ChangeNotifier {
  // Gunakan URL Production kamu
  final String _baseUrl = 'https://eventlyfe.imajiwa.id/api';

  List<dynamic> _categories = [];
  bool _isLoading = false;

  List<dynamic> get categories => _categories;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$_baseUrl/categories'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _categories = data['data']; // Mengambil array 'data' dari JSON Laravel
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }

    _isLoading = false;
    notifyListeners();
  }
}
