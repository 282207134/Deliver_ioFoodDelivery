import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../../data/catalog.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key, this.initialHistory = false});
  final bool initialHistory;
  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  late int tab = widget.initialHistory ? 1 : 0;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    final orders = s.orders
        .where(
          (o) => tab == 1
              ? o.delivered || o.canceled
              : !o.delivered && !o.canceled,
        )
        .toList();
    final empty = orders.isEmpty && (tab == 1 || s.cart.isEmpty);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'My orders',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Segments(
            const ['Active', 'History'],
            tab,
            (i) => setState(() => tab = i),
          ),
        ),
        Expanded(
          child: empty
              ? SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      const Picture(
                        'empty_orders',
                        height: 285,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 22),
                      Text(
                        'You don’t have any orders',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'But you can quickly order a lot\nof delicious food',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Palette.muted),
                      ),
                      const SizedBox(height: 24),
                      PrimaryButton('Order Now', () => home(context)),
                    ],
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (tab == 0 && s.cart.isNotEmpty)
                      _OrderCard(
                        items: s.cart,
                        subtitle: 'Complete the order',
                        button: 'To order',
                        onTap: () => go(context, '/cart'),
                      ),
                    ...orders.map(
                      (o) => _OrderCard(
                        items: o.items,
                        subtitle: o.canceled
                            ? 'Canceled • 16 may'
                            : o.delivered
                            ? 'Delivered • 22 may'
                            : 'On the Way • 25 may',
                        button: tab == 1 ? 'Re-order' : 'Track order',
                        total: o.total,
                        onTap: () {
                          if (tab == 1) {
                            s.reorder(o);
                            go(context, '/cart');
                          } else {
                            go(context, '/tracker');
                          }
                        },
                        onRate: o.delivered ? () => go(context, '/rate') : null,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.items,
    required this.subtitle,
    required this.button,
    required this.onTap,
    this.total,
    this.onRate,
  });
  final Map<String, int> items;
  final String subtitle, button;
  final VoidCallback onTap;
  final VoidCallback? onRate;
  final int? total;
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 18),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: const [
        BoxShadow(
          color: Color(0x0C000000),
          blurRadius: 22,
          offset: Offset(0, 8),
        ),
      ],
    ),
    child: Column(
      children: [
        InkWell(
          onTap: () => go(context, '/restaurant', arguments: restaurants.first),
          child: Row(
            children: [
              const CircleAvatar(
                radius: 18,
                backgroundColor: Color(0xFF244C9C),
                child: Icon(Icons.restaurant, size: 20, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Friendly's",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Palette.muted,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                CupertinoIcons.chevron_right,
                size: 16,
                color: Palette.muted,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        ...items.entries.map(
          (e) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 7),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    '${foodById(e.key).name}${e.value > 1 ? ' ×${e.value}' : ''}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ),
                Text(
                  '\$${foodById(e.key).price * e.value}',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
        if (total != null) ...[
          const Divider(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              Text(
                '\$$total',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ],
        const SizedBox(height: 10),
        PrimaryButton(button, onTap, soft: total != null),
        if (onRate != null)
          TextButton(
            onPressed: onRate,
            child: const Text('Rate this Restaurant'),
          ),
      ],
    ),
  );
}

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return PageFrame(
      title: 'Your order',
      close: true,
      bottom: s.cart.isEmpty
          ? null
          : PrimaryButton(
              'Place an order \$${s.subtotal}',
              () => go(context, '/payment'),
            ),
      child: s.cart.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Picture(
                      'empty_orders',
                      height: 260,
                      fit: BoxFit.contain,
                    ),
                    const Text('Your order is empty'),
                    const SizedBox(height: 20),
                    PrimaryButton('Explore restaurants', () => home(context)),
                  ],
                ),
              ),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 20,
                      backgroundColor: Color(0xFF244C9C),
                      child: Icon(Icons.restaurant, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Friendly's",
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        Text(
                          '${s.count} ${s.count == 1 ? 'dish' : 'dishes'}',
                          style: const TextStyle(
                            color: Palette.muted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                ...s.cart.entries.map((e) {
                  final f = foodById(e.key);
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Picture(f.image, width: 82, height: 84, radius: 8),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                f.name,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Quantity(
                                e.value,
                                (d) => s.changeQuantity(e.key, d),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '\$${f.price * e.value}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
                const SectionTitle('Popular'),
                SizedBox(
                  height: 252,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    separatorBuilder: (_, _) => const SizedBox(width: 12),
                    itemBuilder: (_, i) => SizedBox(
                      width: 156,
                      child: FoodCard(
                        [foods[6], foods[0], foods[5], foods[4]][i],
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});
  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  bool busy = false;
  Future<void> pay() async {
    final s = StoreScope.of(context);
    if (s.cart.isEmpty) {
      notice(context, 'Your order is empty');
      return;
    }
    final result = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Demo payment'),
        content: Text(
          'Complete your \$${s.total} order using a simulated payment. No money will be charged.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Simulate failure'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Confirm payment'),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    setState(() => busy = true);
    await Future<void>.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    if (result) s.placeOrder();
    setState(() => busy = false);
    go(context, result ? '/success' : '/failure');
  }

  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return PageFrame(
      title: 'Payment',
      close: true,
      bottom: PrimaryButton(
        busy
            ? 'Processing…'
            : s.payment == 'Apple Pay'
            ? 'Apple pay'
            : 'Pay \$${s.total}',
        busy || s.cart.isEmpty ? null : pay,
        dark: true,
        icon: s.payment == 'Apple Pay' ? Icons.apple : null,
      ),
      child: ListView(
        children: [
          SettingTile(
            s.address.name,
            s.address.street,
            CupertinoIcons.location_solid,
            onTap: () => go(context, '/addresses', arguments: true),
          ),
          SettingTile(
            s.payment,
            s.payment == 'Apple Pay'
                ? 'Pay with Face ID'
                : 'Credit or debit card',
            CupertinoIcons.creditcard,
            onTap: () => go(context, '/cards', arguments: true),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                ...s.cart.entries.map(
                  (e) => _BillRow(
                    foodById(e.key).name,
                    '\$${foodById(e.key).price * e.value}',
                  ),
                ),
                const Divider(height: 32),
                const _BillRow('Delivery', 'Free'),
                const _BillRow('Service Kit', 'Free'),
                if (s.discount > 0) _BillRow('Discount', '−\$${s.discount}'),
                const Divider(height: 32),
                _BillRow('Total', '\$${s.total}', large: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BillRow extends StatelessWidget {
  const _BillRow(this.label, this.value, {this.large = false});
  final String label, value;
  final bool large;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: large ? 22 : 13,
              fontWeight: large ? FontWeight.w600 : FontWeight.w400,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Text(
          value,
          style: TextStyle(
            fontSize: large ? 22 : 13,
            fontWeight: large ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ],
    ),
  );
}

class PaymentResultScreen extends StatelessWidget {
  const PaymentResultScreen({super.key, required this.success});
  final bool success;
  @override
  Widget build(BuildContext context) => PageFrame(
    title: success ? 'Payment Success' : 'Payment Failed',
    child: LayoutBuilder(
      builder: (context, size) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: size.maxHeight),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Picture(
                  success ? 'success' : 'failure',
                  height: 290,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 32),
                Text(
                  success ? 'Congratulations!' : 'Unfortunately!',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 14),
                Text(
                  success
                      ? 'The payment was successful, enjoy the excellent service and fast delivery!'
                      : 'An error occurred during the payment, please try again',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Palette.muted, fontSize: 13),
                ),
                const SizedBox(height: 24),
                if (success)
                  PrimaryButton('Go to home page', () => home(context))
                else
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(
                          'Skip',
                          () => home(context),
                          soft: true,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: PrimaryButton('Try Again', () {
                          Navigator.pop(context);
                        }),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

class TrackerScreen extends StatelessWidget {
  const TrackerScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const Positioned.fill(child: Picture('map')),
        Positioned.fill(child: CustomPaint(painter: _RoutePainter())),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                tooltip: 'Back',
                style: IconButton.styleFrom(backgroundColor: Colors.white),
                icon: const Icon(CupertinoIcons.chevron_left),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 36,
                    height: 4,
                    margin: const EdgeInsets.only(top: 10, bottom: 22),
                    decoration: BoxDecoration(
                      color: Palette.soft,
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                  Text(
                    'Courier on the way',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Courier John will arrive in 8 minutes',
                    style: TextStyle(color: Palette.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  const SettingTile(
                    '8 minutes',
                    'Your delivery time',
                    CupertinoIcons.clock,
                    trailing: SizedBox(),
                  ),
                  SettingTile(
                    StoreScope.of(context).address.street,
                    'Your address',
                    CupertinoIcons.location_solid,
                    trailing: const SizedBox(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(24),
                    child: Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            'Call John',
                            () => showDialog<void>(
                              context: context,
                              builder: (c) => AlertDialog(
                                title: const Text('Courier John'),
                                content: const Text(
                                  'Demo courier: +1 212 555 0100\nYour order is on the way.',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(c),
                                    child: const Text('Close'),
                                  ),
                                ],
                              ),
                            ),
                            soft: true,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: PrimaryButton(
                            'Support',
                            () => go(context, '/faq'),
                            soft: true,
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

class _RoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * .23, size.height * .12)
      ..lineTo(size.width * .23, size.height * .38)
      ..lineTo(size.width * .57, size.height * .38)
      ..lineTo(size.width * .57, size.height * .50)
      ..lineTo(size.width * .72, size.height * .50);
    canvas.drawPath(
      path,
      Paint()
        ..color = Palette.orange
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke
        ..strokeJoin = StrokeJoin.round,
    );
    for (final p in [
      Offset(size.width * .23, size.height * .12),
      Offset(size.width * .72, size.height * .50),
    ]) {
      canvas.drawCircle(p, 12, Paint()..color = Colors.white);
      canvas.drawCircle(p, 8, Paint()..color = Palette.orange);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});
  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  int stars = 4;
  final comment = TextEditingController();
  @override
  void dispose() {
    comment.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Rate this Restaurant',
    close: true,
    bottom: Row(
      children: [
        Expanded(
          child: PrimaryButton(
            'Skip',
            () => Navigator.pop(context),
            soft: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: PrimaryButton('Continue', () {
            StoreScope.of(context).preferences
                .setString('last_review', '$stars|${comment.text}');
            Navigator.pop(context);
            notice(context, 'Thank you for sharing your feedback!');
          }),
        ),
      ],
    ),
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 30),
        Text(
          'Rate this Restaurant',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        const Text(
          'What do you think about the delivery and delicious food, share your opinion',
          textAlign: TextAlign.center,
          style: TextStyle(color: Palette.muted),
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => IconButton(
              tooltip: '${i + 1} stars',
              onPressed: () => setState(() => stars = i + 1),
              icon: Icon(
                Icons.star_rounded,
                color: i < stars ? Palette.orange : const Color(0xFFD7D7DE),
                size: 36,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
        TextField(
          key: const Key('review'),
          controller: comment,
          maxLines: 6,
          maxLength: 500,
          decoration: const InputDecoration(hintText: 'Share your experience…'),
        ),
      ],
    ),
  );
}
