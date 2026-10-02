import 'package:flutter/material.dart' hide Table;

import '../../model/customer.dart';
import '../../model/reservation.dart';
import '../../service/restaurant_service.dart';
import '../../model/table.dart';
import '../widgets/theme.dart';
import '../widgets/guest_stepper.dart';
import '../widgets/info_field.dart';
import '../widgets/primary_button.dart';

class BookingScreen extends StatefulWidget {
  final RestaurantService service;
  final Customer customer;

  const BookingScreen({
    super.key,
    required this.service,
    required this.customer,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  TableLocation? selectedLocation = TableLocation.bar;
  int guestCount = 2;

  bool get canMinus => guestCount > Reservation.minGuests;

  bool canUse(TableLocation location) {
    return widget.service.hasTableForLocation(
      location: location,
      guest: guestCount,
    );
  }

  void changeGuest(int newCount) {
    setState(() {
      guestCount = newCount;
      if (selectedLocation != null && !canUse(selectedLocation!)) {
        selectedLocation = null;
      }
    });
  }

  void onMinus() {
    changeGuest(guestCount - 1);
  }

  void onAdd() {
    changeGuest(guestCount + 1);
  }

  void onLocationSelected(TableLocation location) {
    setState(() {
      selectedLocation = location;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text(
              'New reservation',
              style: TextStyle(
                fontSize: 22,
                color: AppColors.text,
              ),
            ),
            Text(
              widget.service.restaurant.name,
              style: const TextStyle(fontSize: 12, color: AppColors.textLight),
            ),
          ],
        ),
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
                  value: widget.customer.name,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoField(
                  label: 'Phone number',
                  icon: Icons.phone_outlined,
                  value: widget.customer.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: InfoField(
                  label: 'Date',
                  icon: Icons.calendar_today_outlined,
                  value: 'Sat 20 Sep',
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.hint,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoField(
                  label: 'Time',
                  icon: Icons.access_time,
                  value: '19:00 - 21:00',
                  trailing: const Icon(
                    Icons.keyboard_arrow_down,
                    size: 18,
                    color: AppColors.hint,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          GuestStepper(
            guestCount: guestCount,
            canMinus: canMinus,
            onMinus: onMinus,
            onAdd: onAdd,
          ),
          const SizedBox(height: 16),

          const Text(
            'Special request',
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textMedium,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'Birthday cake at dessert',
              style: TextStyle(fontSize: 14, color: AppColors.text),
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'Table location',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.text,
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
                  label: _locationDisplayName(loc),
                  isSelected: loc == selectedLocation,
                  isEnabled: canUse(loc),
                  onSelected: () => onLocationSelected(loc),
                ),
            ],
          ),

          const SizedBox(height: 28),

          PrimaryButton(
            text: selectedLocation == null
                ? 'Reserve Table'
                : 'Reserve Table · ${_locationDisplayName(selectedLocation!)}',
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
}

class _LocationOptionPill extends StatelessWidget {
  final String label;
  final bool isSelected;
  final bool isEnabled;
  final VoidCallback onSelected;

  const _LocationOptionPill({
    required this.label,
    required this.isSelected,
    required this.isEnabled,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: isEnabled ? 1 : 0.4,
      child: InkWell(
        onTap: isEnabled ? onSelected : null,
        hoverColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.tealLight : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? AppColors.teal : AppColors.border,
              width: isSelected ? 1.5 : 1.0,
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.teal : AppColors.text,
            ),
          ),
        ),
      ),
    );
  }
}
