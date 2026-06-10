import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AuthProvider extends ChangeNotifier {
  final String _baseUrl = 'https://eventlyfe.imajiwa.id/api';

  String? _token;
  String? _role;
  Map<String, dynamic>? _userData;

  bool get isLoggedIn => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get user => _userData;

  bool get isAdmin => _role == 'admin';
  bool get isOrganizer => _role == 'organizer';
  bool get isChecker => _role == 'checker';
  bool get isUser => _role == 'user';

  Future<String?> login(String loginField, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({'login': loginField, 'password': password}),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 200) {
        _token = data['data']['token'];
        _role = data['data']['role'];
        _userData = data['data']['user'];
        notifyListeners();
        return null;
      } else {
        return data['message'] ?? 'Login gagal. Periksa kembali data Anda.';
      }
    } catch (e) {
      debugPrint("Login error: $e");
      return 'Gagal terhubung ke server. Pastikan jaringan aman.';
    }
  }

  Future<String?> register(
    String fullName,
    String username,
    String email,
    String password,
    String confirmPassword,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/register'),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'full_name': fullName,
          'username': username,
          'email': email,
          'password': password,
          'password_confirmation': confirmPassword,
          // Secara default aplikasi mobile mendaftarkan 'user' (pembeli)
          'role': 'user',
        }),
      );

      final data = json.decode(response.body);

      if (response.statusCode == 201) {
        // 🔥 Sama seperti login, langsung simpan datanya
        _token = data['data']['token'];
        _role = data['data']['role'];
        _userData = data['data']['user'];

        notifyListeners();
        return null;
      } else {
        // Menangkap error validasi dari Laravel (misal: email sudah dipakai)
        if (data['errors'] != null) {
          final firstErrorKey = data['errors'].keys.first;
          return data['errors'][firstErrorKey][0];
        }
        return data['message'] ?? 'Gagal mendaftar. Coba lagi.';
      }
    } catch (e) {
      debugPrint("Register error: $e");
      return 'Gagal terhubung ke server.';
    }
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    if (_token != null) {
      try {
        // Hit API logout untuk menghancurkan token di database Laravel
        await http.post(
          Uri.parse('$_baseUrl/logout'),
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $_token',
          },
        );
      } catch (e) {
        debugPrint("API Logout error: $e");
        // Jika API gagal (misal karena offline), kita tetap lanjutkan proses
        // penghapusan state lokal di bawah ini.
      }
    }

    // 🔥 Reset state lokal
    _token = null;
    _role = null;
    _userData = null;

    // TODO: Hapus token dari SharedPreferences di sini

    notifyListeners();
  }
}
