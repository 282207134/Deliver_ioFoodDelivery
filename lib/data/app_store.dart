import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'catalog.dart';

/// One local demo repository. No card number or verification code is persisted.
class AppStore extends ChangeNotifier {
  AppStore(this.preferences);
  final SharedPreferences preferences;
  bool signedIn = false;
  String name = 'Nikita Ogurechnikov', email = 'ogurechnikovn93@gmail.com';
  String phone = '212 507 1690', countryCode = '+1';
  Map<String, int> cart = {};
  List<DeliveryAddress> addresses = [
    const DeliveryAddress(
      name: 'Home',
      street: '3517 W. Gray St. Utica, Pennsylvania 57867',
      entrance: '3',
      apartment: '114',
      floor: '12',
    ),
    const DeliveryAddress(
      name: 'John Friend',
      street: '6391 Elgin St. Celina, Delaware 10299',
    ),
    const DeliveryAddress(
      name: 'My job',
      street: '3891 Ranchview Dr. Richardson, California 62639',
    ),
  ];
  int selectedAddress = 0;
  List<String> cards = [];
  String payment = 'Apple Pay';
  List<bool> notifications = [false, true, false];
  List<String> searches = [
    'Amuse-bouche',
    'Confiserie',
    'Entrée',
    'Plat principal',
  ];
  List<SavedOrder> orders = [];
  DeliveryAddress get address =>
      addresses[selectedAddress.clamp(0, addresses.length - 1)];
  int get count => cart.values.fold(0, (a, b) => a + b);
  int get subtotal =>
      cart.entries.fold(0, (a, e) => a + foodById(e.key).price * e.value);
  int get discount => count == 1 ? 3 : 0;
  int get total => subtotal - discount;

  void restore() {
    final raw = preferences.getString('deliver_io');
    if (raw == null) return;
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      signedIn = j['signedIn'] as bool? ?? false;
      name = j['name'] as String? ?? name;
      email = j['email'] as String? ?? email;
      phone = j['phone'] as String? ?? phone;
      countryCode = j['countryCode'] as String? ?? countryCode;
      cart = Map<String, int>.from(j['cart'] as Map? ?? {});
      cart.removeWhere(
        (key, value) => value < 1 || !foods.any((f) => f.id == key),
      );
      final savedAddresses = (j['addresses'] as List? ?? [])
          .map(
            (a) =>
                DeliveryAddress.fromJson(Map<String, dynamic>.from(a as Map)),
          )
          .toList();
      if (savedAddresses.isNotEmpty) addresses = savedAddresses;
      selectedAddress = (j['selectedAddress'] as int? ?? 0).clamp(
        0,
        addresses.length - 1,
      );
      cards = List<String>.from(j['cards'] as List? ?? []);
      payment = j['payment'] as String? ?? 'Apple Pay';
      final settings = List<bool>.from(j['notifications'] as List? ?? []);
      if (settings.length == 3) notifications = settings;
      searches = List<String>.from(j['searches'] as List? ?? searches);
      orders = (j['orders'] as List? ?? [])
          .map((o) => SavedOrder.fromJson(Map<String, dynamic>.from(o as Map)))
          .toList();
    } on FormatException {
      preferences.remove('deliver_io');
    } on TypeError {
      preferences.remove('deliver_io');
    }
  }

  void commit() {
    preferences.setString(
      'deliver_io',
      jsonEncode({
        'signedIn': signedIn,
        'name': name,
        'email': email,
        'phone': phone,
        'countryCode': countryCode,
        'cart': cart,
        'addresses': addresses.map((a) => a.toJson()).toList(),
        'selectedAddress': selectedAddress,
        'cards': cards,
        'payment': payment,
        'notifications': notifications,
        'searches': searches,
        'orders': orders.map((o) => o.toJson()).toList(),
      }),
    );
    notifyListeners();
  }

  void add(Food food, [int quantity = 1]) {
    cart[food.id] = (cart[food.id] ?? 0) + quantity;
    commit();
  }

  void changeQuantity(String id, int delta) {
    final next = (cart[id] ?? 0) + delta;
    if (next <= 0) {
      cart.remove(id);
    } else {
      cart[id] = next;
    }
    commit();
  }

  void placeOrder() {
    if (cart.isEmpty) return;
    orders.insert(0, SavedOrder(items: Map.of(cart), paidTotal: total));
    cart.clear();
    commit();
  }

  void reorder(SavedOrder order) {
    cart = Map.of(order.items);
    commit();
  }

  void search(String value) {
    if (value.trim().isEmpty) return;
    searches.remove(value);
    searches.insert(0, value);
    commit();
  }
}

class StoreScope extends InheritedNotifier<AppStore> {
  const StoreScope({super.key, required AppStore store, required super.child})
    : super(notifier: store);
  static AppStore of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<StoreScope>()!.notifier!;
}
