import 'package:flutter/material.dart' hide Table;

import 'model/customer.dart';
import 'model/reservation.dart';
import 'model/restaurant.dart';
import 'model/table.dart';
import 'model/time_slot.dart';
import 'ui/screens/restaurant/restaurant_screen.dart';
import 'ui/widgets/theme.dart';

void main() {
  final bistro = Restaurant(
    name: 'The Bistro Gourmet',
    type: 'French',
    openingHour: 10,
    closingHour: 22,
    tables: [
      Table(id: 1, seats: 4, location: TableLocation.indoor),
      Table(id: 2, seats: 2, location: TableLocation.bar),
      Table(id: 3, seats: 2, location: TableLocation.window),
      Table(id: 4, seats: 4, location: TableLocation.outdoor),
      Table(id: 5, seats: 6, location: TableLocation.privateRoom),
      Table(id: 6, seats: 2, location: TableLocation.indoor),
      Table(id: 7, seats: 4, location: TableLocation.bar),
    ],
  );
  final zen = Restaurant(
    name: 'Zen Japanese Dining',
    type: 'Japanese',
    openingHour: 12,
    closingHour: 22,
    tables: [Table(id: 101, seats: 4, location: TableLocation.indoor)],
  );

  final customer = Customer(name: 'Vichea', phone: '012345678');

  final reservations = [
    Reservation(
      id: 'RES-01',
      restaurant: bistro,
      table: bistro.tables[0],
      customer: customer,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 20),
        end: DateTime(2026, 9, 20, 22),
      ),
      guest: 3,
      specialRequest: 'Birthday cake at dessert',
    ),
    Reservation(
      id: 'RES-02',
      restaurant: zen,
      table: zen.tables[0],
      customer: customer,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 12),
        end: DateTime(2026, 9, 20, 14),
      ),
      guest: 2,
      status: ReservationStatus.completed,
    ),
  ];

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: RestaurantScreen(
        restaurants: [bistro, zen],
        reservations: reservations,
        customer: customer,
        now: DateTime(2026, 9, 20, 18, 40),
      ),
    ),
  );
}
