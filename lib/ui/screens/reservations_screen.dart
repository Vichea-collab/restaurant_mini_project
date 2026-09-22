import 'package:flutter/material.dart' hide Table;

import '../../model/reservation.dart';
import '../../service/restaurant_service.dart';
import '../widgets/filter_pill.dart';
import '../widgets/reservation_card.dart';
import 'reservation_sucess_screen.dart';

class ReservationsScreen extends StatelessWidget {
  final RestaurantService service;
  final String? customerId;

  const ReservationsScreen({super.key, required this.service, this.customerId});

  static String _filterDisplayName(ReservationStatus status) {
    switch (status) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.seated:
        return 'Seated';
      case ReservationStatus.completed:
        return 'Completed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.noShow:
        return 'No-show';
    }
  }

  @override
  Widget build(BuildContext context) {
    final reservations = (customerId != null && customerId!.isNotEmpty)
        ? service.getReservationsForCustomer(customerId: customerId!)
        : service.reservations;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Reservation',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E232A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterPill(
                  text: 'All · ${reservations.length}',
                  isSelected: true,
                ),
                for (final status in const [
                  ReservationStatus.pending,
                  ReservationStatus.seated,
                  ReservationStatus.completed,
                  ReservationStatus.cancelled,
                  ReservationStatus.noShow,
                ]) ...[
                  const SizedBox(width: 8),
                  FilterPill(
                    text: _filterDisplayName(status),
                    isSelected: false,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final reservation in reservations) ...[
            Builder(
              builder: (context) {
                final start = reservation.slot.start;
                final end = reservation.slot.end;
                final startTime =
                    '${start.hour.toString().padLeft(2, '0')}:${start.minute.toString().padLeft(2, '0')}';
                final endTime =
                    '${end.hour.toString().padLeft(2, '0')}:${end.minute.toString().padLeft(2, '0')}';

                final r = service.restaurants.firstWhere(
                  (r) => r.id == reservation.restaurantId,
                  orElse: () => service.restaurants.first,
                );
                final restaurantName = r.name;

                final c = service.customers.firstWhere(
                  (c) => c.id == reservation.customerId,
                  orElse: () => service.customers.first,
                );
                final customerName = c.name;
                final customerPhone = c.phone;

                final t = r.tables.firstWhere(
                  (t) => t.id == reservation.tableId,
                  orElse: () => r.tables.first,
                );
                final locationName =
                    '${t.location.name[0].toUpperCase()}${t.location.name.substring(1)}';
                final seats = t.seats;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: ReservationCard(
                    startTime: startTime,
                    endTime: endTime,
                    title: restaurantName,
                    subtitle:
                        '${reservation.guest} guests · Table ${reservation.tableId} · $locationName',
                    status: reservation.status.name,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReservationSucessScreen(
                            service: service,
                            reservation: reservation,
                            restaurantName: restaurantName,
                            customerName: customerName,
                            customerPhone: customerPhone,
                            tableSeats: seats,
                            tableLocation: locationName,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }
}
