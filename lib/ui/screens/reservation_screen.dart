import 'package:flutter/material.dart';

import '../../model/reservation.dart';
import '../../service/restaurant_service.dart';
import '../widgets/theme.dart';
import '../widgets/app_card.dart';
import '../widgets/filter_bar.dart';
import '../widgets/status_badge.dart';

class ReservationScreen extends StatefulWidget {
  final RestaurantService service;
  final String customerId;

  const ReservationScreen({
    super.key,
    required this.service,
    required this.customerId,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  String selectedFilter = 'All';

  List<String> get filterOptions {
    List<String> options = ['All'];
    for (ReservationStatus status in ReservationStatus.values) {
      options.add(status.label);
    }
    return options;
  }

  ReservationStatus? get selectedStatus {
    for (ReservationStatus status in ReservationStatus.values) {
      if (status.label == selectedFilter) {
        return status;
      }
    }
    return null;
  }

  void onFilterChanged(String option) {
    setState(() {
      selectedFilter = option;
    });
  }

  String _subtitle(Reservation reservation) {
    final location = widget.service.getTableLocationName(
      reservation.restaurantId,
      reservation.tableId,
    );
    return '${reservation.guest} guests · Table ${reservation.tableId} · $location';
  }

  static String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final reservations = widget.service.getReservationsForCustomer(
      customerId: widget.customerId,
      status: selectedStatus,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Reservation',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          FilterBar(
            options: filterOptions,
            selectedOption: selectedFilter,
            onSelected: onFilterChanged,
          ),
          const SizedBox(height: 16),
          if (reservations.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(
                child: Text(
                  'No reservations',
                  style: TextStyle(fontSize: 14, color: AppColors.hint),
                ),
              ),
            )
          else
            for (final reservation in reservations)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AppCard(
                  leading: Text(
                    _formatTime(reservation.slot.start),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.text,
                    ),
                  ),
                  title: widget.service.getRestaurantName(
                    reservation.restaurantId,
                  ),
                  subtitle: _subtitle(reservation),
                  trailing: StatusBadge(status: reservation.status),
                ),
              ),
        ],
      ),
    );
  }
}
