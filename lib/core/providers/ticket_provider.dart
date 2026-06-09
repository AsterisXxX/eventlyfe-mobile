import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../models/ticket_model.dart';

class TicketProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Ticket> _tickets = [];
  List<Ticket> get tickets => _tickets;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _isListening = false;
  String? _currentUid; // 🔥 track UID yang sedang didengarkan

  // 🔥 LISTEN REALTIME TICKETS
  void listenTickets() {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("USER NULL → CLEAR TICKETS");
      stopListening();
      clearTickets();
      return;
    }

    // 🔥 kalau UID sama & sudah listening → skip
    if (_isListening && _currentUid == user.uid) return;

    // 🔥 kalau UID berubah (login user lain) → reset listener
    if (_currentUid != user.uid) {
      stopListening();
      _currentUid = user.uid;
    }

    debugPrint("🔥 Listening tickets for UID: ${user.uid}");

    _subscription = _firestore
        .collection('tickets')
        .where('userId', isEqualTo: user.uid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      debugPrint("🔥 Firestore tickets: ${snapshot.docs.length}");

      _tickets = snapshot.docs.map((doc) {
        final data = doc.data();

        // 🔥 DEBUG
        debugPrint("DATA FIRESTORE: $data");

        return Ticket.fromMap(doc.id, data);
      }).toList();

      notifyListeners();
    }, onError: (error) {
      debugPrint("Firestore error: $error");
    });

    _isListening = true;
  }

  // 🔴 STOP LISTENER
  void stopListening() {
    _subscription?.cancel();
    _subscription = null;
    _isListening = false;
  }

  // 🧹 CLEAR (logout)
  void clearTickets() {
    _tickets = [];
    notifyListeners();
  }

  // ➕ ADD TICKET
  Future<void> addTicket(Ticket ticket) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      debugPrint("USER BELUM LOGIN ❌");
      return;
    }

    try {
      await _firestore.collection('tickets').add(
        ticket.toMap(user.uid),
      );
    } catch (e) {
      debugPrint("ADD TICKET ERROR: $e");
    }
  }

  // ✅ CHECK-IN (QR)
  Future<bool> checkInTicket(String ticketId) async {
    try {
      final doc =
          await _firestore.collection('tickets').doc(ticketId).get();

      if (!doc.exists) return false;

      final data = doc.data();

      if (data?['checkedIn'] == true) {
        return false;
      }

      await _firestore.collection('tickets').doc(ticketId).update({
        'checkedIn': true,
        'checkedInAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      debugPrint("CHECK-IN ERROR: $e");
      return false;
    }
  }

  // ❌ DELETE
  Future<void> deleteTicket(String ticketId) async {
    try {
      await _firestore.collection('tickets').doc(ticketId).delete();
    } catch (e) {
      debugPrint("DELETE ERROR: $e");
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}