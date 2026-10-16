class TimeSlot {
  final DateTime start;
  final DateTime end;

  TimeSlot({required this.start, required this.end});

  bool overlaps(TimeSlot other) {
    return start.isBefore(other.end) && other.start.isBefore(end);
  }
}
