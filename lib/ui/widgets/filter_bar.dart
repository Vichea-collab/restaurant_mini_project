import 'package:flutter/material.dart';

import 'theme.dart';

class FilterBar extends StatelessWidget {
  final List<String> options;
  final String selectedOption;
  final ValueChanged<String> onSelected;

  const FilterBar({
    super.key,
    required this.options,
    required this.selectedOption,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final option in options)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => onSelected(option),
                hoverColor: Colors.transparent,
                borderRadius: BorderRadius.circular(20),
                child: Ink(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: option == selectedOption
                        ? AppColors.teal
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: option == selectedOption
                          ? AppColors.teal
                          : AppColors.border,
                    ),
                  ),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: option == selectedOption
                          ? FontWeight.w600
                          : FontWeight.normal,
                      color: option == selectedOption
                          ? Colors.white
                          : AppColors.textMedium,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
