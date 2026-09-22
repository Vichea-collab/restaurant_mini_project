import 'table.dart';

class Restaurant {
  final String id;
  final String name;
  final int openingHour;
  final int closingHour;
  final int maxLateMinutes;
  final List<Table> tables;

  Restaurant({
    required this.id,
    required this.name,
    required this.openingHour,
    required this.closingHour,
    this.maxLateMinutes = 20,
    List<Table>? tables,
  }) : tables = tables ?? [];
}
