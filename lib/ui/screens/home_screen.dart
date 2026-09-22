import 'package:flutter/material.dart' hide Table;

import '../../service/restaurant_service.dart';
import '../widgets/filter_pill.dart';
import '../widgets/restaurant_card.dart';

class HomeScreen extends StatelessWidget {
  final RestaurantService service;
  final String customerId;

  const HomeScreen({
    super.key,
    required this.service,
    this.customerId = 'C103',
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Restaurants',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E232A),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        children: [
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const TextField(
              decoration: InputDecoration(
                hintText: 'Search restaurants...',
                hintStyle: TextStyle(color: Color(0xFF9CA3AF), fontSize: 14),
                prefixIcon: Icon(
                  Icons.search,
                  color: Color(0xFF9CA3AF),
                  size: 20,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(vertical: 14),
              ),
              style: TextStyle(fontSize: 14, color: Color(0xFF1E232A)),
            ),
          ),
          const SizedBox(height: 14),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                FilterPill(
                  text: 'All · ${service.restaurants.length}',
                  isSelected: true,
                ),
                const SizedBox(width: 8),
                const FilterPill(text: 'Fine Dining', isSelected: false),
                const SizedBox(width: 8),
                const FilterPill(text: 'Japanese', isSelected: false),
                const SizedBox(width: 8),
                const FilterPill(text: 'Italian', isSelected: false),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final restaurant in service.restaurants)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: RestaurantCard(restaurant: restaurant),
            ),
        ],
      ),
    );
  }
}
