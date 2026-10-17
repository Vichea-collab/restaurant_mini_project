import 'package:flutter/material.dart';

import '../../model/reservation.dart';
import '../../model/customer.dart';
import '../widgets/chip/status_chip.dart';
import '../widgets/filter_dropdown.dart';

class ReservationScreen extends StatefulWidget {
  final List<Reservation> reservations;
  final Customer customer;

  const ReservationScreen({
    super.key,
    required this.reservations,
    required this.customer,
  });

  @override
  State<ReservationScreen> createState() => _ReservationScreenState();
}

class _ReservationScreenState extends State<ReservationScreen> {
  ReservationStatus? selectedStatus;

  List<Reservation> get filteredReservations {
    List<Reservation> result = [];
    for (Reservation reservation in widget.reservations) {
      if (reservation.customer != widget.customer) {
        continue;
      }
      if (selectedStatus == null || reservation.status == selectedStatus) {
        result.add(reservation);
      }
    }
    return result;
  }

  void onFilterChanged(ReservationStatus? status) {
    setState(() {
      selectedStatus = status;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reservations = filteredReservations;

    return Scaffold(
      appBar: AppBar(title: const Text('Reservation')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: [
            FilterDropdown<ReservationStatus>(
              label: 'Status',
              selected: selectedStatus,
              values: ReservationStatus.values,
              labelOf: (status) => status.label,
              onSelected: onFilterChanged,
            ),
            const SizedBox(height: 10),
            if (reservations.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: Text('No reservations')),
              ),
            for (final reservation in reservations)
              ReservationTile(reservation: reservation),
          ],
        ),
      ),
    );
  }
}

class ReservationTile extends StatelessWidget {
  final Reservation reservation;

  const ReservationTile({super.key, required this.reservation});

  @override
  Widget build(BuildContext context) {
    final start = reservation.slot.start;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Text('${start.hour}:00', style: const TextStyle(fontSize: 16)),
        title: Text(reservation.restaurant.name),
        subtitle: Text(
          '${start.day}/${start.month}/${start.year} · ${reservation.guest} guests · '
          'Table ${reservation.table.id} · ${reservation.table.location.label}',
        ),
        trailing: StatusChip(status: reservation.status),
      ),
    );
  }
}
