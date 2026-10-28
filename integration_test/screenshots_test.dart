import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_io/app.dart';
import 'package:deliver_io/data/app_store.dart';
import 'package:deliver_io/data/catalog.dart';

class Capture {
  const Capture(
    this.name,
    this.route, {
    this.argument,
    this.field,
    this.text = '',
  });
  final String name, route, text;
  final Object? argument;
  final String? field;
}

void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  testWidgets(
    'Pixso and supplemental screens render on Android and are captured',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final store = AppStore(await SharedPreferences.getInstance());
      await tester.pumpWidget(DeliverApp(store: store, initialRoute: '/home'));
      await tester.pumpAndSettle();
      await binding.convertFlutterSurfaceToImage();
      const captures = [
        Capture('01_1_login', '/login'),
        Capture(
          '02_1_login_enter_phone_number',
          '/login',
          field: "phone",
          text: "212 507 1690",
        ),
        Capture('03_2_registration', '/register'),
        Capture(
          '04_2_registration_select_country_code',
          '/country',
          field: "Search",
        ),
        Capture('05_1_login_enter_sms_code', '/sms'),
        Capture(
          '06_1_login_enter_error_sms_code',
          '/sms-error',
          field: "SMS Code",
          text: "0000",
        ),
        Capture('07_2_onboarding1', '/onboarding', argument: 0),
        Capture('08_2_onboarding2', '/onboarding', argument: 1),
        Capture('09_2_onboarding3', '/onboarding', argument: 2),
        Capture(
          '10_home_screen',
          '/home',
          argument: null,
          field: null,
          text: "",
        ),
        Capture(
          '11_find_restaurants_near_you',
          '/location-find',
          field: "location",
          text: "San frans",
        ),
        Capture('12_full_home_screen', '/home'),
        Capture(
          '13_popular',
          '/popular',
          argument: null,
          field: null,
          text: "",
        ),
        Capture('14_my_orders_empty_screen', '/home', argument: 1),
        Capture('15_my_orders_history', '/orders-history'),
        Capture('16_my_orders_active_full', '/home', argument: 1),
        Capture(
          '17_my_orders_active_full_a_lot_of_dishes',
          '/home',
          argument: 1,
        ),
        Capture('18_my_orders_tracker_screen', '/tracker'),
        Capture('19_rate_food_screen', '/rate'),
        Capture(
          '20_rate_food_screen_typing',
          '/rate',
          field: "review",
          text: "Fast delivery and great food, thank you for such a great restaurant!",
        ),
        Capture('21_notification_settings', '/notifications'),
        Capture('22_payment_method_empty', '/cards'),
        Capture('23_payment_method_full', '/cards'),
        Capture('24_payment_method_edit', '/cards-edit'),
        Capture('25_add_credit_card', '/add-card'),
        Capture('26_scan_your_card', '/scan-card'),
        Capture('27_profile_information', '/profile-edit'),
        Capture(
          '28_profile_information',
          '/profile-edit',
          field: "Enter your phone",
          text: "212 507 1690",
        ),
        Capture('29_profile_information_change_phone', '/sms-change'),
        Capture('30_address', '/addresses'),
        Capture('31_refer_to_friends', '/refer'),
        Capture('32_address_information', '/address-edit'),
        Capture('33_restaurant_page', '/restaurant'),
        Capture('34_product_detail_screen', '/product'),
        Capture('35_succes_payment', '/success'),
        Capture('36_failed_payment', '/failure'),
        Capture('37_search', '/home', argument: 2, field: null, text: ""),
        Capture('38_search', '/search-food'),
        Capture('39_search_action', '/search-action', field: "search"),
        Capture('40_search_result_food', '/search-results', argument: "Steak"),
        Capture('41_profile', '/home', argument: 3, field: null, text: ""),
        Capture('42_cart', '/cart', argument: null, field: null, text: ""),
        Capture('43_cart_a_lot_of_dishes', '/cart'),
        Capture(
          '44_payment',
          '/payment',
          argument: null,
          field: null,
          text: "",
        ),
        Capture('45_payment_a_lot_of_dishes', '/payment'),
        Capture(
          '46_change_address',
          '/location',
          field: "location",
          text: "San frans",
        ),
        Capture('47_map_add_address', '/map'),
        Capture(
          '48_change_address',
          '/location-add',
          field: "location",
          text: "San frans",
        ),
        Capture('49_change_address', '/addresses', argument: true),
        Capture('50_payment_method_full', '/cards', argument: true),
        Capture('51_loading_screen', '/splash'),
        Capture('52_faq', '/faq'),
        Capture(
          '53_add_address',
          '/address-new',
          argument: 'San Francisco, California',
        ),
        Capture('54_restaurant_list', '/restaurants'),
      ];
      for (var i = 0; i < captures.length; i++) {
        final spec = captures[i];
        const only = String.fromEnvironment('CAPTURE_ONLY');
        if (only.isNotEmpty &&
            !only.split(',').contains(spec.name.substring(0, 2))) {
          continue;
        }
        store.cart.clear();
        store.cards.clear();
        store.orders.clear();
        if ([15, 16, 41, 43].contains(i)) store.cart = {'schnitzel': 1};
        if ([16, 42, 44].contains(i)) {
          store.cart = {'donut': 1, 'pasta': 1, 'burger': 1, 'schnitzel': 1};
        }
        if (i == 14) {
          store.orders = [
            SavedOrder(items: {'schnitzel': 1, 'ribs': 1}, delivered: true),
            SavedOrder(items: {'squid': 1, 'salad': 1}, canceled: true),
          ];
        }
        if ([15, 16].contains(i)) {
          store.orders = [
            SavedOrder(items: {'schnitzel': 1, 'ribs': 1}),
          ];
        }
        if ([22, 23, 49].contains(i)) store.cards = ['7488', '1235'];
        store.commit();
        navigatorKey.currentState!.pushNamedAndRemoveUntil(
          spec.route,
          (_) => false,
          arguments: spec.argument,
        );
        await tester.pumpAndSettle();
        if (spec.field != null) {
          final keyed = find.byKey(Key(spec.field!));
          final field = keyed.evaluate().isNotEmpty
              ? keyed
              : find.byType(TextField).first;
          await tester.ensureVisible(field);
          await tester.tap(field);
          if (spec.text.isNotEmpty) await tester.enterText(field, spec.text);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull, reason: spec.name);
        // Android rasterization and native keyboard transitions complete after the
        // widget tree has settled. Wait for those before capturing the surface.
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 800)),
        );
        for (var frame = 0; frame < 12; frame++) {
          await tester.pump(const Duration(milliseconds: 40));
        }
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)),
        );
        // This also refreshes Android's converted FlutterImageView. The native
        // screen must be read afterwards or it can contain the previous route.
        await binding.takeScreenshot(spec.name);
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 200)),
        );
        debugPrint('NATIVE_CAPTURE:${spec.name}');
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 800)),
        );
        debugPrint('Captured ${i + 1}/${captures.length}: ${spec.name}');
        FocusManager.instance.primaryFocus?.unfocus();
        await tester.pumpAndSettle();
      }
      navigatorKey.currentState!.pushNamedAndRemoveUntil('/home', (_) => false);
      await tester.pumpAndSettle();
    },
  );
}
