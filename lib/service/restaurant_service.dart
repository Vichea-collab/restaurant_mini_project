import '../model/customer.dart';
import '../model/restaurant.dart';
import '../model/table.dart';

class RestaurantService {
  final List<Restaurant> restaurants = [];
  final List<Customer> customers = [];

  RestaurantService({
    String? restaurantId,
    String? restaurantName,
    int? openingHour,
    int? closingHour,
    int maxLateMinutes = 20,
  }) {
    if (restaurantName != null && openingHour != null && closingHour != null) {
      addRestaurant(
        restaurantId: restaurantId ?? 'RST1',
        name: restaurantName,
        openingHour: openingHour,
        closingHour: closingHour,
        maxLateMinutes: maxLateMinutes,
      );
    }
  }

  Restaurant get restaurant {
    if (restaurants.isEmpty) {
      throw Exception('No restaurants available in the service');
    }
    return restaurants.first;
  }

  List<Table> get tables => restaurants.expand((r) => r.tables).toList();

  void addRestaurant({
    required String restaurantId,
    required String name,
    required int openingHour,
    required int closingHour,
    String type = 'Other',
    int maxLateMinutes = 20,
  }) {
    if (findRestaurantOrNull(restaurantId) != null) {
      throw Exception('Restaurant $restaurantId already exists');
    }
    restaurants.add(
      Restaurant(
        id: restaurantId,
        name: name,
        type: type,
        openingHour: openingHour,
        closingHour: closingHour,
        maxLateMinutes: maxLateMinutes,
      ),
    );
  }

  void addTable({
    String? restaurantId,
    required int tableId,
    required int seats,
    TableLocation location = TableLocation.indoor,
  }) {
    Restaurant r = resolveRestaurant(restaurantId);
    Table? table = findTableInRestaurantOrNull(r, tableId);
    if (table != null) {
      throw Exception('Table $tableId already exists in restaurant ${r.id}');
    }

    if (seats <= 0) {
      throw Exception('Table seats must be greater than zero');
    }

    r.tables.add(Table(id: tableId, seats: seats, location: location));
  }

  void addCustomer({
    required String customerId,
    required String name,
    required String phone,
  }) {
    Customer? customer = findCustomerOrNull(customerId);
    if (customer != null) {
      throw Exception('Customer $customerId already exists');
    }

    customers.add(Customer(id: customerId, name: name, phone: phone));
  }

  void removeCustomer({required String customerId}) {
    findCustomer(customerId);

    customers.removeWhere((c) => c.id == customerId);
  }

  bool hasTableForLocation({
    String? restaurantId,
    required TableLocation location,
    required int guest,
  }) {
    Restaurant r = resolveRestaurant(restaurantId);
    for (Table t in r.tables) {
      if (t.location == location && t.canSeat(guest)) {
        return true;
      }
    }
    return false;
  }

  List<String> getTypes() {
    List<String> result = [];
    for (Restaurant r in restaurants) {
      if (!result.contains(r.type)) {
        result.add(r.type);
      }
    }
    return result;
  }

  List<Restaurant> getRestaurantsForType(String? type) {
    List<Restaurant> result = [];
    for (Restaurant r in restaurants) {
      if (type == null || r.type == type) {
        result.add(r);
      }
    }
    return result;
  }

  String getRestaurantName(String restaurantId) {
    return findRestaurant(restaurantId).name;
  }

  String getTableLocationName(String restaurantId, int tableId) {
    Restaurant r = findRestaurant(restaurantId);
    Table t = findTableInRestaurant(r, tableId);
    String name = t.location.name;
    return '${name[0].toUpperCase()}${name.substring(1)}';
  }

  Customer getCustomer(String customerId) {
    return findCustomer(customerId);
  }

  Restaurant resolveRestaurant(String? restaurantId) {
    if (restaurantId != null) {
      return findRestaurant(restaurantId);
    }
    return restaurant;
  }

  Restaurant findRestaurant(String restaurantId) {
    Restaurant? r = findRestaurantOrNull(restaurantId);
    if (r == null) {
      throw Exception('Restaurant $restaurantId not found');
    }
    return r;
  }

  Restaurant? findRestaurantOrNull(String restaurantId) {
    for (Restaurant r in restaurants) {
      if (r.id == restaurantId) {
        return r;
      }
    }
    return null;
  }

  Table findTableInRestaurant(Restaurant r, int tableId) {
    Table? table = findTableInRestaurantOrNull(r, tableId);
    if (table == null) {
      throw Exception('Table $tableId not found in restaurant ${r.id}');
    }
    return table;
  }

  Table? findTableInRestaurantOrNull(Restaurant r, int tableId) {
    for (Table t in r.tables) {
      if (t.id == tableId) {
        return t;
      }
    }
    return null;
  }

  Customer findCustomer(String customerId) {
    Customer? customer = findCustomerOrNull(customerId);
    if (customer == null) {
      throw Exception('Customer $customerId not found');
    }
    return customer;
  }

  Customer? findCustomerOrNull(String customerId) {
    for (Customer c in customers) {
      if (c.id == customerId) {
        return c;
      }
    }
    return null;
  }
}
