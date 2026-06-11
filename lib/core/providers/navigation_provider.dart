import 'package:flutter/material.dart';

class NavigationProvider with ChangeNotifier {
  int _currentIndex = 0;
  String _searchQuery = '';

  int get currentIndex => _currentIndex;
  String get searchQuery => _searchQuery;

  void setIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void searchAndNavigate(String query) {
    _searchQuery = query;
    _currentIndex = 1;
    notifyListeners();
  }

  void updateQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
