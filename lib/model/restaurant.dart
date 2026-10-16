import 'table.dart';

class Restaurant {
  final String name;
  final String type;
  final int openingHour;
  final int closingHour;
  final List<Table> tables;

  Restaurant({
    required this.name,
    required this.type,
    required this.openingHour,
    required this.closingHour,
    required this.tables,
  });
}
