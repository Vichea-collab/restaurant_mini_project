class FormatUtils {
  static const _weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];

  static String date(DateTime dt) {
    return '${_weekdays[dt.weekday - 1]} ${dt.day} ${_months[dt.month - 1]}';
  }

  static String time(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static String hour(int hour) {
    return '${hour.toString().padLeft(2, '0')}:00';
  }
}
