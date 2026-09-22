import 'package:flutter/material.dart' hide Table;

import '../../model/reservation.dart';
import '../../model/restaurant.dart';
import '../../model/table.dart';
import '../../model/time_slot.dart';
import '../../service/restaurant_service.dart';
import '../widgets/info_field.dart';
import '../widgets/primary_button.dart';
import 'reservation_sucess_screen.dart';

class BookingScreen extends StatelessWidget {
  final RestaurantService service;
  final Restaurant? restaurant;
  final String customerId;
  final TableLocation selectedLocation;

  const BookingScreen({
    super.key,
    required this.service,
    this.restaurant,
    this.customerId = 'C103',
    this.selectedLocation = TableLocation.bar,
  });

  Restaurant get _targetRestaurant =>
      restaurant ??
      (service.restaurants.isNotEmpty
          ? service.restaurants.first
          : service.restaurant);

  @override
  Widget build(BuildContext context) {
    final r = _targetRestaurant;
    final customer = service.customers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => service.customers.first,
    );
    final customerName = customer.name;
    final customerPhone = customer.phone;

    final selectedTable = r.tables.firstWhere(
      (t) => t.location == selectedLocation,
      orElse: () => r.tables.first,
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF1E232A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'New reservation',
          style: TextStyle(
            color: Color(0xFF1E232A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          Row(
            children: [
              Expanded(
                child: InfoField(
                  label: 'Customer name',
                  icon: Icons.person_outline,
                  value: customerName,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoField(
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  value: customerPhone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Row(
            children: [
              Expanded(
                child: InfoField(
                  label: 'Date',
                  icon: Icons.calendar_today_outlined,
                  value: 'Sat 20 Sep',
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: InfoField(
                  label: 'Time',
                  icon: Icons.access_time,
                  value: '19:00 - 21:00',
                  trailing: Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: Color(0xFF9CA3AF),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Guest',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF4B5563),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFF9FAFB),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.remove, size: 20, color: Colors.grey),
                    Text(
                      '3',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Icon(Icons.add, size: 20, color: Colors.grey),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          const Text(
            'Special request',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF4B5563),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Text(
              'Birthday cake at dessert',
              style: TextStyle(fontSize: 14, color: Color(0xFF1E232A)),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Table location',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E232A),
            ),
          ),
          const SizedBox(height: 12),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final loc in const [
                TableLocation.bar,
                TableLocation.window,
                TableLocation.indoor,
                TableLocation.outdoor,
                TableLocation.privateRoom,
              ])
                _LocationOptionPill(
                  location: loc,
                  label: _locationDisplayName(loc),
                  icon: _locationIcon(loc),
                  isSelected: loc == selectedLocation,
                  onTap: () {
                    if (loc != selectedLocation) {
                      Navigator.pushReplacement(
                        context,
                        PageRouteBuilder(
                          pageBuilder:
                              (context, animation, secondaryAnimation) =>
                                  BookingScreen(
                                    service: service,
                                    restaurant: r,
                                    customerId: customerId,
                                    selectedLocation: loc,
                                  ),
                          transitionDuration: Duration.zero,
                          reverseTransitionDuration: Duration.zero,
                        ),
                      );
                    }
                  },
                ),
            ],
          ),

          const SizedBox(height: 28),

          PrimaryButton(
            text: 'Reserve Table · ${_locationDisplayName(selectedLocation)}',
            onPressed: () {
              final newId = 'RES-0${service.reservations.length + 1}';
              final confirmedReservation = Reservation(
                id: newId,
                restaurantId: r.id,
                customerId: customerId,
                tableId: selectedTable.id,
                slot: TimeSlot(
                  start: DateTime(2026, 9, 20, 19, 0),
                  end: DateTime(2026, 9, 20, 21, 0),
                ),
                guest: 3,
                specialRequest: 'Birthday cake at dessert',
                status: ReservationStatus.pending,
                createdAt: DateTime(2026, 9, 20, 18, 40),
                holdUntil: DateTime(2026, 9, 20, 19, 20),
              );

              service.reservations.add(confirmedReservation);

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservationSucessScreen(
                    service: service,
                    reservation: confirmedReservation,
                    restaurantName: r.name,
                    customerName: customerName,
                    customerPhone: customerPhone,
                    tableSeats: selectedTable.seats,
                    tableLocation: _locationDisplayName(selectedLocation),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  static String _locationDisplayName(TableLocation loc) {
    switch (loc) {
      case TableLocation.bar:
        return 'Bar';
      case TableLocation.window:
        return 'Window';
      case TableLocation.indoor:
        return 'Indoor';
      case TableLocation.outdoor:
        return 'Outdoor';
      case TableLocation.privateRoom:
        return 'Private Room';
    }
  }

  static IconData _locationIcon(TableLocation loc) {
    switch (loc) {
      case TableLocation.bar:
        return Icons.local_bar_outlined;
      case TableLocation.window:
        return Icons.window_outlined;
      case TableLocation.indoor:
        return Icons.chair_outlined;
      case TableLocation.outdoor:
        return Icons.deck_outlined;
      case TableLocation.privateRoom:
        return Icons.meeting_room_outlined;
    }
  }
}

class _LocationOptionPill extends StatelessWidget {
  final TableLocation location;
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _LocationOptionPill({
    required this.location,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFFF2F9F7) : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? const Color(0xFF166359)
                  : const Color(0xFFE5E7EB),
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected
                    ? const Color(0xFF166359)
                    : const Color(0xFF6B7280),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF166359)
                      : const Color(0xFF1E232A),
                ),
              ),
              if (isSelected) ...[
                const SizedBox(width: 6),
                const Icon(
                  Icons.check_circle,
                  size: 16,
                  color: Color(0xFF166359),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
