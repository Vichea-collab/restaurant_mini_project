enum TableLocation { indoor, outdoor, window, bar, privateRoom }

enum TableStatus { available, occupied, outOfService }

class Table {
  final int id;
  final int seats;
  final TableLocation location;
  TableStatus status = TableStatus.available;

  Table({required this.id, required this.seats, required this.location});
}
