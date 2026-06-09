import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/event_model.dart';

class EventProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<Event> _events = [];
  List<Event> get events => _events;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _subscription;
  bool _isListening = false;

  // 🔥 LISTEN REALTIME EVENTS
  void listenEvents() {
    if (_isListening) return;

    _subscription?.cancel();

    _subscription = _firestore
        .collection('events')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .listen((snapshot) {
      debugPrint("🔥 Firestore events: ${snapshot.docs.length}");

      _events = snapshot.docs.map((doc) {
        final data = doc.data();

        return Event(
          id: doc.id, // 🔥 penting untuk edit/delete
          title: data['title'] ?? 'No Title',
          price: (data['price'] ?? 0) as int,
          image: data['image'] ?? '',
        );
      }).toList();

      notifyListeners();
    }, onError: (error) {
      debugPrint("Firestore event error: $error");
    });

    _isListening = true;
  }

  // 🔴 STOP LISTENER
  void stopListening() {
    _subscription?.cancel();
    _isListening = false;
  }

  // 🔄 REFRESH (optional manual fetch)
  Future<void> refreshEvents() async {
    final snapshot = await _firestore.collection('events').get();

    _events = snapshot.docs.map((doc) {
      final data = doc.data();

      return Event(
        id: doc.id,
        title: data['title'] ?? 'No Title',
        price: (data['price'] ?? 0) as int,
        image: data['image'] ?? '',
      );
    }).toList();

    notifyListeners();
  }

  // ➕ ADD EVENT (ADMIN)
  Future<void> addEvent(Event event) async {
    await _firestore.collection('events').add({
      'title': event.title,
      'price': event.price,
      'image': event.image,
      'createdAt': Timestamp.now(),
    });
  }

  // ✏️ UPDATE EVENT
  Future<void> updateEvent(Event event) async {
    await _firestore.collection('events').doc(event.id).update({
      'title': event.title,
      'price': event.price,
      'image': event.image,
    });
  }

  // ❌ DELETE EVENT
  Future<void> deleteEvent(String id) async {
    await _firestore.collection('events').doc(id).delete();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}