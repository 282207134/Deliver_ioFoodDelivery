import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../data/catalog.dart';
import 'theme.dart';

void go(BuildContext context, String route, {Object? arguments}) =>
    Navigator.of(context).pushNamed(route, arguments: arguments);
void home(BuildContext context, [int tab = 0]) =>
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/home', (_) => false, arguments: tab);
void notice(BuildContext context, String message) =>
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
    );

class Picture extends StatelessWidget {
  const Picture(
    this.name, {
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.radius = 0,
  });
  final String name;
  final double? width, height;
  final BoxFit fit;
  final double radius;
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(radius),
    child: Image.asset(
      'assets/images/$name.png',
      width: width,
      height: height,
      fit: fit,
    ),
  );
}

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
    this.label,
    this.onPressed, {
    super.key,
    this.dark = false,
    this.soft = false,
    this.icon,
  });
  final String label;
  final VoidCallback? onPressed;
  final bool dark, soft;
  final IconData? icon;
  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: FilledButton(
      onPressed: onPressed,
      style: dark || soft
          ? FilledButton.styleFrom(
              backgroundColor: dark ? Palette.ink : Palette.soft,
              foregroundColor: dark ? Colors.white : Palette.ink,
            )
          : null,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 21), const SizedBox(width: 8)],
          Flexible(child: Text(label, textAlign: TextAlign.center)),
        ],
      ),
    ),
  );
}

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
    required this.title,
    required this.child,
    this.action,
    this.bottom,
    this.close = false,
  });
  final String title;
  final Widget child;
  final Widget? action, bottom;
  final bool close;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(title),
      leading: IconButton(
        tooltip: 'Back',
        icon: Icon(
          close ? CupertinoIcons.xmark : CupertinoIcons.chevron_left,
          size: 21,
        ),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      actions: [?action, const SizedBox(width: 12)],
    ),
    body: SafeArea(top: false, child: child),
    bottomNavigationBar: bottom == null
        ? null
        : SafeArea(
            top: false,
            minimum: const EdgeInsets.fromLTRB(24, 12, 24, 16),
            child: bottom!,
          ),
  );
}

class SectionTitle extends StatelessWidget {
  const SectionTitle(this.title, {super.key, this.onMore});
  final String title;
  final VoidCallback? onMore;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 16),
    child: Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        if (onMore != null)
          TextButton(
            onPressed: onMore,
            child: const Text('See more', style: TextStyle(fontSize: 15)),
          ),
      ],
    ),
  );
}

class SettingTile extends StatelessWidget {
  const SettingTile(
    this.title,
    this.subtitle,
    this.icon, {
    super.key,
    this.onTap,
    this.trailing,
  });
  final String title, subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => ListTile(
    contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 3),
    leading: Icon(icon, color: Palette.muted, size: 23),
    title: Text(
      title,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
    ),
    subtitle: subtitle.isEmpty
        ? null
        : Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Palette.muted, fontSize: 11),
          ),
    trailing:
        trailing ??
        const Icon(
          CupertinoIcons.chevron_right,
          size: 17,
          color: Color(0xFFBDBEC3),
        ),
    onTap: onTap,
  );
}

class LabeledField extends StatelessWidget {
  const LabeledField(
    this.label, {
    super.key,
    required this.controller,
    this.hint,
    this.keyboard,
    this.validator,
    this.onTap,
    this.readOnly = false,
    this.obscure = false,
    this.suffix,
  });
  final String label;
  final TextEditingController controller;
  final String? hint;
  final TextInputType? keyboard;
  final String? Function(String?)? validator;
  final VoidCallback? onTap;
  final bool readOnly, obscure;
  final Widget? suffix;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 20),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        TextFormField(
          key: ValueKey(label),
          controller: controller,
          keyboardType: keyboard,
          validator: validator,
          onTap: onTap,
          readOnly: readOnly,
          obscureText: obscure,
          decoration: InputDecoration(hintText: hint, suffixIcon: suffix),
        ),
      ],
    ),
  );
}

class Segments extends StatelessWidget {
  const Segments(this.labels, this.selected, this.onChange, {super.key});
  final List<String> labels;
  final int selected;
  final ValueChanged<int> onChange;
  @override
  Widget build(BuildContext context) => Container(
    height: 38,
    padding: const EdgeInsets.all(3),
    decoration: BoxDecoration(
      color: Palette.soft,
      borderRadius: BorderRadius.circular(9),
    ),
    child: Row(
      children: List.generate(
        labels.length,
        (i) => Expanded(
          child: GestureDetector(
            onTap: () => onChange(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: i == selected ? Palette.orange : Colors.transparent,
                borderRadius: BorderRadius.circular(7),
              ),
              child: Text(
                labels[i],
                style: TextStyle(
                  color: i == selected ? Colors.white : Palette.muted,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

class CategoryTags extends StatelessWidget {
  const CategoryTags({
    super.key,
    this.selected = '',
    required this.onSelect,
    this.all = false,
  });
  final String selected;
  final ValueChanged<String> onSelect;
  final bool all;
  @override
  Widget build(BuildContext context) {
    final tags = [if (all) 'All', ...categories];
    Widget row(List<String> values) => SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: values
            .map(
              (s) => Padding(
                padding: const EdgeInsets.only(right: 12),
                child: ActionChip(
                  label: Text(s),
                  onPressed: () => onSelect(s),
                  backgroundColor: s == selected
                      ? Palette.orange
                      : Palette.soft,
                  labelStyle: TextStyle(
                    color: s == selected ? Colors.white : Palette.ink,
                    fontSize: 15,
                  ),
                  side: BorderSide.none,
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
    return Column(
      children: [
        row(tags.take(4).toList()),
        const SizedBox(height: 4),
        row(tags.skip(4).toList()),
      ],
    );
  }
}

class RestaurantCard extends StatelessWidget {
  const RestaurantCard(this.restaurant, {super.key});
  final Restaurant restaurant;
  @override
  Widget build(BuildContext context) {
    final r = restaurant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0E000000),
              blurRadius: 24,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => go(context, '/restaurant', arguments: r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  children: [
                    Picture(r.image, width: double.infinity, height: 128),
                    if (r.free)
                      Positioned(
                        left: 16,
                        top: 16,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: Palette.green,
                            borderRadius: BorderRadius.circular(22),
                          ),
                          child: const Text(
                            'Free delivery',
                            style: TextStyle(color: Colors.white, fontSize: 15),
                          ),
                        ),
                      ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              r.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.star_rounded,
                            size: 20,
                            color: Palette.orange,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${r.rating}',
                            style: const TextStyle(
                              color: Palette.orange,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              '${r.distance} KM ~ ${r.minutes} min',
                              style: const TextStyle(
                                color: Palette.muted,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          if (r.closed)
                            const Text(
                              'Open at 10:00 AM',
                              style: TextStyle(
                                color: Palette.muted,
                                fontSize: 10,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard(this.food, {super.key});
  final Food food;
  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12),
    clipBehavior: Clip.antiAlias,
    child: InkWell(
      onTap: () => go(context, '/product', arguments: food),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Picture(food.image, width: double.infinity, height: 100),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${food.grams} g',
                    style: const TextStyle(color: Palette.muted, fontSize: 12),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
            child: SizedBox(
              width: double.infinity,
              height: 36,
              child: TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Palette.soft,
                  foregroundColor: Palette.ink,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  StoreScope.of(context).add(food);
                  notice(context, '${food.name} added to your order');
                },
                child: Text(
                  '\$${food.price}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ),
        ],
      ),
    ),
  );
}

class FoodGrid extends StatelessWidget {
  const FoodGrid(this.items, {super.key});
  final List<Food> items;
  @override
  Widget build(BuildContext context) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    itemCount: items.length,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      mainAxisExtent: 252,
    ),
    itemBuilder: (_, i) => FoodCard(items[i]),
  );
}

class Quantity extends StatelessWidget {
  const Quantity(this.value, this.onChange, {super.key});
  final int value;
  final ValueChanged<int> onChange;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      _button(CupertinoIcons.minus, () => onChange(-1), 'Decrease quantity'),
      SizedBox(width: 38, child: Text('$value', textAlign: TextAlign.center)),
      _button(CupertinoIcons.plus, () => onChange(1), 'Increase quantity'),
    ],
  );
  Widget _button(IconData icon, VoidCallback action, String label) =>
      IconButton(
        tooltip: label,
        onPressed: action,
        icon: Icon(icon, size: 20),
        style: IconButton.styleFrom(
          backgroundColor: Palette.soft,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          minimumSize: const Size(44, 44),
        ),
      );
}
