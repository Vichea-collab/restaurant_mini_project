import '../model/customer.dart';
import '../model/reservation.dart';
import '../model/restaurant.dart';
import '../model/table.dart';
import '../model/time_slot.dart';

class RestaurantService {
  final List<Restaurant> restaurants = [];
  final List<Customer> customers = [];
  final List<Reservation> reservations = [];
  final DateTime Function() _now;

  RestaurantService({
    String? restaurantId,
    String? restaurantName,
    int? openingHour,
    int? closingHour,
    int maxLateMinutes = 20,
    DateTime Function()? now,
  }) : _now = now ?? DateTime.now {
    if (restaurantName != null && openingHour != null && closingHour != null) {
      addRestaurant(
        restaurantId: restaurantId ?? 'RST1',
        name: restaurantName,
        openingHour: openingHour,
        closingHour: closingHour,
        maxLateMinutes: maxLateMinutes,
      );
    }
  }

  Restaurant get restaurant {
    if (restaurants.isEmpty) {
      throw Exception('No restaurants available in the service');
    }
    return restaurants.first;
  }

  List<Table> get tables => restaurants.expand((r) => r.tables).toList();

  void addRestaurant({
    required String restaurantId,
    required String name,
    required int openingHour,
    required int closingHour,
    String type = 'Other',
    int maxLateMinutes = 20,
  }) {
    if (_findRestaurantOrNull(restaurantId) != null) {
      throw Exception('Restaurant $restaurantId already exists');
    }
    restaurants.add(
      Restaurant(
        id: restaurantId,
        name: name,
        type: type,
        openingHour: openingHour,
        closingHour: closingHour,
        maxLateMinutes: maxLateMinutes,
      ),
    );
  }

  void addTable({
    String? restaurantId,
    required int tableId,
    required int seats,
    TableLocation location = TableLocation.indoor,
  }) {
    Restaurant r = _resolveRestaurant(restaurantId);
    Table? table = _findTableInRestaurantOrNull(r, tableId);
    if (table != null) {
      throw Exception('Table $tableId already exists in restaurant ${r.id}');
    }

    if (seats <= 0) {
      throw Exception('Table seats must be greater than zero');
    }

    r.tables.add(Table(id: tableId, seats: seats, location: location));
  }

  void addCustomer({
    required String customerId,
    required String name,
    required String phone,
  }) {
    Customer? customer = _findCustomerOrNull(customerId);
    if (customer != null) {
      throw Exception('Customer $customerId already exists');
    }

    customers.add(Customer(id: customerId, name: name, phone: phone));
  }

  void makeReservation({
    required String reservationId,
    String? restaurantId,
    required String customerId,
    required int tableId,
    required DateTime start,
    required int guest,
    int? durationMinutes,
    String? specialRequest,
  }) {
    releaseExpiredReservations();

    Reservation? existing = _findReservationOrNull(reservationId);
    if (existing != null) {
      throw Exception('Reservation $reservationId already exists');
    }

    Restaurant r = _resolveRestaurant(restaurantId);

    _findCustomer(customerId);

    Table table = _findTableInRestaurant(r, tableId);

    if (table.status == TableStatus.outOfService) {
      throw Exception('Table $tableId is out of service');
    }

    if (guest < Reservation.minGuests) {
      throw Exception('Guest count must be greater than zero');
    }
    if (!table.canSeat(guest)) {
      throw Exception(
        'Table $tableId (${table.seats} seats) cannot seat $guest',
      );
    }

    TimeSlot slot = _slotFor(start, durationMinutes);
    if (!_isWithinOpeningHours(r, slot)) {
      throw Exception(
        'Reservation ${slot.start} - ${slot.end} is outside opening hours '
        '(${r.openingHour}:00 - ${r.closingHour}:00)',
      );
    }

    if (!_isTableFree(r.id, tableId, slot)) {
      throw Exception(
        'Table $tableId is already reserved between ${slot.start} and ${slot.end}',
      );
    }

    reservations.add(
      Reservation(
        id: reservationId,
        restaurantId: r.id,
        customerId: customerId,
        tableId: tableId,
        slot: slot,
        guest: guest,
        specialRequest: specialRequest,
        createdAt: _now(),
        holdUntil: start.add(Duration(minutes: r.maxLateMinutes)),
      ),
    );
  }

  bool hasTableForLocation({
    String? restaurantId,
    required TableLocation location,
    required int guest,
  }) {
    Restaurant r = _resolveRestaurant(restaurantId);
    for (Table t in r.tables) {
      if (t.location == location && t.canSeat(guest)) {
        return true;
      }
    }
    return false;
  }

  void seatReservation({required String reservationId}) {
    releaseExpiredReservations();

    Reservation reservation = _findReservation(reservationId);

    if (reservation.status == ReservationStatus.noShow) {
      throw Exception(
        'Reservation $reservationId expired at ${reservation.holdUntil}; '
        'make a new reservation if the table is still free',
      );
    }

    if (reservation.status != ReservationStatus.pending) {
      throw Exception(
        'Reservation $reservationId is ${reservation.status.name}, not pending',
      );
    }

    reservation.status = ReservationStatus.seated;
    Restaurant r = _findRestaurant(reservation.restaurantId);
    _findTableInRestaurant(r, reservation.tableId).status =
        TableStatus.occupied;
  }

  void completeReservation({required String reservationId}) {
    Reservation reservation = _findReservation(reservationId);

    if (reservation.status != ReservationStatus.seated) {
      throw Exception('Reservation $reservationId has not been seated');
    }

    reservation.status = ReservationStatus.completed;
    Restaurant r = _findRestaurant(reservation.restaurantId);
    _findTableInRestaurant(r, reservation.tableId).status =
        TableStatus.available;
  }

  void cancelReservation({required String reservationId}) {
    Reservation reservation = _findReservation(reservationId);

    if (reservation.status != ReservationStatus.pending) {
      throw Exception(
        'Reservation $reservationId is ${reservation.status.name}, not pending',
      );
    }

    reservation.status = ReservationStatus.cancelled;
  }

  void markNoShow({required String reservationId}) {
    Reservation reservation = _findReservation(reservationId);

    if (reservation.status != ReservationStatus.pending) {
      throw Exception(
        'Reservation $reservationId is ${reservation.status.name}, not pending',
      );
    }

    reservation.status = ReservationStatus.noShow;
  }

  int releaseExpiredReservations() {
    DateTime now = _now();
    int released = 0;
    for (Reservation r in reservations) {
      bool late =
          r.status == ReservationStatus.pending && now.isAfter(r.holdUntil);
      if (late) {
        r.status = ReservationStatus.noShow;
        released++;
      }
    }
    return released;
  }

  List<Table> findAvailableTables({
    String? restaurantId,
    required DateTime start,
    required int guest,
    int? durationMinutes,
  }) {
    releaseExpiredReservations();

    Restaurant r = _resolveRestaurant(restaurantId);
    TimeSlot slot = _slotFor(start, durationMinutes);
    List<Table> result = [];
    for (Table t in r.tables) {
      bool inService = t.status != TableStatus.outOfService;
      bool fits = guest >= Reservation.minGuests && t.canSeat(guest);
      if (inService && fits && _isTableFree(r.id, t.id, slot)) {
        result.add(t);
      }
    }
    return result;
  }

  List<Reservation> getReservationsForDate(
    DateTime date, {
    String? restaurantId,
  }) {
    List<Reservation> result = reservations
        .where(
          (r) =>
              (restaurantId == null || r.restaurantId == restaurantId) &&
              r.slot.start.year == date.year &&
              r.slot.start.month == date.month &&
              r.slot.start.day == date.day,
        )
        .toList();
    result.sort((a, b) => a.slot.start.compareTo(b.slot.start));
    return result;
  }

  List<String> getTypes() {
    List<String> result = [];
    for (Restaurant r in restaurants) {
      if (!result.contains(r.type)) {
        result.add(r.type);
      }
    }
    return result;
  }

  List<Restaurant> getRestaurantsForType(String? type) {
    List<Restaurant> result = [];
    for (Restaurant r in restaurants) {
      if (type == null || r.type == type) {
        result.add(r);
      }
    }
    return result;
  }

  List<Reservation> getReservationsForCustomer({
    required String customerId,
    ReservationStatus? status,
  }) {
    List<Reservation> result = [];
    for (Reservation r in reservations) {
      if (r.customerId != customerId) {
        continue;
      }
      if (status == null || r.status == status) {
        result.add(r);
      }
    }
    return result;
  }

  List<Reservation> getReservationsForRestaurant({
    required String restaurantId,
  }) {
    return reservations.where((r) => r.restaurantId == restaurantId).toList();
  }

  void removeCustomer({required String customerId}) {
    _findCustomer(customerId);

    customers.removeWhere((c) => c.id == customerId);
    reservations.removeWhere((r) => r.customerId == customerId);
  }

  TimeSlot _slotFor(DateTime start, int? durationMinutes) {
    if (durationMinutes != null && durationMinutes <= 0) {
      throw Exception('Duration must be greater than zero');
    }
    int minutes = durationMinutes ?? 90;
    return TimeSlot(
      start: start,
      end: start.add(Duration(minutes: minutes)),
    );
  }

  bool _isWithinOpeningHours(Restaurant r, TimeSlot slot) {
    DateTime day = DateTime(slot.start.year, slot.start.month, slot.start.day);
    DateTime opens = day.add(Duration(hours: r.openingHour));
    DateTime closes = day.add(Duration(hours: r.closingHour));
    return !slot.start.isBefore(opens) && !slot.end.isAfter(closes);
  }

  bool _overlaps(TimeSlot a, TimeSlot b) {
    return a.start.isBefore(b.end) && b.start.isBefore(a.end);
  }

  bool _isTableFree(String restaurantId, int tableId, TimeSlot slot) {
    for (Reservation r in reservations) {
      bool holdsTable =
          r.status == ReservationStatus.pending ||
          r.status == ReservationStatus.seated;
      bool overlaps = _overlaps(r.slot, slot);
      if (r.restaurantId == restaurantId &&
          r.tableId == tableId &&
          holdsTable &&
          overlaps) {
        return false;
      }
    }
    return true;
  }

  String getRestaurantName(String restaurantId) {
    return _findRestaurant(restaurantId).name;
  }

  String getTableLocationName(String restaurantId, int tableId) {
    Restaurant r = _findRestaurant(restaurantId);
    Table t = _findTableInRestaurant(r, tableId);
    String name = t.location.name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  Customer getCustomer(String customerId) {
    return _findCustomer(customerId);
  }

  Restaurant _resolveRestaurant(String? restaurantId) {
    if (restaurantId != null) {
      return _findRestaurant(restaurantId);
    }
    return restaurant;
  }

  Restaurant _findRestaurant(String restaurantId) {
    Restaurant? r = _findRestaurantOrNull(restaurantId);
    if (r == null) {
      throw Exception('Restaurant $restaurantId not found');
    }
    return r;
  }

  Restaurant? _findRestaurantOrNull(String restaurantId) {
    for (Restaurant r in restaurants) {
      if (r.id == restaurantId) {
        return r;
      }
    }
    return null;
  }

  Table _findTableInRestaurant(Restaurant r, int tableId) {
    Table? table = _findTableInRestaurantOrNull(r, tableId);
    if (table == null) {
      throw Exception('Table $tableId not found in restaurant ${r.id}');
    }
    return table;
  }

  Table? _findTableInRestaurantOrNull(Restaurant r, int tableId) {
    for (Table t in r.tables) {
      if (t.id == tableId) {
        return t;
      }
    }
    return null;
  }

  Customer _findCustomer(String customerId) {
    Customer? customer = _findCustomerOrNull(customerId);
    if (customer == null) {
      throw Exception('Customer $customerId not found');
    }
    return customer;
  }

  Customer? _findCustomerOrNull(String customerId) {
    for (Customer c in customers) {
      if (c.id == customerId) {
        return c;
      }
    }
    return null;
  }

  Reservation _findReservation(String reservationId) {
    Reservation? reservation = _findReservationOrNull(reservationId);
    if (reservation == null) {
      throw Exception('Reservation $reservationId not found');
    }
    return reservation;
  }

  Reservation? _findReservationOrNull(String reservationId) {
    for (Reservation r in reservations) {
      if (r.id == reservationId) {
        return r;
      }
    }
    return null;
  }
}
