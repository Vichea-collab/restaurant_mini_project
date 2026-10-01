import 'package:flutter/material.dart' hide Table;
import 'package:flutter_test/flutter_test.dart';
import 'package:w3/main.dart';
import 'package:w3/model/reservation.dart';
import 'package:w3/model/table.dart';
import 'package:w3/model/time_slot.dart';
import 'package:w3/service/restaurant_service.dart';
import 'package:w3/ui/widgets/filter_bar.dart';

void addReservation(RestaurantService s, String id, ReservationStatus status) {
  s.reservations.add(
    Reservation(
      id: id,
      restaurantId: 'RST1',
      customerId: 'C103',
      tableId: 1,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 19),
        end: DateTime(2026, 9, 20, 21),
      ),
      guest: 2,
      status: status,
      createdAt: DateTime(2026, 9, 16),
      holdUntil: DateTime(2026, 9, 20, 19, 20),
    ),
  );
}

RestaurantService buildService() {
  final s = RestaurantService(now: () => DateTime(2026, 9, 20, 18, 40));
  s.addRestaurant(
    restaurantId: 'RST1',
    name: 'Bistro',
    type: 'French',
    openingHour: 11,
    closingHour: 23,
  );
  s.addTable(
    restaurantId: 'RST1',
    tableId: 1,
    seats: 4,
    location: TableLocation.indoor,
  );
  s.addTable(
    restaurantId: 'RST1',
    tableId: 4,
    seats: 2,
    location: TableLocation.bar,
  );
  s.addCustomer(customerId: 'C103', name: 'Vichea', phone: '012');
  addReservation(s, 'A', ReservationStatus.pending);
  addReservation(s, 'B', ReservationStatus.cancelled);
  addReservation(s, 'C', ReservationStatus.cancelled);
  return s;
}

Future<void> openBooking(WidgetTester tester) async {
  await tester.tap(find.byIcon(Icons.add_circle_outline));
  await tester.pumpAndSettle();
}

Future<void> chooseFilter(WidgetTester tester, String option) async {
  final pill = find.descendant(
    of: find.byType(FilterBar),
    matching: find.text(option),
  );
  await tester.tap(pill);
  await tester.pump();
}

void main() {
  testWidgets('home filter reacts', (tester) async {
    final service = buildService();
    service.addRestaurant(
      restaurantId: 'RST2',
      name: 'Zen',
      type: 'Japanese',
      openingHour: 12,
      closingHour: 23,
    );
    await tester.pumpWidget(RestaurantApp(service: service));
    expect(find.text('Bistro'), findsOneWidget);
    expect(find.text('Zen'), findsOneWidget);
    await chooseFilter(tester, 'Japanese');
    expect(find.text('Bistro'), findsNothing);
    expect(find.text('Zen'), findsOneWidget);
    await chooseFilter(tester, 'All');
    expect(find.text('Bistro'), findsOneWidget);
  });

  testWidgets('reservation filter reacts', (tester) async {
    await tester.pumpWidget(
      RestaurantApp(service: buildService(), initialTabIndex: 2),
    );
    expect(find.text('No reservations'), findsNothing);
    expect(find.text('Pending'), findsNWidgets(2)); // pill + card badge
    await chooseFilter(tester, 'Cancelled');
    expect(find.text('Pending'), findsOneWidget); // only the pill now
    expect(find.text('Cancelled'), findsNWidgets(3)); // pill + 2 cards
    await chooseFilter(tester, 'Seated');
    expect(find.text('No reservations'), findsOneWidget);
  });

  testWidgets('locations depend on the guest count', (tester) async {
    tester.view.physicalSize = const Size(800, 2400);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(RestaurantApp(service: buildService()));
    await openBooking(tester);

    // 2 guests: bar (2 seats) is selected
    expect(find.text('Reserve Table · Bar'), findsOneWidget);
    await tester.tap(find.text('Window')); // no window table: disabled
    await tester.pump();
    expect(find.text('Reserve Table · Bar'), findsOneWidget);

    // 3 guests: the bar is too small, so the selection is cleared
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(find.text('Reserve Table'), findsOneWidget);
    await tester.tap(find.text('Bar')); // disabled
    await tester.pump();
    expect(find.text('Reserve Table'), findsOneWidget);
    await tester.tap(find.text('Indoor')); // 4 seats: enabled
    await tester.pump();
    expect(find.text('Reserve Table · Indoor'), findsOneWidget);

    // indoor has no guest limit, so + never stops
    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }
    expect(find.text('9'), findsOneWidget);
    expect(find.text('Reserve Table · Indoor'), findsOneWidget);
    await tester.tap(find.text('Bar')); // bar has a limit: still disabled
    await tester.pump();
    expect(find.text('Reserve Table · Indoor'), findsOneWidget);

    // back to 1 guest: the bar works again, and 1 is the minimum
    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
    }
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.text('Bar'));
    await tester.pump();
    expect(find.text('Reserve Table · Bar'), findsOneWidget);
  });
}
