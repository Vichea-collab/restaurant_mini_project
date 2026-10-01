import 'package:flutter/material.dart';

import 'theme.dart';

class GuestStepper extends StatelessWidget {
  final int guestCount;
  final bool canMinus;
  final VoidCallback onMinus;
  final VoidCallback onAdd;

  const GuestStepper({
    super.key,
    required this.guestCount,
    required this.canMinus,
    required this.onMinus,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Guest',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textMedium,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.border),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  Icons.remove,
                  size: 20,
                  color: canMinus ? AppColors.text : Colors.grey,
                ),
                onPressed: canMinus ? onMinus : null,
              ),
              Text(
                '$guestCount',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.add, size: 20, color: AppColors.text),
                onPressed: onAdd,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
