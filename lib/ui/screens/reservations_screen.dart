import 'package:flutter/material.dart' hide Table;

import '../../model/reservation.dart';
import '../widgets/filter_pill.dart';
import '../widgets/reservation_card.dart';

class ReservationsScreen extends StatelessWidget {
  final List<Reservation> reservations;
  final String Function(String restaurantId)? getRestaurantName;
  final String Function(String restaurantId, int tableId)? getTableLocationName;

  const ReservationsScreen({
    super.key,
    required this.reservations,
    this.getRestaurantName,
    this.getTableLocationName,
  });

  static String _filterDisplayName(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Pending';
      case 'seated':
        return 'Seated';
      case 'completed':
        return 'Completed';
      case 'cancelled':
        return 'Cancelled';
      case 'noshow':
      case 'no-show':
        return 'No-show';
      default:
        return status;
    }
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
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
                  'pending',
                  'seated',
                  'completed',
                  'cancelled',
                  'no-show',
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
          for (final reservation in reservations)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ReservationCard(
                startTime: _formatTime(reservation.slot.start),
                endTime: _formatTime(reservation.slot.end),
                title:
                    getRestaurantName?.call(reservation.restaurantId) ??
                    'The Bistro Gourmet',
                subtitle:
                    '${reservation.guest} guests · Table ${reservation.tableId} · ${getTableLocationName?.call(reservation.restaurantId, reservation.tableId) ?? 'Indoor'}',
                status: reservation.status.name,
              ),
            ),
        ],
      ),
    );
  }
}
