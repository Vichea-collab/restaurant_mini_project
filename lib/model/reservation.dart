import 'time_slot.dart';

enum ReservationStatus { pending, seated, completed, cancelled, noShow }

class Reservation {
  final String id;
  final String restaurantId;
  final String customerId;
  final int tableId;
  final TimeSlot slot;
  final int guest;
  final String? specialRequest;
  final DateTime createdAt;
  final DateTime holdUntil;
  ReservationStatus status = ReservationStatus.pending;

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
    ReservationStatus? status,
  }) : status = status ?? ReservationStatus.pending;
}
