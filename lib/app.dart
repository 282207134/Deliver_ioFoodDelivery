import 'package:flutter/material.dart';

import 'core/theme.dart';
import 'data/app_store.dart';
import 'data/catalog.dart';
import 'features/auth/auth_screens.dart';
import 'features/browse/browse_screens.dart';
import 'features/orders/order_screens.dart';
import 'features/account/account_screens.dart';

final navigatorKey = GlobalKey<NavigatorState>();

class DeliverApp extends StatelessWidget {
  const DeliverApp({super.key, required this.store, this.initialRoute = '/'});
  final AppStore store;
  final String initialRoute;
  @override
  Widget build(BuildContext context) => StoreScope(
    store: store,
    child: MaterialApp(
      title: 'Deliver.io',
      debugShowCheckedModeBanner: false,
      theme: appTheme(),
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      onGenerateInitialRoutes: (name) => [
        buildRoute(RouteSettings(name: name)),
      ],
      onGenerateRoute: buildRoute,
    ),
  );

  Route<Object?> buildRoute(RouteSettings settings) {
    final args = settings.arguments;
    final Widget screen = switch (settings.name) {
      '/' => const SplashScreen(),
      '/splash' => const SplashScreen(automatic: false),
      '/login' => const AuthScreen(),
      '/register' => const AuthScreen(register: true),
      '/country' => const CountryScreen(),
      '/sms' => const SmsScreen(),
      '/sms-error' => const SmsScreen(initialError: true),
      '/sms-change' => const SmsScreen(changePhone: true),
      '/onboarding' => OnboardingScreen(initialPage: args is int ? args : 0),
      '/home' => HomeShell(initialTab: args is int ? args : 0),
      '/restaurants' => const RestaurantListScreen(),
      '/popular' => const RestaurantListScreen(popular: true),
      '/restaurant' => RestaurantScreen(
        restaurant: args is Restaurant ? args : restaurants.first,
      ),
      '/product' => ProductScreen(food: args is Food ? args : foods[7]),
      '/search-action' => const SearchActionScreen(),
      '/search-food' => const Scaffold(
        body: SafeArea(child: SearchScreen(initialFood: true)),
      ),
      '/search-results' => Scaffold(
        body: SafeArea(
          child: SearchScreen(query: args is String ? args : 'Steak'),
        ),
      ),
      '/orders-history' => const Scaffold(
        body: SafeArea(child: OrdersScreen(initialHistory: true)),
      ),
      '/cart' => const CartScreen(),
      '/payment' => const PaymentScreen(),
      '/success' => const PaymentResultScreen(success: true),
      '/failure' => const PaymentResultScreen(success: false),
      '/tracker' => const TrackerScreen(),
      '/rate' => const RatingScreen(),
      '/profile-edit' => const ProfileEditScreen(),
      '/notifications' => const NotificationScreen(),
      '/cards' => CardsScreen(select: args == true),
      '/cards-edit' => const CardsScreen(initialEdit: true),
      '/add-card' => const AddCardScreen(),
      '/scan-card' => const ScanCardScreen(),
      '/addresses' => AddressesScreen(select: args == true),
      '/address-edit' => AddressEditScreen(index: args is int ? args : 0),
      '/address-new' => AddressEditScreen(street: args is String ? args : null),
      '/location' => const LocationScreen(),
      '/location-add' => const LocationScreen(add: true),
      '/location-find' => const LocationScreen(find: true),
      '/map' => const MapScreen(),
      '/refer' => const ReferScreen(),
      '/faq' => const FaqScreen(),
      _ => const HomeShell(),
    };
    return MaterialPageRoute<Object?>(
      settings: settings,
      builder: (_) => screen,
    );
  }
}
