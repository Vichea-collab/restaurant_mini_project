import 'package:test/test.dart';
import 'package:w3/model/reservation.dart';
import 'package:w3/model/table.dart';
import 'package:w3/service/restaurant_service.dart';

RestaurantService newService({DateTime Function()? now}) {
  final service = RestaurantService(
    restaurantName: 'Bistro',
    openingHour: 11,
    closingHour: 22,
    maxLateMinutes: 20,
    now: now ?? () => dinner.subtract(const Duration(hours: 1)),
  );
  service.addTable(tableId: 1, seats: 4, location: TableLocation.indoor);
  service.addTable(tableId: 2, seats: 2, location: TableLocation.window);
  service.addCustomer(customerId: 'C1', name: 'Alice', phone: '555-0100');
  return service;
}

final dinner = DateTime(2026, 9, 20, 19, 0);

void main() {
  test('adds a table', () {
    final service = newService();

    expect(service.tables.length, 2);
    expect(service.tables.first.seats, 4);
    expect(service.tables.first.status, TableStatus.available);
  });

  test('rejects a duplicate table id', () {
    final service = newService();

    expect(() => service.addTable(tableId: 1, seats: 6), throwsException);
  });

  test('adds a customer', () {
    final service = newService();

    expect(service.customers.length, 1);
    expect(service.customers.first.name, 'Alice');
  });

  test('rejects a duplicate customer id', () {
    final service = newService();

    expect(
      () => service.addCustomer(customerId: 'C1', name: 'Bob', phone: '1'),
      throwsException,
    );
  });

  test('makes a pending reservation with the default duration', () {
    final service = newService();

    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 3,
    );

    final r = service.reservations.single;
    expect(r.status, ReservationStatus.pending);
    expect(r.customerId, 'C1');
    expect(r.tableId, 1);
    expect(r.slot.start, dinner);
    expect(r.slot.end, dinner.add(const Duration(minutes: 90)));
    expect(r.holdUntil, dinner.add(const Duration(minutes: 20)));
    expect(r.guest, 3);
  });

  test('stores a custom duration and special request', () {
    final service = newService();

    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
      durationMinutes: 120,
      specialRequest: 'Birthday cake',
    );

    final r = service.reservations.single;
    expect(r.slot.end, dinner.add(const Duration(minutes: 120)));
    expect(r.specialRequest, 'Birthday cake');
  });

  test('rejects a duplicate reservation id', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    expect(
      () => service.makeReservation(
        reservationId: 'R1',
        customerId: 'C1',
        tableId: 2,
        start: dinner,
        guest: 2,
      ),
      throwsException,
    );
  });

  test('rejects a reservation for an unknown customer', () {
    final service = newService();

    expect(
      () => service.makeReservation(
        reservationId: 'R1',
        customerId: 'NOBODY',
        tableId: 1,
        start: dinner,
        guest: 2,
      ),
      throwsException,
    );
  });

  test('rejects a party larger than table seats', () {
    final service = newService();

    expect(
      () => service.makeReservation(
        reservationId: 'R1',
        customerId: 'C1',
        tableId: 2,
        start: dinner,
        guest: 3,
      ),
      throwsException,
    );
  });

  test('rejects a reservation outside opening hours', () {
    final service = newService();

    expect(
      () => service.makeReservation(
        reservationId: 'R1',
        customerId: 'C1',
        tableId: 1,
        start: DateTime(2026, 9, 20, 21, 30),
        guest: 2,
      ),
      throwsException,
    );
  });

  test('rejects an overlapping reservation on the same table', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    expect(
      () => service.makeReservation(
        reservationId: 'R2',
        customerId: 'C1',
        tableId: 1,
        start: dinner.add(const Duration(minutes: 30)),
        guest: 2,
      ),
      throwsException,
    );
  });

  test('allows a reservation right after another one ends', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    service.makeReservation(
      reservationId: 'R2',
      customerId: 'C1',
      tableId: 1,
      start: dinner.add(const Duration(minutes: 90)),
      guest: 2,
    );

    expect(service.reservations.length, 2);
  });

  test('allows a reservation after a cancelled one on the same slot', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    service.cancelReservation(reservationId: 'R1');

    service.makeReservation(
      reservationId: 'R2',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    expect(service.reservations.length, 2);
    expect(service.reservations.first.status, ReservationStatus.cancelled);
  });

  test('rejects a reservation on a table that is out of service', () {
    final service = newService();
    service.tables.first.status = TableStatus.outOfService;

    expect(
      () => service.makeReservation(
        reservationId: 'R1',
        customerId: 'C1',
        tableId: 1,
        start: dinner,
        guest: 2,
      ),
      throwsException,
    );
  });

  test('seating occupies the table and completing frees it', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    service.seatReservation(reservationId: 'R1');
    expect(service.reservations.single.status, ReservationStatus.seated);
    expect(service.tables.first.status, TableStatus.occupied);

    service.completeReservation(reservationId: 'R1');
    expect(service.reservations.single.status, ReservationStatus.completed);
    expect(service.tables.first.status, TableStatus.available);
  });

  test('cannot seat a reservation that was cancelled', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    service.cancelReservation(reservationId: 'R1');

    expect(() => service.seatReservation(reservationId: 'R1'), throwsException);
  });

  test('cannot complete a reservation that has not been seated', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    expect(
      () => service.completeReservation(reservationId: 'R1'),
      throwsException,
    );
  });

  test('marks a reservation as no-show', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    service.markNoShow(reservationId: 'R1');

    expect(service.reservations.single.status, ReservationStatus.noShow);
  });

  test('finds only tables that fit the party and are free in the slot', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    final free = service.findAvailableTables(start: dinner, guest: 2);
    expect(free.map((t) => t.id), [2]);

    final freeForFour = service.findAvailableTables(start: dinner, guest: 4);
    expect(freeForFour, isEmpty);
  });

  test('lists reservations for a given day', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    service.makeReservation(
      reservationId: 'R2',
      customerId: 'C1',
      tableId: 2,
      start: DateTime(2026, 9, 21, 12, 0),
      guest: 2,
    );

    final sept20 = service.getReservationsForDate(DateTime(2026, 9, 20));
    expect(sept20.map((r) => r.id), ['R1']);
  });

  test('lists reservations for a customer', () {
    final service = newService();
    service.addCustomer(customerId: 'C2', name: 'Bob', phone: '555-0200');
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    service.makeReservation(
      reservationId: 'R2',
      customerId: 'C2',
      tableId: 2,
      start: dinner,
      guest: 2,
    );

    final bobs = service.getReservationsForCustomer(customerId: 'C2');
    expect(bobs.map((r) => r.id), ['R2']);
  });

  test('removing a customer also removes their reservations', () {
    final service = newService();
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    service.removeCustomer(customerId: 'C1');

    expect(service.customers, isEmpty);
    expect(service.reservations, isEmpty);
  });

  test('table is still held one minute before the late limit', () {
    var now = dinner;
    final service = newService(now: () => now);
    service.addCustomer(customerId: 'C2', name: 'Bob', phone: '555-0200');
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    now = dinner.add(const Duration(minutes: 19));

    expect(
      () => service.makeReservation(
        reservationId: 'R2',
        customerId: 'C2',
        tableId: 1,
        start: now,
        guest: 2,
      ),
      throwsException,
    );
  });

  test('table becomes available once the guest is 20 minutes late', () {
    var now = dinner;
    final service = newService(now: () => now);
    service.addCustomer(customerId: 'C2', name: 'Bob', phone: '555-0200');
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    now = dinner.add(const Duration(minutes: 21));

    expect(service.findAvailableTables(start: now, guest: 2).length, 2);
    service.makeReservation(
      reservationId: 'R2',
      customerId: 'C2',
      tableId: 1,
      start: now,
      guest: 2,
    );

    expect(service.reservations.first.status, ReservationStatus.noShow);
    expect(service.reservations.last.status, ReservationStatus.pending);
  });

  test('releaseExpiredReservations reports how many it released', () {
    var now = dinner;
    final service = newService(now: () => now);
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    now = dinner.add(const Duration(minutes: 30));

    expect(service.releaseExpiredReservations(), 1);
    expect(service.releaseExpiredReservations(), 0);
  });

  test('a seated reservation never expires', () {
    var now = dinner;
    final service = newService(now: () => now);
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    service.seatReservation(reservationId: 'R1');

    now = dinner.add(const Duration(minutes: 60));

    expect(service.releaseExpiredReservations(), 0);
    expect(service.reservations.single.status, ReservationStatus.seated);
  });

  test('cannot seat a guest who arrives after the late limit', () {
    var now = dinner;
    final service = newService(now: () => now);
    service.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    now = dinner.add(const Duration(minutes: 25));

    expect(() => service.seatReservation(reservationId: 'R1'), throwsException);
    expect(service.reservations.single.status, ReservationStatus.noShow);
  });

  test(
    'supports many-to-many relationship between customers and restaurants',
    () {
      final service = newService();

      service.addRestaurant(
        restaurantId: 'RST2',
        name: 'Sushi Zen',
        openingHour: 12,
        closingHour: 23,
      );
      service.addTable(
        restaurantId: 'RST2',
        tableId: 1,
        seats: 4,
        location: TableLocation.indoor,
      );

      service.makeReservation(
        reservationId: 'RES-BISTRO',
        restaurantId: 'RST1',
        customerId: 'C1',
        tableId: 1,
        start: dinner,
        guest: 2,
      );

      service.makeReservation(
        reservationId: 'RES-SUSHI',
        restaurantId: 'RST2',
        customerId: 'C1',
        tableId: 1,
        start: dinner.add(const Duration(days: 1)),
        guest: 2,
      );

      final c1Reservations = service.getReservationsForCustomer(
        customerId: 'C1',
      );
      expect(c1Reservations.length, 2);

      expect(
        service.getReservationsForRestaurant(restaurantId: 'RST1').length,
        1,
      );
      expect(
        service.getReservationsForRestaurant(restaurantId: 'RST2').length,
        1,
      );
    },
  );
}
