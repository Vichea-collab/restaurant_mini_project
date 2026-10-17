import 'customer.dart';
import 'restaurant.dart';
import 'table.dart';
import 'time_slot.dart';

enum ReservationStatus {
  pending('Pending'),
  seated('Seated'),
  completed('Completed'),
  cancelled('Cancelled');

  final String label;
  const ReservationStatus(this.label);
}

class Reservation {
  static const int minGuests = 1;
  static const int visitHours = 2;

  final String id;
  final Restaurant restaurant;
  final Table table;
  final Customer customer;
  final TimeSlot slot;
  final int guest;
  final String? specialRequest;
  ReservationStatus status;

  Reservation({
    required this.id,
    required this.restaurant,
    required this.table,
    required this.customer,
    required this.slot,
    required this.guest,
    this.specialRequest,
    this.status = ReservationStatus.pending,
  });

  bool get holdsTable =>
      status == ReservationStatus.pending || status == ReservationStatus.seated;
}
