import 'package:test/test.dart';
import 'package:w3/model/reservation.dart';
import 'package:w3/model/table.dart';
import 'package:w3/service/reservation_service.dart';
import 'package:w3/service/restaurant_service.dart';

(RestaurantService, ReservationService) newService({
  DateTime Function()? now,
}) {
  final service = RestaurantService(
    restaurantName: 'Bistro',
    openingHour: 11,
    closingHour: 22,
    maxLateMinutes: 20,
  );
  service.addTable(tableId: 1, seats: 4, location: TableLocation.indoor);
  service.addTable(tableId: 2, seats: 2, location: TableLocation.window);
  service.addCustomer(customerId: 'C1', name: 'Alice', phone: '555-0100');
  final reservationService = ReservationService(
    service,
    now: now ?? () => dinner.subtract(const Duration(hours: 1)),
  );
  return (service, reservationService);
}

final dinner = DateTime(2026, 9, 20, 19, 0);

void main() {
  test('adds a table', () {
    final (service, _) = newService();

    expect(service.tables.length, 2);
    expect(service.tables.first.seats, 4);
    expect(service.tables.first.status, TableStatus.available);
  });

  test('rejects a duplicate table id', () {
    final (service, _) = newService();

    expect(() => service.addTable(tableId: 1, seats: 6), throwsException);
  });

  test('adds a customer', () {
    final (service, _) = newService();

    expect(service.customers.length, 1);
    expect(service.customers.first.name, 'Alice');
  });

  test('rejects a duplicate customer id', () {
    final (service, _) = newService();

    expect(
      () => service.addCustomer(customerId: 'C1', name: 'Bob', phone: '1'),
      throwsException,
    );
  });

  test('makes a pending reservation with the default duration', () {
    final (_, reservationService) = newService();

    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 3,
    );

    final r = reservationService.reservations.single;
    expect(r.status, ReservationStatus.pending);
    expect(r.customerId, 'C1');
    expect(r.tableId, 1);
    expect(r.slot.start, dinner);
    expect(r.slot.end, dinner.add(const Duration(minutes: 90)));
    expect(r.holdUntil, dinner.add(const Duration(minutes: 20)));
    expect(r.guest, 3);
  });

  test('stores a custom duration and special request', () {
    final (_, reservationService) = newService();

    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
      durationMinutes: 120,
      specialRequest: 'Birthday cake',
    );

    final r = reservationService.reservations.single;
    expect(r.slot.end, dinner.add(const Duration(minutes: 120)));
    expect(r.specialRequest, 'Birthday cake');
  });

  test('rejects a duplicate reservation id', () {
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    expect(
      () => reservationService.makeReservation(
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
    final (_, reservationService) = newService();

    expect(
      () => reservationService.makeReservation(
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
    final (_, reservationService) = newService();

    expect(
      () => reservationService.makeReservation(
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
    final (_, reservationService) = newService();

    expect(
      () => reservationService.makeReservation(
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
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    expect(
      () => reservationService.makeReservation(
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
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    reservationService.makeReservation(
      reservationId: 'R2',
      customerId: 'C1',
      tableId: 1,
      start: dinner.add(const Duration(minutes: 90)),
      guest: 2,
    );

    expect(reservationService.reservations.length, 2);
  });

  test('allows a reservation after a cancelled one on the same slot', () {
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    reservationService.cancelReservation(reservationId: 'R1');

    reservationService.makeReservation(
      reservationId: 'R2',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    expect(reservationService.reservations.length, 2);
    expect(
      reservationService.reservations.first.status,
      ReservationStatus.cancelled,
    );
  });

  test('rejects a reservation on a table that is out of service', () {
    final (service, reservationService) = newService();
    service.tables.first.status = TableStatus.outOfService;

    expect(
      () => reservationService.makeReservation(
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
    final (service, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    reservationService.seatReservation(reservationId: 'R1');
    expect(
      reservationService.reservations.single.status,
      ReservationStatus.seated,
    );
    expect(service.tables.first.status, TableStatus.occupied);

    reservationService.completeReservation(reservationId: 'R1');
    expect(
      reservationService.reservations.single.status,
      ReservationStatus.completed,
    );
    expect(service.tables.first.status, TableStatus.available);
  });

  test('cannot seat a reservation that was cancelled', () {
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    reservationService.cancelReservation(reservationId: 'R1');

    expect(
      () => reservationService.seatReservation(reservationId: 'R1'),
      throwsException,
    );
  });

  test('cannot complete a reservation that has not been seated', () {
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    expect(
      () => reservationService.completeReservation(reservationId: 'R1'),
      throwsException,
    );
  });

  test('marks a reservation as no-show', () {
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    reservationService.markNoShow(reservationId: 'R1');

    expect(
      reservationService.reservations.single.status,
      ReservationStatus.noShow,
    );
  });

  test('finds only tables that fit the party and are free in the slot', () {
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    final free = reservationService.findAvailableTables(
      start: dinner,
      guest: 2,
    );
    expect(free.map((t) => t.id), [2]);

    final freeForFour = reservationService.findAvailableTables(
      start: dinner,
      guest: 4,
    );
    expect(freeForFour, isEmpty);
  });

  test('lists reservations for a given day', () {
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    reservationService.makeReservation(
      reservationId: 'R2',
      customerId: 'C1',
      tableId: 2,
      start: DateTime(2026, 9, 21, 12, 0),
      guest: 2,
    );

    final sept20 = reservationService.getReservationsForDate(
      DateTime(2026, 9, 20),
    );
    expect(sept20.map((r) => r.id), ['R1']);
  });

  test('lists reservations for a customer', () {
    final (service, reservationService) = newService();
    service.addCustomer(customerId: 'C2', name: 'Bob', phone: '555-0200');
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    reservationService.makeReservation(
      reservationId: 'R2',
      customerId: 'C2',
      tableId: 2,
      start: dinner,
      guest: 2,
    );

    final bobs = reservationService.getReservationsForCustomer(
      customerId: 'C2',
    );
    expect(bobs.map((r) => r.id), ['R2']);
  });

  test('removing a customer also removes their reservations', () {
    final (service, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    service.removeCustomer(customerId: 'C1');
    reservationService.removeReservationsForCustomer(customerId: 'C1');

    expect(service.customers, isEmpty);
    expect(reservationService.reservations, isEmpty);
  });

  test('table is still held one minute before the late limit', () {
    var now = dinner;
    final (service, reservationService) = newService(now: () => now);
    service.addCustomer(customerId: 'C2', name: 'Bob', phone: '555-0200');
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    now = dinner.add(const Duration(minutes: 19));

    expect(
      () => reservationService.makeReservation(
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
    final (service, reservationService) = newService(now: () => now);
    service.addCustomer(customerId: 'C2', name: 'Bob', phone: '555-0200');
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    now = dinner.add(const Duration(minutes: 21));

    expect(
      reservationService.findAvailableTables(start: now, guest: 2).length,
      2,
    );
    reservationService.makeReservation(
      reservationId: 'R2',
      customerId: 'C2',
      tableId: 1,
      start: now,
      guest: 2,
    );

    expect(
      reservationService.reservations.first.status,
      ReservationStatus.noShow,
    );
    expect(
      reservationService.reservations.last.status,
      ReservationStatus.pending,
    );
  });

  test('releaseExpiredReservations reports how many it released', () {
    var now = dinner;
    final (_, reservationService) = newService(now: () => now);
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    now = dinner.add(const Duration(minutes: 30));

    expect(reservationService.releaseExpiredReservations(), 1);
    expect(reservationService.releaseExpiredReservations(), 0);
  });

  test('a seated reservation never expires', () {
    var now = dinner;
    final (_, reservationService) = newService(now: () => now);
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    reservationService.seatReservation(reservationId: 'R1');

    now = dinner.add(const Duration(minutes: 60));

    expect(reservationService.releaseExpiredReservations(), 0);
    expect(
      reservationService.reservations.single.status,
      ReservationStatus.seated,
    );
  });

  test('cannot seat a guest who arrives after the late limit', () {
    var now = dinner;
    final (_, reservationService) = newService(now: () => now);
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );

    now = dinner.add(const Duration(minutes: 25));

    expect(
      () => reservationService.seatReservation(reservationId: 'R1'),
      throwsException,
    );
    expect(
      reservationService.reservations.single.status,
      ReservationStatus.noShow,
    );
  });

  test(
    'supports many-to-many relationship between customers and restaurants',
    () {
      final (service, reservationService) = newService();

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

      reservationService.makeReservation(
        reservationId: 'RES-BISTRO',
        restaurantId: 'RST1',
        customerId: 'C1',
        tableId: 1,
        start: dinner,
        guest: 2,
      );

      reservationService.makeReservation(
        reservationId: 'RES-SUSHI',
        restaurantId: 'RST2',
        customerId: 'C1',
        tableId: 1,
        start: dinner.add(const Duration(days: 1)),
        guest: 2,
      );

      final c1Reservations = reservationService.getReservationsForCustomer(
        customerId: 'C1',
      );
      expect(c1Reservations.length, 2);

      expect(
        reservationService
            .getReservationsForRestaurant(restaurantId: 'RST1')
            .length,
        1,
      );
      expect(
        reservationService
            .getReservationsForRestaurant(restaurantId: 'RST2')
            .length,
        1,
      );
    },
  );

  test('filters a customer\'s reservations by status', () {
    final (_, reservationService) = newService();
    reservationService.makeReservation(
      reservationId: 'RES-1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 2,
    );
    reservationService.makeReservation(
      reservationId: 'RES-2',
      customerId: 'C1',
      tableId: 2,
      start: dinner,
      guest: 2,
    );
    reservationService.cancelReservation(reservationId: 'RES-2');

    expect(
      reservationService.getReservationsForCustomer(customerId: 'C1').length,
      2,
    );
    expect(
      reservationService
          .getReservationsForCustomer(
            customerId: 'C1',
            status: ReservationStatus.cancelled,
          )
          .map((r) => r.id),
      ['RES-2'],
    );
    expect(
      reservationService
          .getReservationsForCustomer(
            customerId: 'C1',
            status: ReservationStatus.seated,
          )
          .isEmpty,
      isTrue,
    );
  });

  test('looking up an unknown id throws instead of guessing', () {
    final (service, _) = newService();

    expect(() => service.getCustomer('C-NONE'), throwsException);
    expect(() => service.getRestaurantName('RST-NONE'), throwsException);
    expect(() => service.getTableLocationName('RST1', 99), throwsException);
  });

  test('gets a customer, a restaurant name and a table location name', () {
    final (service, _) = newService();

    expect(service.getCustomer('C1').name, 'Alice');
    expect(service.getRestaurantName('RST1'), 'Bistro');
    expect(service.getTableLocationName('RST1', 2), 'Window');
  });

  test('filters restaurants by type', () {
    final (service, _) = newService();
    service.addRestaurant(
      restaurantId: 'RST2',
      name: 'Zen',
      type: 'Japanese',
      openingHour: 12,
      closingHour: 23,
    );
    service.addRestaurant(
      restaurantId: 'RST3',
      name: 'Sakura',
      type: 'Japanese',
      openingHour: 12,
      closingHour: 23,
    );

    expect(service.getTypes(), ['Other', 'Japanese']);
    expect(service.getRestaurantsForType(null).length, 3);
    expect(service.getRestaurantsForType('Japanese').map((r) => r.name), [
      'Zen',
      'Sakura',
    ]);
    expect(service.getRestaurantsForType('Italian').isEmpty, isTrue);
  });

  test('checks that a location has a table big enough', () {
    final (service, _) = newService();

    expect(
      service.hasTableForLocation(location: TableLocation.indoor, guest: 4),
      isTrue,
    );
    expect(
      service.hasTableForLocation(location: TableLocation.window, guest: 2),
      isTrue,
    );
    expect(
      service.hasTableForLocation(location: TableLocation.window, guest: 3),
      isFalse,
    );
    expect(
      service.hasTableForLocation(location: TableLocation.bar, guest: 1),
      isFalse,
    );
  });

  test('only bar, window and outdoor have a guest limit', () {
    final (service, reservationService) = newService();

    // indoor table has 4 seats but takes any number of guests
    reservationService.makeReservation(
      reservationId: 'R1',
      customerId: 'C1',
      tableId: 1,
      start: dinner,
      guest: 12,
    );
    expect(reservationService.reservations.first.guest, 12);

    // window table has 2 seats and a limit
    expect(
      service.hasTableForLocation(location: TableLocation.window, guest: 3),
      isFalse,
    );
    expect(
      service.hasTableForLocation(location: TableLocation.indoor, guest: 50),
      isTrue,
    );
  });
}
