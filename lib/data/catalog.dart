class Food {
  const Food(
    this.id,
    this.name,
    this.grams,
    this.price,
    this.image,
    this.category, {
    this.description = 'Freshly prepared with carefully selected ingredients, herbs and spices. Served just the way you like it.',
  });
  final String id, name, image, category, description;
  final int grams, price;
}

const foods = [
  Food('ribs', 'Grilled pork ribs barbecue', 320, 20, 'ribs', 'Barbecue'),
  Food(
    'knuckle',
    'Pork knuckle with crispy crust',
    350,
    40,
    'knuckle',
    'Steak',
  ),
  Food('schnitzel', 'Viennese pork schnitzel', 250, 25, 'schnitzel', 'Steak'),
  Food('kebab', 'Pork shish kebab with bacon', 300, 32, 'kebab', 'Barbecue'),
  Food('squid', "Commander's grilled squid", 200, 40, 'squid', 'Sushi'),
  Food('salmon', 'Salmon fillet', 320, 32, 'salmon', 'Sushi'),
  Food('salad', 'Salad with roasted beef', 350, 20, 'salad', 'Steak'),
  Food(
    'soup',
    'Hungarian goulash soup',
    220,
    24,
    'soup',
    'All',
    description: 'Thick soup with spicy spice with bell peppers, potatoes, beef, onions, carrots and garlic',
  ),
  Food('pizza', 'Margherita pizza', 380, 18, 'ribs', 'Pizza'),
  Food('burger', 'Burger with chopped steak', 280, 20, 'burger', 'Burger'),
  Food('pasta', 'Spezle carbonara', 260, 17, 'pasta', 'Pasta'),
  Food('donut', 'Classic ice cream with fillers', 160, 10, 'icecream', 'Donut'),
  Food('rolls', 'Salmon avocado rolls', 220, 22, 'salmon', 'Rolls'),
];

class Restaurant {
  const Restaurant(
    this.name,
    this.rating,
    this.distance,
    this.minutes,
    this.image, {
    this.free = false,
    this.closed = false,
  });
  final String name, image;
  final double rating, distance;
  final int minutes;
  final bool free, closed;
}

const restaurants = [
  Restaurant("Friendly's", 4.5, 1.3, 30, 'restaurant1', free: true),
  Restaurant('Planet Hollywood', 4.3, 1.5, 40, 'restaurant2', closed: true),
  Restaurant('LongHorn Steakhouse', 4.5, .9, 18, 'restaurant3'),
  Restaurant('Scores', 5, 1.3, 30, 'restaurant4'),
  Restaurant(
    "Charlie Brown's Steakhouse",
    4.9,
    1.5,
    40,
    'restaurant5',
    closed: true,
  ),
  Restaurant('Red Robin', 4.8, .9, 18, 'restaurant1', free: true),
];

const categories = [
  'Pizza',
  'Sushi',
  'Barbecue',
  'Burger',
  'Rolls',
  'Donut',
  'Steak',
  'Pasta',
];
Food foodById(String id) =>
    foods.firstWhere((f) => f.id == id, orElse: () => foods.first);

class DeliveryAddress {
  const DeliveryAddress({
    required this.name,
    required this.street,
    this.entrance = '',
    this.apartment = '',
    this.floor = '',
    this.comment = '',
  });
  final String name, street, entrance, apartment, floor, comment;
  Map<String, dynamic> toJson() => {
    'name': name,
    'street': street,
    'entrance': entrance,
    'apartment': apartment,
    'floor': floor,
    'comment': comment,
  };
  factory DeliveryAddress.fromJson(Map<String, dynamic> j) => DeliveryAddress(
    name: j['name'] as String,
    street: j['street'] as String,
    entrance: j['entrance'] as String? ?? '',
    apartment: j['apartment'] as String? ?? '',
    floor: j['floor'] as String? ?? '',
    comment: j['comment'] as String? ?? '',
  );
}

class SavedOrder {
  SavedOrder({
    required this.items,
    this.delivered = false,
    this.canceled = false,
    this.paidTotal,
  });
  final Map<String, int> items;
  final bool delivered, canceled;
  final int? paidTotal;
  int get total =>
      paidTotal ??
      items.entries.fold(0, (sum, e) => sum + foodById(e.key).price * e.value);
  Map<String, dynamic> toJson() => {
    'items': items,
    'delivered': delivered,
    'canceled': canceled,
    'paidTotal': paidTotal,
  };
  factory SavedOrder.fromJson(Map<String, dynamic> j) => SavedOrder(
    items: Map<String, int>.from(j['items'] as Map),
    delivered: j['delivered'] as bool? ?? false,
    canceled: j['canceled'] as bool? ?? false,
    paidTotal: j['paidTotal'] as int?,
  );
}
