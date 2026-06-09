import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? get user => _auth.currentUser;

  bool _isAdmin = false;
  bool get isAdmin => _isAdmin;

  bool get isLoggedIn => user != null;

  // 🔐 LOGIN
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // 🔥 Ambil role admin
      await loadUserRole();

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 📝 REGISTER
  Future<String?> register(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;

      if (user != null) {
        // 🔥 Simpan ke Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'email': email,
          'isAdmin': false, // default user biasa
          'createdAt': Timestamp.now(),
        });
      }

      notifyListeners();
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message;
    } catch (e) {
      return e.toString();
    }
  }

  // 🔎 LOAD ROLE ADMIN
  Future<void> loadUserRole() async {
    final user = _auth.currentUser;

    if (user == null) return;

    final doc = await _firestore.collection('users').doc(user.uid).get();

    if (doc.exists) {
      _isAdmin = doc.data()?['isAdmin'] ?? false;
    } else {
      _isAdmin = false;
    }

    notifyListeners();
  }

  // 🚪 LOGOUT
  Future<void> logout() async {
    await _auth.signOut();

    // 🔥 reset state
    _isAdmin = false;

    notifyListeners();
  }
}