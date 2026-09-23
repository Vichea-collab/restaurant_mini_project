import 'package:flutter/material.dart' hide Table;

import 'model/reservation.dart';
import 'model/table.dart';
import 'model/time_slot.dart';
import 'service/restaurant_service.dart';
import 'ui/screens/booking_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/reservation_sucess_screen.dart';
import 'ui/screens/reservations_screen.dart';

void main() {
  final service = RestaurantService(now: () => DateTime(2026, 9, 20, 18, 40));

  service.addRestaurant(
    restaurantId: 'RST1',
    name: 'The Bistro Gourmet',
    openingHour: 11,
    closingHour: 23,
    maxLateMinutes: 20,
  );
  service.addRestaurant(
    restaurantId: 'RST2',
    name: 'Zen Japanese Dining',
    openingHour: 12,
    closingHour: 23,
    maxLateMinutes: 15,
  );
  service.addRestaurant(
    restaurantId: 'RST3',
    name: 'Bella Italia Trattoria',
    openingHour: 10,
    closingHour: 22,
    maxLateMinutes: 20,
  );

  service.addTable(
    restaurantId: 'RST1',
    tableId: 1,
    seats: 4,
    location: TableLocation.indoor,
  );
  service.addTable(
    restaurantId: 'RST1',
    tableId: 2,
    seats: 2,
    location: TableLocation.window,
  );
  service.addTable(
    restaurantId: 'RST1',
    tableId: 3,
    seats: 6,
    location: TableLocation.privateRoom,
  );
  service.addTable(
    restaurantId: 'RST1',
    tableId: 4,
    seats: 2,
    location: TableLocation.bar,
  );

  service.addTable(
    restaurantId: 'RST2',
    tableId: 101,
    seats: 2,
    location: TableLocation.bar,
  );
  service.addTable(
    restaurantId: 'RST2',
    tableId: 102,
    seats: 4,
    location: TableLocation.indoor,
  );
  service.addTable(
    restaurantId: 'RST3',
    tableId: 201,
    seats: 4,
    location: TableLocation.outdoor,
  );

  service.addCustomer(
    customerId: 'C101',
    name: 'Bob Chan',
    phone: '012-345-001',
  );
  service.addCustomer(
    customerId: 'C102',
    name: 'Dara Sok',
    phone: '012-345-002',
  );
  service.addCustomer(customerId: 'C103', name: 'Vichea', phone: '012345678');
  service.addCustomer(
    customerId: 'C104',
    name: 'Mina Park',
    phone: '012-345-004',
  );
  service.addCustomer(
    customerId: 'C105',
    name: 'Ken Ito',
    phone: '012-345-005',
  );

  service.reservations.addAll([
    Reservation(
      id: 'RES-01',
      restaurantId: 'RST1',
      customerId: 'C103',
      tableId: 2,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 12, 0),
        end: DateTime(2026, 9, 20, 14, 0),
      ),
      guest: 2,
      status: ReservationStatus.completed,
      createdAt: DateTime(2026, 9, 16, 10, 0),
      holdUntil: DateTime(2026, 9, 20, 12, 20),
    ),

    Reservation(
      id: 'RES-02',
      restaurantId: 'RST2',
      customerId: 'C103',
      tableId: 102,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 18, 30),
        end: DateTime(2026, 9, 20, 20, 30),
      ),
      guest: 4,
      status: ReservationStatus.pending,
      createdAt: DateTime(2026, 9, 16, 11, 30),
      holdUntil: DateTime(2026, 9, 20, 18, 50),
    ),

    Reservation(
      id: 'RES-03',
      restaurantId: 'RST1',
      customerId: 'C103',
      tableId: 1,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 19, 0),
        end: DateTime(2026, 9, 20, 21, 0),
      ),
      guest: 3,
      specialRequest: 'Birthday cake at dessert',
      status: ReservationStatus.pending,
      createdAt: DateTime(2026, 9, 16, 14, 2),
      holdUntil: DateTime(2026, 9, 20, 19, 20),
    ),

    Reservation(
      id: 'RES-04',
      restaurantId: 'RST3',
      customerId: 'C103',
      tableId: 201,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 19, 30),
        end: DateTime(2026, 9, 20, 21, 30),
      ),
      guest: 2,
      status: ReservationStatus.seated,
      createdAt: DateTime(2026, 9, 16, 15, 0),
      holdUntil: DateTime(2026, 9, 20, 19, 50),
    ),

    Reservation(
      id: 'RES-05',
      restaurantId: 'RST1',
      customerId: 'C103',
      tableId: 4,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 20, 30),
        end: DateTime(2026, 9, 20, 22, 30),
      ),
      guest: 2,
      status: ReservationStatus.noShow,
      createdAt: DateTime(2026, 9, 16, 16, 45),
      holdUntil: DateTime(2026, 9, 20, 20, 50),
    ),

    Reservation(
      id: 'RES-06',
      restaurantId: 'RST1',
      customerId: 'C103',
      tableId: 3,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 21, 0),
        end: DateTime(2026, 9, 20, 23, 0),
      ),
      guest: 2,
      status: ReservationStatus.cancelled,
      createdAt: DateTime(2026, 9, 16, 17, 0),
      holdUntil: DateTime(2026, 9, 20, 21, 20),
    ),
  ]);

  service.restaurants
          .firstWhere((r) => r.id == 'RST3')
          .tables
          .firstWhere((t) => t.id == 201)
          .status =
      TableStatus.occupied;

  runApp(RestaurantApp(service: service));
}

class RestaurantApp extends StatelessWidget {
  final RestaurantService service;
  final int initialTabIndex;
  final String customerId;

  const RestaurantApp({
    super.key,
    required this.service,
    this.initialTabIndex = 0,
    this.customerId = 'C103',
  });

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF166359);

    return MaterialApp(
      title: 'Restaurant Reservation System',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryTeal,
          primary: primaryTeal,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8F8),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1E232A),
          elevation: 0,
        ),
      ),
      home: AppNavigationBar(
        service: service,
        initialTabIndex: initialTabIndex,
        customerId: customerId,
      ),
    );
  }
}

class AppNavigationBar extends StatelessWidget {
  final RestaurantService service;
  final int initialTabIndex;
  final String customerId;

  const AppNavigationBar({
    super.key,
    required this.service,
    this.initialTabIndex = 0,
    this.customerId = 'C103',
  });

  @override
  Widget build(BuildContext context) {
    const primaryTeal = Color(0xFF166359);
    final customer = service.getCustomer(customerId);
    final reservation = service.getReservationForCustomer(customerId);

    return DefaultTabController(
      length: 4,
      initialIndex: initialTabIndex,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(restaurants: service.restaurants),
            BookingScreen(restaurant: service.restaurant, customer: customer),
            ReservationsScreen(
              reservations: service.getReservationsForCustomer(
                customerId: customerId,
              ),
              getRestaurantName: service.getRestaurantName,
              getTableLocationName: service.getTableLocationName,
            ),
            ReservationSucessScreen(
              reservation: reservation,
              restaurantName: service.getRestaurantName(
                reservation.restaurantId,
              ),
              tableLocation: service.getTableLocationName(
                reservation.restaurantId,
                reservation.tableId,
              ),
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
          ),
          child: const TabBar(
            labelColor: primaryTeal,
            unselectedLabelColor: Color(0xFF9CA3AF),
            indicatorColor: primaryTeal,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            tabs: [
              Tab(icon: Icon(Icons.restaurant_outlined), text: 'Home'),
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Booking'),
              Tab(icon: Icon(Icons.calendar_today_outlined), text: 'History'),
              Tab(icon: Icon(Icons.check_circle_outline), text: 'Success'),
            ],
          ),
        ),
      ),
    );
  }
}
