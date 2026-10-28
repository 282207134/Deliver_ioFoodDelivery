import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_io/app.dart';
import 'package:deliver_io/data/app_store.dart';
import 'package:deliver_io/data/catalog.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  Future<AppStore> launch(WidgetTester tester, {String route = '/home'}) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final store = AppStore(await SharedPreferences.getInstance());
    await tester.pumpWidget(DeliverApp(store: store, initialRoute: route));
    await tester.pumpAndSettle();
    return store;
  }

  testWidgets(
    'Browse → add to cart → checkout → success creates active order',
    (tester) async {
      final store = await launch(tester);
      await tester.tap(find.text("Friendly's").first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('\$20').first);
      await tester.pumpAndSettle();
      expect(store.count, 1);
      await tester.tap(find.text('Your order · 1 items   \$20'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Place an order \$20'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Apple pay'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Confirm payment'));
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
      expect(find.text('Congratulations!'), findsOneWidget);
      expect(store.cart, isEmpty);
      expect(store.orders.length, 1);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets(
    'Login validates phone and rejects incorrect SMS before onboarding',
    (tester) async {
      await launch(tester, route: '/login');
      await tester.tap(find.text('Continue').first);
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid phone number'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('phone')), '2125071690');
      FocusManager.instance.primaryFocus?.unfocus();
      await tester.pumpAndSettle();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 600)),
      );
      await tester.ensureVisible(find.text('Continue').first);
      await tester.tap(find.text('Continue').first);
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('sms_code')), '0000');
      await tester.pumpAndSettle();
      expect(find.text('The code was entered incorrectly'), findsOneWidget);
      await tester.enterText(find.byKey(const Key('sms_code')), '1234');
      await tester.pumpAndSettle();
      expect(
        find.text('Order from your favourite\nstores or vendors'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('All independent routes render at small phone width', (
    tester,
  ) async {
    final s = await launch(tester);
    s.add(foods[2]);
    s.cards.addAll(['7488', '1235']);
    for (final route in [
      '/register',
      '/country',
      '/sms-error',
      '/restaurant',
      '/popular',
      '/product',
      '/search-action',
      '/search-results',
      '/search-food',
      '/orders-history',
      '/cart',
      '/payment',
      '/success',
      '/failure',
      '/tracker',
      '/rate',
      '/profile-edit',
      '/cards',
      '/cards-edit',
      '/add-card',
      '/scan-card',
      '/addresses',
      '/address-edit',
      '/address-new',
      '/location',
      '/location-add',
      '/location-find',
      '/map',
      '/refer',
      '/notifications',
      '/faq',
    ]) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil(route, (_) => false);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull, reason: route);
    }
  });
}
