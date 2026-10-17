import 'package:flutter/material.dart' hide Table;
import 'package:flutter_test/flutter_test.dart';
import 'package:w3/model/customer.dart';
import 'package:w3/model/reservation.dart';
import 'package:w3/model/restaurant.dart';
import 'package:w3/model/table.dart';
import 'package:w3/model/time_slot.dart';
import 'package:w3/ui/screens/booking_screen.dart';
import 'package:w3/ui/screens/reservation_screen.dart';
import 'package:w3/ui/screens/restaurant_screen.dart';

class TestData {
  final customer = Customer(name: 'Vichea', phone: '012345678');
  final bistro = Restaurant(
    name: 'Bistro',
    type: 'French',
    openingHour: 10,
    closingHour: 22,
    tables: [
      Table(id: 1, seats: 4, location: TableLocation.indoor),
      Table(id: 4, seats: 2, location: TableLocation.bar),
    ],
  );
  late final restaurants = [bistro];
  late final reservations = [
    reservation('A', ReservationStatus.pending),
    reservation('B', ReservationStatus.cancelled),
    reservation('C', ReservationStatus.cancelled),
  ];

  Reservation reservation(String id, ReservationStatus status) {
    return Reservation(
      id: id,
      restaurant: bistro,
      table: bistro.tables[0],
      customer: customer,
      slot: TimeSlot(
        start: DateTime(2026, 9, 20, 19),
        end: DateTime(2026, 9, 20, 21),
      ),
      guest: 2,
      status: status,
    );
  }

  Widget app() {
    return MaterialApp(
      home: RestaurantScreen(
        restaurants: restaurants,
        reservations: reservations,
        customer: customer,
        now: DateTime(2026, 9, 20, 18, 40),
      ),
    );
  }
}

Future<void> openBooking(WidgetTester tester) async {
  await tester.tap(find.text('Bistro'));
  await tester.pumpAndSettle();
}

final nameField = find.widgetWithText(TextFormField, 'Customer name');
final phoneField = find.widgetWithText(TextFormField, 'Phone number');
Future<void> useTallScreen(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 2400);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

String? selectedLocation(WidgetTester tester) {
  for (final tile in tester.widgetList<LocationTile>(
    find.byType(LocationTile),
  )) {
    if (tile.isSelected) {
      return tile.location.label;
    }
  }
  return null;
}

final timeDropdown = find.byType(DropdownMenu<int>);

Future<void> pickTime(WidgetTester tester, String slot) async {
  await tester.tap(timeDropdown);
  await tester.pumpAndSettle();
  await tester.tap(find.text(slot).last);
  await tester.pumpAndSettle();
}

Future<void> pickDate(WidgetTester tester) async {
  await tester.tap(find.text('Date'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('OK'));
  await tester.pumpAndSettle();
}

Future<void> fillContact(WidgetTester tester) async {
  await tester.enterText(nameField, 'Sok Dara');
  await tester.enterText(phoneField, '012987654');
}

Future<void> chooseFilter(WidgetTester tester, String option) async {
  await tester.tap(find.byWidgetPredicate((w) => w is DropdownMenu));
  await tester.pumpAndSettle();
  await tester.tap(find.text(option).last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('restaurant filter reacts', (tester) async {
    final data = TestData();
    data.restaurants.add(
      Restaurant(
        name: 'Zen',
        type: 'Japanese',
        openingHour: 12,
        closingHour: 22,
        tables: [],
      ),
    );
    await tester.pumpWidget(data.app());
    expect(find.text('Bistro'), findsOneWidget);
    expect(find.text('Zen'), findsOneWidget);
    await chooseFilter(tester, 'Japanese');
    expect(find.text('Bistro'), findsNothing);
    expect(find.text('Zen'), findsOneWidget);
    await chooseFilter(tester, 'All');
    expect(find.text('Bistro'), findsOneWidget);
  });

  testWidgets('reservation filter reacts', (tester) async {
    final data = TestData();
    await tester.pumpWidget(data.app());
    await tester.tap(find.byTooltip('My reservations'));
    await tester.pumpAndSettle();
    expect(find.text('No reservations'), findsNothing);
    expect(find.text('Pending'), findsOneWidget);
    await chooseFilter(tester, 'Cancelled');
    expect(find.text('Pending'), findsNothing);
    expect(find.text('Cancelled'), findsNWidgets(3));
    await chooseFilter(tester, 'Seated');
    expect(find.text('No reservations'), findsOneWidget);
  });

  testWidgets('locations depend on the guest count', (tester) async {
    await useTallScreen(tester);
    final data = TestData();
    await tester.pumpWidget(data.app());
    await openBooking(tester);

    expect(find.text('1'), findsOneWidget);
    expect(selectedLocation(tester), isNull);
    await tester.tap(find.text('Bar'));
    await tester.pump();
    expect(selectedLocation(tester), 'Bar');
    await tester.tap(find.text('Window'));
    await tester.pump();
    expect(selectedLocation(tester), 'Bar');

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(selectedLocation(tester), 'Bar');

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);
    expect(selectedLocation(tester), isNull);
    await tester.tap(find.text('Bar'));
    await tester.pump();
    expect(selectedLocation(tester), isNull);
    await tester.tap(find.text('Indoor'));
    await tester.pump();
    expect(selectedLocation(tester), 'Indoor');

    for (var i = 0; i < 6; i++) {
      await tester.tap(find.byIcon(Icons.add));
      await tester.pump();
    }
    expect(find.text('9'), findsOneWidget);
    expect(selectedLocation(tester), 'Indoor');
    await tester.tap(find.text('Bar'));
    await tester.pump();
    expect(selectedLocation(tester), 'Indoor');

    for (var i = 0; i < 10; i++) {
      await tester.tap(find.byIcon(Icons.remove));
      await tester.pump();
    }
    expect(find.text('1'), findsOneWidget);
    await tester.tap(find.text('Bar'));
    await tester.pump();
    expect(selectedLocation(tester), 'Bar');
  });

  testWidgets('the form shows an error under every invalid field', (
    tester,
  ) async {
    await useTallScreen(tester);
    final data = TestData();
    await tester.pumpWidget(data.app());
    await openBooking(tester);

    await tester.enterText(phoneField, '12');
    await tester.tap(find.text('Reserve Table'));
    await tester.pump();

    expect(find.text('Enter your name'), findsOneWidget);
    expect(
      find.text('Phone number must have at least 8 digits'),
      findsOneWidget,
    );
    expect(find.text('Choose a date'), findsOneWidget);
    expect(find.text('Choose a time'), findsOneWidget);
    expect(find.text('Choose a table location'), findsOneWidget);
  });

  testWidgets('phone with letters shows an error on reserve', (tester) async {
    await useTallScreen(tester);
    final data = TestData();
    await tester.pumpWidget(data.app());
    await openBooking(tester);

    await tester.enterText(phoneField, '012abc');
    await tester.tap(find.text('Reserve Table'));
    await tester.pump();
    expect(find.text('Phone number can only have numbers'), findsOneWidget);

    await tester.enterText(phoneField, '012345678');
    await tester.tap(find.text('Reserve Table'));
    await tester.pump();
    expect(find.text('Phone number can only have numbers'), findsNothing);
  });

  testWidgets('time options stay in opening hours', (tester) async {
    await useTallScreen(tester);
    final data = TestData();
    await tester.pumpWidget(data.app());
    await openBooking(tester);

    await tester.tap(timeDropdown);
    await tester.pumpAndSettle();

    expect(find.text('10:00 - 12:00'), findsOneWidget);
    expect(find.text('20:00 - 22:00'), findsOneWidget);
    expect(find.text('22:00 - 24:00'), findsNothing);
    expect(find.text('11:00 - 13:00'), findsNothing);
  });

  testWidgets('a time that already passed today is rejected', (tester) async {
    await useTallScreen(tester);
    final data = TestData();
    await tester.pumpWidget(data.app());
    await openBooking(tester);

    await pickDate(tester);
    await pickTime(tester, '18:00 - 20:00');
    await tester.tap(find.text('Reserve Table'));
    await tester.pumpAndSettle();
    expect(find.text('Choose a time in the future'), findsOneWidget);
  });

  testWidgets('a taken table shows an error and keeps the form open', (
    tester,
  ) async {
    await useTallScreen(tester);
    final data = TestData();
    await tester.pumpWidget(data.app());
    await openBooking(tester);

    await fillContact(tester);
    await pickDate(tester);
    await pickTime(tester, '20:00 - 22:00');
    await tester.tap(find.text('Indoor'));
    await tester.pump();
    await tester.tap(find.text('Reserve Table'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No free Indoor table'), findsOneWidget);
    expect(find.text('Reserve at Bistro'), findsOneWidget);
    expect(data.reservations.length, 3);
  });

  testWidgets('a valid form creates a reservation and shows it', (
    tester,
  ) async {
    await useTallScreen(tester);
    final data = TestData();
    await tester.pumpWidget(data.app());
    await openBooking(tester);

    await fillContact(tester);
    await pickDate(tester);
    await pickTime(tester, '20:00 - 22:00');
    await tester.tap(find.text('Bar'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Special request (optional)'),
      'Window view',
    );
    await tester.pump();
    await tester.tap(find.text('Reserve Table'));
    await tester.pumpAndSettle();

    final created = data.reservations.last;
    expect(data.reservations.length, 4);
    expect(created.id, 'RES-04');
    expect(created.table.id, 4);
    expect(created.guest, 1);
    expect(created.specialRequest, 'Window view');
    expect(created.slot.start, DateTime(2026, 9, 20, 20));
    expect(created.slot.end, DateTime(2026, 9, 20, 22));
    expect(data.customer.name, 'Sok Dara');
    expect(data.customer.phone, '012987654');

    expect(find.text('Reserve at Bistro'), findsNothing);
    expect(find.byType(ReservationTile), findsNWidgets(4));
  });
}
