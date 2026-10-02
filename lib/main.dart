import 'package:flutter/material.dart' hide Table;

import 'model/reservation.dart';
import 'model/table.dart';
import 'model/time_slot.dart';
import 'service/reservation_service.dart';
import 'service/restaurant_service.dart';
import 'ui/screens/booking_screen.dart';
import 'ui/screens/home_screen.dart';
import 'ui/screens/reservation_screen.dart';
import 'ui/widgets/theme.dart';

void main() {
  final service = RestaurantService();
  final reservationService = ReservationService(
    service,
    now: () => DateTime(2026, 9, 20, 18, 40),
  );

  service.addRestaurant(
    restaurantId: 'RST1',
    name: 'The Bistro Gourmet',
    type: 'French',
    openingHour: 11,
    closingHour: 23,
    maxLateMinutes: 20,
  );
  service.addRestaurant(
    restaurantId: 'RST2',
    name: 'Zen Japanese Dining',
    type: 'Japanese',
    openingHour: 12,
    closingHour: 23,
    maxLateMinutes: 15,
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
    location: TableLocation.bar,
  );
  service.addTable(
    restaurantId: 'RST1',
    tableId: 3,
    seats: 2,
    location: TableLocation.window,
  );
  service.addTable(
    restaurantId: 'RST1',
    tableId: 4,
    seats: 4,
    location: TableLocation.outdoor,
  );
  service.addTable(
    restaurantId: 'RST1',
    tableId: 5,
    seats: 6,
    location: TableLocation.privateRoom,
  );
  service.addTable(
    restaurantId: 'RST1',
    tableId: 6,
    seats: 2,
    location: TableLocation.indoor,
  );
  service.addTable(
    restaurantId: 'RST1',
    tableId: 7,
    seats: 4,
    location: TableLocation.bar,
  );

  service.addTable(
    restaurantId: 'RST2',
    tableId: 101,
    seats: 4,
    location: TableLocation.indoor,
  );

  service.addCustomer(customerId: 'C103', name: 'Vichea', phone: '012345678');

  reservationService.reservations.addAll([
    Reservation(
      id: 'RES-01',
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
      id: 'RES-02',
      restaurantId: 'RST2',
      customerId: 'C103',
      tableId: 101,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 12, 0),
        end: DateTime(2026, 9, 20, 14, 0),
      ),
      guest: 2,
      status: ReservationStatus.completed,
      createdAt: DateTime(2026, 9, 16, 10, 0),
      holdUntil: DateTime(2026, 9, 20, 12, 20),
    ),
  ]);

  runApp(RestaurantApp(service: service, reservationService: reservationService));
}

class RestaurantApp extends StatelessWidget {
  final RestaurantService service;
  final ReservationService reservationService;
  final int initialTabIndex;
  final String customerId;

  const RestaurantApp({
    super.key,
    required this.service,
    required this.reservationService,
    this.initialTabIndex = 0,
    this.customerId = 'C103',
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Restaurant Reservation System',
      debugShowCheckedModeBanner: false,
      theme: appTheme,
      home: AppNavigationBar(
        service: service,
        reservationService: reservationService,
        initialTabIndex: initialTabIndex,
        customerId: customerId,
      ),
    );
  }
}

class AppNavigationBar extends StatelessWidget {
  final RestaurantService service;
  final ReservationService reservationService;
  final int initialTabIndex;
  final String customerId;

  const AppNavigationBar({
    super.key,
    required this.service,
    required this.reservationService,
    required this.initialTabIndex,
    required this.customerId,
  });

  @override
  Widget build(BuildContext context) {
    final customer = service.getCustomer(customerId);

    return DefaultTabController(
      length: 3,
      animationDuration: Duration.zero,
      initialIndex: initialTabIndex,
      child: Scaffold(
        body: TabBarView(
          physics: const NeverScrollableScrollPhysics(),
          children: [
            HomeScreen(service: service),
            BookingScreen(service: service, customer: customer),
            ReservationScreen(
              service: service,
              reservationService: reservationService,
              customerId: customerId,
            ),
          ],
        ),
        bottomNavigationBar: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
          ),
          child: const TabBar(
            labelColor: AppColors.teal,
            unselectedLabelColor: AppColors.hint,
            indicatorColor: AppColors.teal,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.w600, fontSize: 11),
            tabs: [
              Tab(icon: Icon(Icons.restaurant_outlined), text: 'Home'),
              Tab(icon: Icon(Icons.add_circle_outline), text: 'Booking'),
              Tab(
                icon: Icon(Icons.calendar_today_outlined),
                text: 'Reservation',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
