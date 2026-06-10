import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../models/event_model.dart';

class EventProvider extends ChangeNotifier {
  // Ganti dengan IP komputermu dan tambahkan prefix /api
  final String _baseUrl = 'https://eventlyfe.imajiwa.id/api';

  List<Event> _events = [];
  List<Event> get events => _events;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Variabel untuk menyimpan token Sanctum
  String? _authToken;

  // Method untuk mengupdate token dari AuthProvider
  void updateToken(String? token) {
    _authToken = token;
  }

  // Helper untuk Headers
  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  // 🔄 FETCH EVENTS (Menggantikan listenEvents & refreshEvents Firebase)
  Future<void> fetchEvents() async {
    _isLoading = true;
    // Hapus notifyListeners() di sini jika tidak ingin UI berkedip saat fetch ulang
    notifyListeners();

    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/events'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        final List<dynamic> eventsData = responseData['data'] ?? [];

        _events = eventsData.map((data) {
          String imageUrl = data['image'] ?? '';
          if (imageUrl.isNotEmpty && !imageUrl.startsWith('http')) {
            final rootUrl = _baseUrl.replaceAll('/api', '');

            if (imageUrl.startsWith('events/')) {
              imageUrl = '$rootUrl/storage/$imageUrl';
            } else {
              imageUrl = '$rootUrl/images/events/$imageUrl';
            }
          }

          return Event(
            id: data['id'].toString(),
            title:
                data['name'] ??
                'No Title', // Sudah disesuaikan dengan kolom 'name' di DB
            price: int.tryParse(data['price'].toString()) ?? 0,
            image: imageUrl, // URL final yang sudah matang
          );
        }).toList();

        debugPrint("🔥 Laravel events fetched: ${_events.length}");
      } else {
        debugPrint(
          "Error fetching events: ${response.statusCode} - ${response.body}",
        );
      }
    } catch (error) {
      debugPrint("API event fetch error: $error");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ➕ ADD EVENT (ADMIN/ORGANIZER)
  Future<bool> addEvent(Event event) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/organizer/events',
        ), // Sesuaikan dengan route Laravel-mu
        headers: _headers,
        body: json.encode({
          'title': event.title,
          'price': event.price,
          'image': event.image,
          // 'createdAt' tidak perlu dikirim karena Laravel mengurusnya lewat TimeStamps
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        await fetchEvents(); // Refresh data setelah berhasil nambah
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Add event error: $e");
      return false;
    }
  }

  // ✏️ UPDATE EVENT
  Future<bool> updateEvent(Event event) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/organizer/events/${event.id}'),
        headers: _headers,
        body: json.encode({
          'title': event.title,
          'price': event.price,
          'image': event.image,
        }),
      );

      if (response.statusCode == 200) {
        await fetchEvents();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Update event error: $e");
      return false;
    }
  }

  // ❌ DELETE EVENT
  Future<bool> deleteEvent(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$_baseUrl/organizer/events/$id'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        // Hapus dari list lokal agar UI langsung update tanpa perlu nunggu fetch baru
        _events.removeWhere((event) => event.id == id);
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("Delete event error: $e");
      return false;
    }
  }
}
