import 'package:flutter/material.dart';

class FilterDropdown<T> extends StatelessWidget {
  final String label;
  final T? selected;
  final List<T> values;
  final String Function(T value) labelOf;
  final ValueChanged<T?> onSelected;

  const FilterDropdown({
    super.key,
    required this.label,
    required this.selected,
    required this.values,
    required this.labelOf,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<T?>(
      initialSelection: selected,
      label: Text(label),
      expandedInsets: EdgeInsets.zero,
      onSelected: onSelected,
      dropdownMenuEntries: [
        DropdownMenuEntry<T?>(value: null, label: 'All'),
        for (final value in values)
          DropdownMenuEntry<T?>(value: value, label: labelOf(value)),
      ],
    );
  }
}
