import 'package:flutter/material.dart';

import '../../service/restaurant_service.dart';
import '../widgets/theme.dart';
import '../widgets/app_card.dart';
import '../widgets/filter_bar.dart';

class HomeScreen extends StatefulWidget {
  final RestaurantService service;

  const HomeScreen({super.key, required this.service});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedFilter = 'All';

  List<String> get filterOptions {
    List<String> options = ['All'];
    options.addAll(widget.service.getTypes());
    return options;
  }

  void onFilterChanged(String option) {
    setState(() {
      selectedFilter = option;
    });
  }

  @override
  Widget build(BuildContext context) {
    String? type;
    if (selectedFilter != 'All') {
      type = selectedFilter;
    }
    final restaurants = widget.service.getRestaurantsForType(type);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Restaurants',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.text,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          FilterBar(
            options: filterOptions,
            selectedOption: selectedFilter,
            onSelected: onFilterChanged,
          ),
          const SizedBox(height: 16),
          for (final restaurant in restaurants)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AppCard(
                leading: const Icon(
                  Icons.restaurant,
                  color: AppColors.teal,
                  size: 28,
                ),
                title: restaurant.name,
                subtitle:
                    '${restaurant.type} · ${restaurant.openingHour}:00 - ${restaurant.closingHour}:00',
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.hint,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
