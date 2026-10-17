import 'package:flutter/material.dart';

import '../../model/customer.dart';
import '../../model/reservation.dart';
import '../../model/restaurant.dart';
import '../widgets/theme.dart';
import '../widgets/filter_dropdown.dart';
import 'booking_screen.dart';
import 'reservation_screen.dart';

class RestaurantScreen extends StatefulWidget {
  final List<Restaurant> restaurants;
  final List<Reservation> reservations;
  final Customer customer;
  final DateTime? now;

  const RestaurantScreen({
    super.key,
    required this.restaurants,
    required this.reservations,
    required this.customer,
    this.now,
  });

  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  String? selectedType;

  List<String> get types {
    List<String> result = [];
    for (Restaurant restaurant in widget.restaurants) {
      if (!result.contains(restaurant.type)) {
        result.add(restaurant.type);
      }
    }
    return result;
  }

  List<Restaurant> get filteredRestaurants {
    List<Restaurant> result = [];
    for (Restaurant restaurant in widget.restaurants) {
      if (selectedType == null || restaurant.type == selectedType) {
        result.add(restaurant);
      }
    }
    return result;
  }

  void onFilterChanged(String? type) {
    setState(() {
      selectedType = type;
    });
  }

  void onOpenReservations() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReservationScreen(
          reservations: widget.reservations,
          customer: widget.customer,
        ),
      ),
    );
  }

  void onRestaurantSelected(Restaurant restaurant) async {
    Reservation? newReservation = await Navigator.of(context).push<Reservation>(
      MaterialPageRoute(
        builder: (context) => BookingScreen(
          restaurant: restaurant,
          reservations: widget.reservations,
          customer: widget.customer,
          now: widget.now,
        ),
      ),
    );

    if (newReservation != null) {
      setState(() {
        widget.reservations.add(newReservation);
      });
      onOpenReservations();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Restaurant> restaurants = filteredRestaurants;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurants'),
        actions: [
          IconButton(
            onPressed: onOpenReservations,
            tooltip: 'My reservations',
            icon: const Icon(Icons.calendar_today_outlined),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            FilterDropdown<String>(
              label: 'Type',
              selected: selectedType,
              values: types,
              labelOf: (type) => type,
              onSelected: onFilterChanged,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: restaurants.length,
                itemBuilder: (context, index) => RestaurantTile(
                  restaurant: restaurants[index],
                  onTap: () => onRestaurantSelected(restaurants[index]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RestaurantTile extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantTile({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.restaurant, color: AppColors.teal),
        title: Text(restaurant.name),
        subtitle: Text(
          '${restaurant.type} · ${restaurant.openingHour}:00 - ${restaurant.closingHour}:00',
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }
}
