import 'package:flutter/material.dart';

import '../../model/reservation.dart';
import 'theme.dart';

class StatusBadge extends StatelessWidget {
  final ReservationStatus status;

  const StatusBadge({super.key, required this.status});

  Color get backgroundColor {
    switch (status) {
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

  Color get textColor {
    switch (status) {
      case ReservationStatus.pending:
        return const Color(0xFFB47214);
      case ReservationStatus.seated:
        return const Color(0xFF1A73E8);
      case ReservationStatus.completed:
        return AppColors.teal;
      case ReservationStatus.cancelled:
        return AppColors.red;
      case ReservationStatus.noShow:
        return const Color(0xFF5F6368);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
