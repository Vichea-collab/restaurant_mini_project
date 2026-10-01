import 'time_slot.dart';

enum ReservationStatus {
  pending('Pending'),
  seated('Seated'),
  completed('Completed'),
  cancelled('Cancelled'),
  noShow('No-show');

  final String label;
  const ReservationStatus(this.label);
}

class Reservation {
  static const int minGuests = 1;

  final String id;
  final String restaurantId;
  final String customerId;
  final int tableId;
  final TimeSlot slot;
  final int guest;
  final String? specialRequest;
  final DateTime createdAt;
  final DateTime holdUntil;
  ReservationStatus status;

  Reservation({
    required this.id,
    required this.restaurantId,
    required this.customerId,
    required this.tableId,
    required this.slot,
    required this.guest,
    required this.createdAt,
    required this.holdUntil,
    this.specialRequest,
    this.status = ReservationStatus.pending,
  });
}
