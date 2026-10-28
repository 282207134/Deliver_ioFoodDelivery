import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_io/data/app_store.dart';
import 'package:deliver_io/data/catalog.dart';

void main() {
  late AppStore store;
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    store = AppStore(await SharedPreferences.getInstance());
  });
  test('Cart quantities, totals, discount and removal are consistent', () {
    store.add(foods[2]);
    expect(store.subtotal, 25);
    expect(store.total, 22);
    store.add(foods[0], 2);
    expect(store.count, 3);
    expect(store.subtotal, 65);
    expect(store.discount, 0);
    store.changeQuantity('schnitzel', -1);
    expect(store.cart.containsKey('schnitzel'), false);
    store.changeQuantity('ribs', -2);
    expect(store.cart, isEmpty);
  });
  test(
    'Payment snapshots cart and re-order restores independent quantities',
    () {
      store.add(foods[0], 2);
      store.placeOrder();
      expect(store.cart, isEmpty);
      expect(store.orders.single.total, 40);
      store.reorder(store.orders.single);
      store.changeQuantity('ribs', 1);
      expect(store.orders.single.items['ribs'], 2);
      expect(store.cart['ribs'], 3);
    },
  );
  test('Profile, preferences, addresses, cards and orders survive reload', () {
    store.name = 'Test Person';
    store.notifications[0] = true;
    store.cards.add('7488');
    store.selectedAddress = 2;
    store.add(foods[2]);
    store.placeOrder();
    final restored = AppStore(store.preferences)..restore();
    expect(restored.name, 'Test Person');
    expect(restored.notifications.first, true);
    expect(restored.cards, ['7488']);
    expect(restored.address.name, 'My job');
    expect(restored.orders.single.total, 22);
  });
  test('Malformed saved JSON falls back to usable defaults', () async {
    await store.preferences.setString('deliver_io', '{bad json');
    store.restore();
    expect(store.address.name, 'Home');
    expect(store.cart, isEmpty);
  });
}
