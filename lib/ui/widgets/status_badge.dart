import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String text;
  final Color? textColor;
  final Color? backgroundColor;

  const StatusBadge({
    super.key,
    required this.text,
    this.textColor,
    this.backgroundColor,
  });

  factory StatusBadge.forStatus(String status) {
    Color bg;
    Color fg;
    switch (status.toLowerCase()) {
      case 'pending':
        bg = const Color(0xFFFEF3E2);
        fg = const Color(0xFFB47214);
        break;
      case 'seated':
        bg = const Color(0xFFE8F0FE);
        fg = const Color(0xFF1A73E8);
        break;
      case 'confirmed':
      case 'completed':
        bg = const Color(0xFFE8F5F1);
        fg = const Color(0xFF166359);
        break;
      case 'no-show':
      case 'noshow':
        bg = const Color(0xFFF1F3F4);
        fg = const Color(0xFF5F6368);
        break;
      case 'cancelled':
        bg = const Color(0xFFFCE8E6);
        fg = const Color(0xFFD93025);
        break;
      default:
        bg = const Color(0xFFF1F3F4);
        fg = const Color(0xFF333333);
    }

    final String formatted;
    if (status.toLowerCase() == 'noshow' || status.toLowerCase() == 'no-show') {
      formatted = 'No-show';
    } else if (status.isEmpty) {
      formatted = '';
    } else {
      formatted = status[0].toUpperCase() + status.substring(1).toLowerCase();
    }
    return StatusBadge(text: formatted, textColor: fg, backgroundColor: bg);
  }

  @override
  Widget build(BuildContext context) {
    final fg = textColor ?? const Color(0xFF166359);
    final bg = backgroundColor ?? const Color(0xFFE8F5F1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }
}
