import 'package:flutter/material.dart';

import 'theme.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;

  const AppButton({super.key, required this.text, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.teal,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        onPressed: onPressed,
        child: Text(
          text,
          style: const TextStyle(fontSize: 15, color: Colors.white),
        ),
      ),
    );
  }
}
