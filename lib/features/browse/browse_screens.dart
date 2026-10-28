import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../../data/catalog.dart';
import '../orders/order_screens.dart';
import '../account/account_screens.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, this.initialTab = 0});
  final int initialTab;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int tab = widget.initialTab;
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(
          index: tab,
          children: const [
            HomeScreen(),
            OrdersScreen(),
            SearchScreen(),
            ProfileScreen(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          height: 60,
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color(0x06000000),
                blurRadius: 16,
                offset: Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: List.generate(4, (i) {
              final selected = i == tab;
              const icons = [
                CupertinoIcons.house,
                CupertinoIcons.cart,
                CupertinoIcons.search,
                CupertinoIcons.person_circle,
              ];
              const labels = ['Home', 'Cart', 'Search', 'Profile'];
              return Expanded(
                child: InkWell(
                  key: Key('tab_$i'),
                  onTap: () => setState(() => tab = i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Badge(
                        isLabelVisible: i == 1 && store.count > 0,
                        label: Text('${store.count}'),
                        backgroundColor: Palette.orange,
                        child: Icon(
                          icons[i],
                          color: selected
                              ? Palette.orange
                              : const Color(0xFFA9AAAE),
                          size: 27,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        labels[i],
                        style: TextStyle(
                          fontSize: 10,
                          color: selected
                              ? Palette.orange
                              : const Color(0xFFA9AAAE),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
    children: [
      InkWell(
        onTap: () => go(context, '/location'),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.location_solid,
              size: 23,
              color: Palette.muted,
            ),
            const SizedBox(width: 32),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Deliver to',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(width: 6),
                      const Icon(
                        CupertinoIcons.chevron_down,
                        color: Palette.muted,
                        size: 12,
                      ),
                    ],
                  ),
                  Text(
                    StoreScope.of(context).address.street,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Palette.muted, fontSize: 11),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 16),
      InkWell(
        onTap: () => go(context, '/search-action'),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 42,
          decoration: BoxDecoration(
            color: Palette.soft,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(CupertinoIcons.search, color: Color(0xFFA9AAAE), size: 18),
              SizedBox(width: 10),
              Text(
                'Search',
                style: TextStyle(color: Color(0xFFA9AAAE), fontSize: 16),
              ),
            ],
          ),
        ),
      ),
      const SizedBox(height: 30),
      CategoryTags(
        onSelect: (s) => go(context, '/search-results', arguments: s),
      ),
      SectionTitle('Restaurants', onMore: () => go(context, '/restaurants')),
      ...restaurants.take(3).map(RestaurantCard.new),
      SectionTitle('Popular', onMore: () => go(context, '/popular')),
      SizedBox(
        height: 252,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) =>
              SizedBox(width: 156, child: FoodCard(foods[i])),
        ),
      ),
      SectionTitle(
        'Best restaurants',
        onMore: () => go(context, '/restaurants'),
      ),
      ...restaurants.skip(3).map(RestaurantCard.new),
    ],
  );
}

class RestaurantListScreen extends StatelessWidget {
  const RestaurantListScreen({super.key, this.popular = false});
  final bool popular;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: popular ? 'Popular' : 'Restaurants',
    child: ListView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      children: [
        if (popular) ...[
          const SectionTitle('Food'),
          FoodGrid([foods[0], foods[4], foods[5], foods[6]]),
        ],
        const SectionTitle('Restaurants'),
        ...restaurants.map(RestaurantCard.new),
      ],
    ),
  );
}

class RestaurantScreen extends StatefulWidget {
  const RestaurantScreen({super.key, required this.restaurant});
  final Restaurant restaurant;
  @override
  State<RestaurantScreen> createState() => _RestaurantScreenState();
}

class _RestaurantScreenState extends State<RestaurantScreen> {
  String category = 'All';
  bool favorite = false;
  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 185,
            pinned: true,
            backgroundColor: Palette.ink,
            foregroundColor: Colors.white,
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(CupertinoIcons.chevron_left),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                tooltip: 'Search menu',
                onPressed: () => go(context, '/search-action'),
                icon: const Icon(CupertinoIcons.search),
              ),
              IconButton(
                tooltip: 'Favorite',
                onPressed: () => setState(() => favorite = !favorite),
                icon: Icon(
                  favorite ? CupertinoIcons.heart_fill : CupertinoIcons.heart,
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  const Picture('restaurant_hero'),
                  Container(color: Colors.black.withValues(alpha: .35)),
                  Positioned(
                    left: 24,
                    bottom: 22,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.restaurant.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '★ ${widget.restaurant.rating}',
                          style: const TextStyle(color: Palette.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                CategoryTags(
                  all: true,
                  selected: category,
                  onSelect: (s) => setState(() => category = s),
                ),
                const SectionTitle('Food'),
                FoodGrid(
                  category == 'All'
                      ? foods
                      : foods.where((f) => f.category == category).toList(),
                ),
              ]),
            ),
          ),
        ],
      ),
      bottomNavigationBar: store.count == 0
          ? null
          : SafeArea(
              top: false,
              minimum: const EdgeInsets.fromLTRB(24, 8, 24, 16),
              child: PrimaryButton(
                'Your order · ${store.count} items   \$${store.subtotal}',
                () => go(context, '/cart'),
              ),
            ),
    );
  }
}

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key, required this.food});
  final Food food;
  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    final f = widget.food;
    return Scaffold(
      backgroundColor: Palette.soft,
      body: Stack(
        children: [
          const IgnorePointer(child: HomeScreen()),
          Container(color: Palette.ink.withValues(alpha: .5)),
          SafeArea(
            top: false,
            bottom: false,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * .8,
                ),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Stack(
                              children: [
                                Picture(
                                  f.image,
                                  width: double.infinity,
                                  height: 300,
                                ),
                                Positioned(
                                  top: 9,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Container(
                                      width: 36,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(3),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 14,
                                  right: 12,
                                  child: IconButton(
                                    tooltip: 'Close',
                                    style: IconButton.styleFrom(
                                      backgroundColor: Colors.white70,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    icon: const Icon(
                                      CupertinoIcons.xmark,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Padding(
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    f.name,
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge,
                                  ),
                                  const SizedBox(height: 12),
                                  Text(f.description),
                                  const SizedBox(height: 16),
                                  Text(
                                    '${f.grams} g',
                                    style: const TextStyle(
                                      color: Palette.muted,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SafeArea(
                      top: false,
                      minimum: const EdgeInsets.fromLTRB(24, 12, 24, 16),
                      child: Row(
                        children: [
                          Quantity(
                            quantity,
                            (d) => setState(
                              () => quantity = (quantity + d).clamp(1, 99),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: PrimaryButton(
                              'Add \$${f.price * quantity}',
                              () {
                                StoreScope.of(context).add(f, quantity);
                                Navigator.pop(context);
                                notice(context, 'Added to your order');
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.query = '', this.initialFood = false});
  final String query;
  final bool initialFood;
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late int selected = widget.initialFood || widget.query.isNotEmpty ? 1 : 0;
  @override
  Widget build(BuildContext context) {
    final q = widget.query.toLowerCase();
    final found = foods
        .where(
          (f) =>
              q.isEmpty ||
              f.name.toLowerCase().contains(q) ||
              f.category.toLowerCase().contains(q),
        )
        .toList();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      children: [
        InkWell(
          onTap: () => go(context, '/search-action'),
          child: Row(
            children: [
              if (q.isNotEmpty)
                IconButton(
                  onPressed: () => Navigator.maybePop(context),
                  icon: const Icon(CupertinoIcons.chevron_left, size: 18),
                ),
              Expanded(
                child: Text(
                  widget.query.isEmpty ? 'Search' : widget.query,
                  textAlign: widget.query.isEmpty
                      ? TextAlign.center
                      : TextAlign.start,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(CupertinoIcons.search, size: 21),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Segments(
          const ['Restaurants', 'Food'],
          selected,
          (s) => setState(() => selected = s),
        ),
        if (selected == 0) ...[
          SectionTitle(
            q.isEmpty ? 'With a high rating' : 'Restaurants',
            onMore: () => go(context, '/restaurants'),
          ),
          ...restaurants
              .where((r) => q.isEmpty || r.name.toLowerCase().contains(q))
              .map(RestaurantCard.new),
          if (q.isEmpty) ...[
            const SectionTitle('Worth your attention'),
            ...restaurants.reversed.take(3).map(RestaurantCard.new),
          ],
        ],
        if (selected == 1) ...[
          SectionTitle(
            q.isEmpty ? 'New dishes' : 'Food',
            onMore: q.isEmpty ? () => go(context, '/popular') : null,
          ),
          if (found.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 60),
              child: Text(
                'No dishes found. Try another search.',
                textAlign: TextAlign.center,
              ),
            ),
          FoodGrid(found),
        ],
        if (selected == 0 &&
            q.isNotEmpty &&
            !restaurants.any((r) => r.name.toLowerCase().contains(q)))
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 60),
            child: Text(
              'No restaurants found. Try the Food tab.',
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}

class SearchActionScreen extends StatefulWidget {
  const SearchActionScreen({super.key});
  @override
  State<SearchActionScreen> createState() => _SearchActionScreenState();
}

class _SearchActionScreenState extends State<SearchActionScreen> {
  final controller = TextEditingController();
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  void submit(String q) {
    if (q.trim().isEmpty) return;
    StoreScope.of(context).search(q.trim());
    go(context, '/search-results', arguments: q.trim());
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  key: const Key('search'),
                  controller: controller,
                  textInputAction: TextInputAction.search,
                  onSubmitted: submit,
                  decoration: InputDecoration(
                    hintText: 'Search',
                    prefixIcon: const Icon(CupertinoIcons.search, size: 18),
                    suffixIcon: IconButton(
                      tooltip: 'Search',
                      onPressed: () => submit(controller.text),
                      icon: const Icon(CupertinoIcons.arrow_right, size: 18),
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
          const SectionTitle('Popular'),
          CategoryTags(onSelect: submit),
          Row(
            children: [
              const Expanded(child: SectionTitle('Search history')),
              TextButton(
                onPressed: () {
                  final s = StoreScope.of(context);
                  s.searches.clear();
                  s.commit();
                },
                child: const Text('Clear all'),
              ),
            ],
          ),
          ...StoreScope.of(context).searches.map(
            (s) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                CupertinoIcons.clock,
                size: 20,
                color: Palette.muted,
              ),
              title: Text(s, style: const TextStyle(fontSize: 14)),
              onTap: () => submit(s),
            ),
          ),
        ],
      ),
    ),
  );
}
