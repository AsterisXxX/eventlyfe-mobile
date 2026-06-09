import 'event_model.dart';

class Ticket {
  final String id;
  final Event event;
  final int quantity;
  final int total;
  final bool checkedIn;

  const Ticket({
    required this.id,
    required this.event,
    required this.quantity,
    required this.total,
    required this.checkedIn,
  });

  // 🔥 FROM FIRESTORE
  factory Ticket.fromMap(String id, Map<String, dynamic> data) {
    return Ticket(
      id: id,
      event: Event(
        id: '',
        title: data['title'] ?? '',
        price: (data['price'] ?? 0) as int,
        image: '',
      ),
      quantity: (data['quantity'] ?? 0) as int,
      total: (data['total'] ?? 0) as int,
      checkedIn: data['checkedIn'] ?? false,
    );
  }

  // 🔥 TO FIRESTORE
  Map<String, dynamic> toMap(String userId) {
    return {
      'userId': userId,
      'title': event.title,
      'price': event.price,
      'quantity': quantity,
      'total': total,
      'checkedIn': false,
      'checkedInAt': null,
    };
  }
}