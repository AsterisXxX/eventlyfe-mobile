import '../../models/ticket_model.dart';

class TicketStorage {
  static List<Ticket> tickets = [];

  static void addTicket(Ticket ticket) {
    tickets.add(ticket);
  }
}