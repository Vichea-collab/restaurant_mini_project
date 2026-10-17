import 'package:flutter/material.dart' hide Table;

import '../../model/customer.dart';
import '../../model/reservation.dart';
import '../../model/restaurant.dart';
import '../../model/table.dart';
import '../../model/time_slot.dart';
import '../widgets/theme.dart';
import '../widgets/app_button.dart';

class BookingScreen extends StatefulWidget {
  final Restaurant restaurant;
  final List<Reservation> reservations;
  final Customer customer;
  final DateTime? now;

  const BookingScreen({
    super.key,
    required this.restaurant,
    required this.reservations,
    required this.customer,
    this.now,
  });

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dateController = TextEditingController();
  final _requestController = TextEditingController();

  DateTime? selectedDate;
  int? selectedHour;
  TableLocation? selectedLocation;
  int guestCount = Reservation.minGuests;
  String? locationError;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dateController.dispose();
    _requestController.dispose();
    super.dispose();
  }

  Restaurant get restaurant => widget.restaurant;

  DateTime get now => widget.now ?? DateTime.now();

  int get visitHours => Reservation.visitHours;

  List<int> get startHours {
    List<int> hours = [];
    int hour = restaurant.openingHour;
    while (hour + visitHours <= restaurant.closingHour) {
      hours.add(hour);
      hour += visitHours;
    }
    return hours;
  }

  DateTime startAt(int hour) {
    DateTime date = selectedDate!;
    return DateTime(date.year, date.month, date.day, hour);
  }

  bool canUse(TableLocation location) {
    for (Table table in restaurant.tables) {
      if (table.location == location && table.canSeat(guestCount)) {
        return true;
      }
    }
    return false;
  }

  bool isTableFree(Table table, TimeSlot slot) {
    for (Reservation reservation in widget.reservations) {
      if (reservation.table == table &&
          reservation.holdsTable &&
          reservation.slot.overlaps(slot)) {
        return false;
      }
    }
    return true;
  }

  String? validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Enter your name';
    }
    return null;
  }

  String? validatePhone(String? value) {
    if (value != null && value.isNotEmpty && int.tryParse(value) == null) {
      return 'Phone number can only have numbers';
    }
    if (value == null || value.length < 8) {
      return 'Phone number must have at least 8 digits';
    }
    return null;
  }

  String? validateDate(String? value) {
    if (value == null || value.isEmpty) {
      return 'Choose a date';
    }
    return null;
  }

  String? validateTime(int? hour) {
    if (hour == null) {
      return 'Choose a time';
    }
    if (selectedDate != null && !startAt(hour).isAfter(now)) {
      return 'Choose a time in the future';
    }
    return null;
  }

  void onPickDate() async {
    DateTime today = DateTime(now.year, now.month, now.day);
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? today,
      firstDate: today,
      lastDate: today.add(const Duration(days: 60)),
    );

    if (picked != null) {
      selectedDate = picked;
      _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }

  void onGuestChanged(int newCount) {
    setState(() {
      guestCount = newCount;
      if (selectedLocation != null && !canUse(selectedLocation!)) {
        selectedLocation = null;
      }
    });
  }

  void onLocationSelected(TableLocation location) {
    setState(() {
      selectedLocation = location;
      locationError = null;
    });
  }

  Table? findTable(TimeSlot slot) {
    Table? best;
    for (Table table in restaurant.tables) {
      bool fits =
          table.location == selectedLocation && table.canSeat(guestCount);
      if (!fits || !isTableFree(table, slot)) {
        continue;
      }
      if (best == null || table.seats < best.seats) {
        best = table;
      }
    }
    return best;
  }

  void onReserve() {
    setState(() {
      locationError = selectedLocation == null
          ? 'Choose a table location'
          : null;
    });
    if (!_formKey.currentState!.validate() || selectedLocation == null) {
      return;
    }

    DateTime start = startAt(selectedHour!);
    TimeSlot slot = TimeSlot(
      start: start,
      end: start.add(Duration(hours: visitHours)),
    );
    Table? table = findTable(slot);
    if (table == null) {
      setState(() {
        locationError =
            'No free ${selectedLocation!.label} table at '
            '${start.hour}:00. Try another time or location.';
      });
      return;
    }

    widget.customer.name = _nameController.text.trim();
    widget.customer.phone = _phoneController.text;

    String request = _requestController.text.trim();
    Reservation reservation = Reservation(
      id: 'RES-${(widget.reservations.length + 1).toString().padLeft(2, '0')}',
      restaurant: restaurant,
      table: table,
      customer: widget.customer,
      slot: slot,
      guest: guestCount,
      specialRequest: request.isEmpty ? null : request,
    );

    Navigator.pop<Reservation>(context, reservation);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Reserve at ${restaurant.name}')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                validator: validateName,
                controller: _nameController,
                maxLength: 50,
                decoration: const InputDecoration(label: Text('Customer name')),
              ),
              TextFormField(
                validator: validatePhone,
                controller: _phoneController,
                maxLength: 12,
                decoration: const InputDecoration(label: Text('Phone number')),
              ),
              TextFormField(
                validator: validateDate,
                controller: _dateController,
                readOnly: true,
                onTap: onPickDate,
                decoration: const InputDecoration(
                  label: Text('Date'),
                  suffixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),
              const SizedBox(height: 10),
              FormField<int>(
                validator: validateTime,
                builder: (field) => DropdownMenu<int>(
                  label: const Text('Time'),
                  expandedInsets: EdgeInsets.zero,
                  requestFocusOnTap: false,
                  errorText: field.errorText,
                  inputDecorationTheme: const InputDecorationTheme(
                    border: UnderlineInputBorder(),
                  ),
                  onSelected: (hour) {
                    selectedHour = hour;
                    field.didChange(hour);
                  },
                  dropdownMenuEntries: [
                    for (final hour in startHours)
                      DropdownMenuEntry(
                        value: hour,
                        label: '$hour:00 - ${hour + visitHours}:00',
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              GuestTile(
                guestCount: guestCount,
                canMinus: guestCount > Reservation.minGuests,
                onMinus: () => onGuestChanged(guestCount - 1),
                onAdd: () => onGuestChanged(guestCount + 1),
              ),
              TextFormField(
                controller: _requestController,
                maxLength: 100,
                decoration: const InputDecoration(
                  label: Text('Special request (optional)'),
                ),
              ),
              const SizedBox(height: 10),
              const Text('Table location'),
              for (final location in TableLocation.values)
                LocationTile(
                  location: location,
                  isSelected: location == selectedLocation,
                  isEnabled: canUse(location),
                  onSelected: onLocationSelected,
                ),
              if (locationError != null)
                Text(
                  locationError!,
                  style: const TextStyle(color: AppColors.red),
                ),
              const SizedBox(height: 20),
              AppButton(text: 'Reserve Table', onPressed: onReserve),
            ],
          ),
        ),
      ),
    );
  }
}

class GuestTile extends StatelessWidget {
  final int guestCount;
  final bool canMinus;
  final VoidCallback onMinus;
  final VoidCallback onAdd;

  const GuestTile({
    super.key,
    required this.guestCount,
    required this.canMinus,
    required this.onMinus,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Guests'),
        const Spacer(),
        IconButton(
          onPressed: canMinus ? onMinus : null,
          icon: const Icon(Icons.remove),
        ),
        Text('$guestCount'),
        IconButton(onPressed: onAdd, icon: const Icon(Icons.add)),
      ],
    );
  }
}

class LocationTile extends StatelessWidget {
  final TableLocation location;
  final bool isSelected;
  final bool isEnabled;
  final ValueChanged<TableLocation> onSelected;

  const LocationTile({
    super.key,
    required this.location,
    required this.isSelected,
    required this.isEnabled,
    required this.onSelected,
  });

  Color get backgroundColor =>
      isSelected ? AppColors.teal.withAlpha(100) : Colors.grey[200]!;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        enabled: isEnabled,
        onTap: () => onSelected(location),
        title: Text(location.label),
      ),
    );
  }
}
