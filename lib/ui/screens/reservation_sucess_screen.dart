import 'package:flutter/material.dart' hide Table;

import '../../main.dart';
import '../../model/reservation.dart';
import '../../service/restaurant_service.dart';
import '../widgets/info_field.dart';
import '../widgets/primary_button.dart';
import '../widgets/status_badge.dart';

class ReservationSucessScreen extends StatelessWidget {
  final RestaurantService service;
  final Reservation reservation;
  final String restaurantName;
  final String? customerName;
  final String? customerPhone;
  final int? tableSeats;
  final String tableLocation;

  const ReservationSucessScreen({
    super.key,
    required this.service,
    required this.reservation,
    this.restaurantName = 'The Bistro Gourmet',
    this.customerName,
    this.customerPhone,
    this.tableSeats,
    this.tableLocation = 'Indoor',
  });

  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
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

  String _formatDate(DateTime dt) =>
      '${_days[dt.weekday - 1]} ${dt.day} ${_months[dt.month - 1]}';

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _formatBookedDate(DateTime dt) =>
      '${dt.day} ${_months[dt.month - 1]}, ${_formatTime(dt)}';

  String get _statusBadgeText {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return 'Pending';
      case ReservationStatus.seated:
        return 'Seated';
      case ReservationStatus.completed:
        return 'Completed';
      case ReservationStatus.cancelled:
        return 'Cancelled';
      case ReservationStatus.noShow:
        return 'No-show';
    }
  }

  String get _statusHeadline {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return 'Reservation Confirmed!';
      case ReservationStatus.seated:
        return 'Guests Seated';
      case ReservationStatus.completed:
        return 'Reservation Completed';
      case ReservationStatus.cancelled:
        return 'Reservation Cancelled';
      case ReservationStatus.noShow:
        return 'Marked as No-Show';
    }
  }

  String get _statusSubtitle {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return 'Your table at $restaurantName is booked.';
      case ReservationStatus.seated:
        return 'Guests are currently seated at $restaurantName.';
      case ReservationStatus.completed:
        return 'This reservation at $restaurantName was completed.';
      case ReservationStatus.cancelled:
        return 'This reservation has been cancelled.';
      case ReservationStatus.noShow:
        return 'Guest did not arrive for this reservation.';
    }
  }

  IconData get _statusIcon {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return Icons.check_circle_rounded;
      case ReservationStatus.seated:
        return Icons.chair_outlined;
      case ReservationStatus.completed:
        return Icons.task_alt_rounded;
      case ReservationStatus.cancelled:
        return Icons.cancel_outlined;
      case ReservationStatus.noShow:
        return Icons.person_off_outlined;
    }
  }

  Color get _statusIconColor {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return const Color(0xFFB47214);
      case ReservationStatus.seated:
        return const Color(0xFF1A73E8);
      case ReservationStatus.completed:
        return const Color(0xFF166359);
      case ReservationStatus.cancelled:
        return const Color(0xFFD93025);
      case ReservationStatus.noShow:
        return const Color(0xFF5F6368);
    }
  }

  Color get _statusIconBg {
    switch (reservation.status) {
      case ReservationStatus.pending:
        return const Color(0xFFFEF3E2);
      case ReservationStatus.seated:
        return const Color(0xFFE8F0FE);
      case ReservationStatus.completed:
        return const Color(0xFFE8F5F1);
      case ReservationStatus.cancelled:
        return const Color(0xFFFCE8E6);
      case ReservationStatus.noShow:
        return const Color(0xFFF1F3F4);
    }
  }

  @override
  Widget build(BuildContext context) {
    final startTime = _formatTime(reservation.slot.start);
    final endTime = _formatTime(reservation.slot.end);
    final dateStr = _formatDate(reservation.slot.start);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 18,
            color: Color(0xFF1E232A),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Confirmation',
          style: TextStyle(
            color: Color(0xFF1E232A),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StatusBadge.forStatus(_statusBadgeText)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        children: [
          const SizedBox(height: 8),

          Center(
            child: Column(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: _statusIconBg,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(_statusIcon, color: _statusIconColor, size: 38),
                ),
                const SizedBox(height: 12),
                Text(
                  _statusHeadline,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E232A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _statusSubtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF6B7280),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F9F7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF166359).withValues(alpha: 0.15),
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF166359),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.restaurant,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        restaurantName,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E232A),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Booking ID: ${reservation.id}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF166359),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: InfoField(
                  label: 'Date',
                  icon: Icons.calendar_today_outlined,
                  value: dateStr,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InfoField(
                  label: 'Time',
                  icon: Icons.access_time,
                  value: '$startTime - $endTime',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          InfoField(
            label: 'Guest',
            icon: Icons.people_outline,
            value: '${reservation.guest} guests',
          ),
          const SizedBox(height: 16),

          InfoField(
            label: 'Table location',
            icon: Icons.chair_outlined,
            value: tableLocation,
          ),

          if (reservation.specialRequest != null &&
              reservation.specialRequest!.isNotEmpty) ...[
            const SizedBox(height: 16),
            InfoField(
              label: 'Special request',
              icon: Icons.notes_outlined,
              value: reservation.specialRequest!,
            ),
          ],
          const SizedBox(height: 16),

          InfoField(
            label: 'Booked',
            icon: Icons.schedule,
            value: _formatBookedDate(reservation.createdAt),
          ),
          const SizedBox(height: 24),

          PrimaryButton(
            text: 'Done',
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => RestaurantCustomerApp(
                    service: service,
                    initialTabIndex: 1,
                    customerId: reservation.customerId,
                  ),
                ),
                (route) => false,
              );
            },
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

typedef ReservationSuccessScreen = ReservationSucessScreen;
typedef ReservationDetailScreen = ReservationSucessScreen;
