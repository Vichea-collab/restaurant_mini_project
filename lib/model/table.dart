enum TableLocation { indoor, outdoor, window, bar, privateRoom }

enum TableStatus { available, occupied, outOfService }

class Table {
  final int id;
  final int seats;
  final TableLocation location;
  TableStatus status = TableStatus.available;

  Table({required this.id, required this.seats, required this.location});

  // indoor and private room accept any number of guests
  bool get hasGuestLimit {
    return location == TableLocation.bar ||
        location == TableLocation.window ||
        location == TableLocation.outdoor;
  }

  bool canSeat(int guest) {
    return !hasGuestLimit || guest <= seats;
  }
}
