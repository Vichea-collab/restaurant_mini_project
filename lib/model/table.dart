enum TableLocation {
  indoor('Indoor'),
  outdoor('Outdoor'),
  window('Window'),
  bar('Bar'),
  privateRoom('Private Room');

  final String label;
  const TableLocation(this.label);
}

class Table {
  final int id;
  final int seats;
  final TableLocation location;

  Table({required this.id, required this.seats, required this.location});

  bool get hasGuestLimit {
    return location == TableLocation.bar ||
        location == TableLocation.window ||
        location == TableLocation.outdoor;
  }

  bool canSeat(int guest) {
    return !hasGuestLimit || guest <= seats;
  }
}
