import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';
import '../../data/catalog.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});
  @override
  Widget build(BuildContext context) => ListView(
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SectionTitle('Account settings'),
      ),
      SettingTile(
        'Profile information',
        'Change your account information',
        CupertinoIcons.person,
        onTap: () => go(context, '/profile-edit'),
      ),
      SettingTile(
        'Payment method',
        'Add your credit & debit cards',
        CupertinoIcons.creditcard,
        onTap: () => go(context, '/cards'),
      ),
      SettingTile(
        'Address',
        'Add your delivery location',
        CupertinoIcons.location_solid,
        onTap: () => go(context, '/addresses'),
      ),
      SettingTile(
        'Refer to friends',
        'Share your invitation link',
        CupertinoIcons.share,
        onTap: () => go(context, '/refer'),
      ),
      SettingTile(
        'Notifications',
        'Manage your notification preferences',
        CupertinoIcons.bell,
        onTap: () => go(context, '/notifications'),
      ),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 24),
        child: SectionTitle('More'),
      ),
      SettingTile(
        'Rate Us',
        'Share your experience with us',
        CupertinoIcons.star,
        onTap: () => go(context, '/rate'),
      ),
      SettingTile(
        'FAQ',
        'Frequently asked questions',
        CupertinoIcons.info_circle,
        onTap: () => go(context, '/faq'),
      ),
      const SizedBox(height: 16),
      SettingTile(
        'Logout',
        'Log out of your account',
        CupertinoIcons.square_arrow_right,
        onTap: () async {
          final store = StoreScope.of(context);
          final ok = await showDialog<bool>(
            context: context,
            builder: (c) => AlertDialog(
              title: const Text('Log out?'),
              content: const Text(
                'Your saved addresses and orders will stay on this device.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(c, false),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(c, true),
                  child: const Text('Logout'),
                ),
              ],
            ),
          );
          if (ok == true && context.mounted) {
            store.signedIn = false;
            store.commit();
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/login', (_) => false);
          }
        },
      ),
    ],
  );
}

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});
  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      email = TextEditingController(),
      phone = TextEditingController();
  bool loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!loaded) {
      final s = StoreScope.of(context);
      name.text = s.name;
      email.text = s.email;
      phone.text = s.phone;
      loaded = true;
    }
  }

  @override
  void dispose() {
    name.dispose();
    email.dispose();
    phone.dispose();
    super.dispose();
  }

  Future<void> save() async {
    if (!form.currentState!.validate()) return;
    final s = StoreScope.of(context);
    if (phone.text != s.phone) {
      final old = s.phone;
      s.phone = phone.text;
      final verified = await Navigator.of(context).pushNamed('/sms-change');
      if (verified != true) {
        s.phone = old;
        return;
      }
    }
    s.name = name.text.trim();
    s.email = email.text.trim();
    s.commit();
    if (mounted) {
      Navigator.pop(context);
      notice(context, 'Profile saved');
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Profile',
    action: TextButton(onPressed: save, child: const Text('Save')),
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          LabeledField('Full name', controller: name, validator: requiredValue),
          LabeledField(
            'Enter your phone',
            controller: phone,
            keyboard: TextInputType.phone,
            validator: (v) => (v ?? '').replaceAll(RegExp(r'\D'), '').length < 7
                ? 'Enter a valid phone number'
                : null,
          ),
          LabeledField(
            'Email',
            controller: email,
            keyboard: TextInputType.emailAddress,
            validator: (v) =>
                RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v ?? '')
                ? null
                : 'Enter a valid email address',
          ),
        ],
      ),
    ),
  );
}

String? requiredValue(String? value) =>
    value == null || value.trim().isEmpty ? 'This field is required' : null;

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    const titles = [
      'Receive SMS-notifications',
      'Receive Push-notification',
      'Receive email newsletters',
    ];
    return PageFrame(
      title: 'Notifications',
      child: ListView(
        children: List.generate(
          3,
          (i) => SwitchListTile.adaptive(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 10,
            ),
            activeTrackColor: Palette.orange,
            title: Text(
              titles[i],
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              i == 1
                  ? 'Order and delivery notifications'
                  : 'News, promotions, discounts',
              style: const TextStyle(fontSize: 11, color: Palette.muted),
            ),
            value: s.notifications[i],
            onChanged: (b) {
              s.notifications[i] = b;
              s.commit();
            },
          ),
        ),
      ),
    );
  }
}

class CardsScreen extends StatefulWidget {
  const CardsScreen({super.key, this.select = false, this.initialEdit = false});
  final bool select, initialEdit;
  @override
  State<CardsScreen> createState() => _CardsScreenState();
}

class _CardsScreenState extends State<CardsScreen> {
  late bool edit = widget.initialEdit;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    void choose(String method) {
      s.payment = method;
      s.commit();
      if (widget.select) Navigator.pop(context);
    }

    return PageFrame(
      title: 'Payment method',
      action: s.cards.isEmpty
          ? null
          : TextButton(
              onPressed: () => setState(() => edit = !edit),
              child: Text(edit ? 'Save' : 'Edit'),
            ),
      child: s.cards.isEmpty
          ? LayoutBuilder(
              builder: (_, size) => SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: size.maxHeight),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Picture(
                          'empty_cards',
                          height: 240,
                          fit: BoxFit.contain,
                        ),
                        const SizedBox(height: 50),
                        Text(
                          'Don’t have any card?',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'It looks like you didn’t link the card to our app, you can quickly add a new card',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Palette.muted, fontSize: 13),
                        ),
                        const SizedBox(height: 24),
                        PrimaryButton(
                          'Add credit card',
                          () => go(context, '/add-card'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : ListView(
              children: [
                if (!edit)
                  SettingTile(
                    'Apple Pay',
                    'Pay with Face ID',
                    Icons.apple,
                    onTap: () => choose('Apple Pay'),
                    trailing: _selection(s.payment == 'Apple Pay'),
                  ),
                ...s.cards.map(
                  (last4) => SettingTile(
                    'MasterCard • $last4',
                    '04/29',
                    CupertinoIcons.creditcard_fill,
                    onTap: edit ? null : () => choose('MasterCard • $last4'),
                    trailing: edit
                        ? IconButton(
                            tooltip: 'Delete card $last4',
                            icon: const Icon(
                              CupertinoIcons.minus_circle_fill,
                              color: Color(0xFFED7456),
                            ),
                            onPressed: () {
                              s.cards.remove(last4);
                              if (s.payment.endsWith(last4)) {
                                s.payment = 'Apple Pay';
                              }
                              s.commit();
                            },
                          )
                        : _selection(s.payment.endsWith(last4)),
                  ),
                ),
                if (!edit)
                  SettingTile(
                    'Add credit card',
                    'Add new credit or debit card',
                    CupertinoIcons.creditcard,
                    onTap: () => go(context, '/add-card'),
                  ),
              ],
            ),
    );
  }

  Widget _selection(bool checked) => Icon(
    checked ? CupertinoIcons.check_mark_circled_solid : CupertinoIcons.circle,
    color: checked ? Palette.orange : const Color(0xFFD7D7DE),
    size: 22,
  );
}

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});
  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final number = TextEditingController(),
      expiry = TextEditingController(),
      cvv = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    number.dispose();
    expiry.dispose();
    cvv.dispose();
    super.dispose();
  }

  void save() {
    if (!form.currentState!.validate()) return;
    final s = StoreScope.of(context),
        digits = number.text.replaceAll(RegExp(r'\D'), '');
    final last4 = digits.substring(digits.length - 4);
    if (!s.cards.contains(last4)) s.cards.add(last4);
    s.payment = 'MasterCard • $last4';
    s.commit();
    Navigator.pop(context);
    notice(context, 'Demo card saved');
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Add credit card',
    bottom: PrimaryButton('Save credit card', save),
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          LabeledField(
            'Card number',
            controller: number,
            hint: '5469 5400 1201 4567',
            keyboard: TextInputType.number,
            validator: (v) =>
                RegExp(r'^\d{16}$')
                    .hasMatch((v ?? '').replaceAll(RegExp(r'\D'), ''))
                ? null
                : 'Enter a 16-digit card number',
            suffix: IconButton(
              tooltip: 'Scan card',
              onPressed: () => go(context, '/scan-card'),
              icon: const Icon(CupertinoIcons.viewfinder),
            ),
          ),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: LabeledField(
                  'Validity period',
                  controller: expiry,
                  hint: '04 / 29',
                  keyboard: TextInputType.datetime,
                  validator: (v) =>
                      RegExp(r'^(0[1-9]|1[0-2])\s*/\s*\d{2}$').hasMatch(v ?? '')
                      ? null
                      : 'Use MM/YY',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: LabeledField(
                  'CVV',
                  controller: cvv,
                  hint: '•••',
                  obscure: true,
                  keyboard: TextInputType.number,
                  validator: (v) => RegExp(r'^\d{3,4}$').hasMatch(v ?? '')
                      ? null
                      : 'Enter 3–4 digits',
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Demo only. Only the last four digits are saved on your device.',
            style: TextStyle(color: Palette.muted, fontSize: 12),
          ),
        ],
      ),
    ),
  );
}

class ScanCardScreen extends StatelessWidget {
  const ScanCardScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Palette.ink,
    body: Stack(
      children: [
        const Positioned.fill(child: Picture('scan')),
        Positioned.fill(
          child: Container(color: Palette.ink.withValues(alpha: .45)),
        ),
        SafeArea(
          child: Column(
            children: [
              Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  tooltip: 'Back',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(
                    CupertinoIcons.chevron_left,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 70),
              const Text(
                'Scan your card',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Keep the card inside the frame, it will be read automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
              Container(
                height: 175,
                margin: const EdgeInsets.symmetric(horizontal: 24),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const Spacer(),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  'Demo preview. Enter your card details manually.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: PrimaryButton(
                  'Enter card manually',
                  () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key, this.select = false});
  final bool select;
  @override
  Widget build(BuildContext context) {
    final s = StoreScope.of(context);
    return PageFrame(
      title: 'Address',
      action: IconButton(
        tooltip: 'Add address',
        onPressed: () => go(context, '/location-add'),
        icon: const Icon(CupertinoIcons.plus, size: 22),
      ),
      child: ListView(
        children: [
          ...s.addresses.asMap().entries.map(
            (e) => SettingTile(
              e.value.name,
              e.value.street,
              CupertinoIcons.location_solid,
              onTap: () {
                if (select) {
                  s.selectedAddress = e.key;
                  s.commit();
                  Navigator.pop(context);
                } else {
                  go(context, '/address-edit', arguments: e.key);
                }
              },
              trailing: select
                  ? Icon(
                      e.key == s.selectedAddress
                          ? CupertinoIcons.check_mark_circled_solid
                          : CupertinoIcons.circle,
                      color: e.key == s.selectedAddress
                          ? Palette.orange
                          : const Color(0xFFD7D7DE),
                      size: 22,
                    )
                  : null,
            ),
          ),
          SettingTile(
            'Add address',
            'Add new delivery address',
            CupertinoIcons.plus,
            onTap: () => go(context, '/location-add'),
          ),
        ],
      ),
    );
  }
}

class AddressEditScreen extends StatefulWidget {
  const AddressEditScreen({super.key, this.index, this.street});
  final int? index;
  final String? street;
  @override
  State<AddressEditScreen> createState() => _AddressEditScreenState();
}

class _AddressEditScreenState extends State<AddressEditScreen> {
  final form = GlobalKey<FormState>();
  final name = TextEditingController(),
      street = TextEditingController(),
      entrance = TextEditingController(),
      apartment = TextEditingController(),
      floor = TextEditingController(),
      comment = TextEditingController();
  bool loaded = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (loaded) return;
    if (widget.index != null) {
      final a = StoreScope.of(context).addresses[widget.index!];
      name.text = a.name;
      street.text = a.street;
      entrance.text = a.entrance;
      apartment.text = a.apartment;
      floor.text = a.floor;
      comment.text = a.comment;
    } else {
      street.text = widget.street ?? '';
    }
    loaded = true;
  }

  @override
  void dispose() {
    for (final c in [name, street, entrance, apartment, floor, comment]) {
      c.dispose();
    }
    super.dispose();
  }

  void save() {
    if (!form.currentState!.validate()) return;
    final s = StoreScope.of(context);
    final a = DeliveryAddress(
      name: name.text.trim(),
      street: street.text.trim(),
      entrance: entrance.text,
      apartment: apartment.text,
      floor: floor.text,
      comment: comment.text,
    );
    if (widget.index == null) {
      s.addresses.add(a);
      s.selectedAddress = s.addresses.length - 1;
    } else {
      s.addresses[widget.index!] = a;
    }
    s.commit();
    Navigator.pop(context);
    notice(context, 'Address saved');
  }

  Future<void> delete() async {
    final s = StoreScope.of(context);
    if (s.addresses.length == 1) {
      notice(context, 'Keep at least one delivery address');
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Delete this address?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(c, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(c, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      final index = widget.index!;
      s.addresses.removeAt(index);
      if (s.selectedAddress >= index) {
        s.selectedAddress = (s.selectedAddress - 1).clamp(
          0,
          s.addresses.length - 1,
        );
      }
      s.commit();
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) => PageFrame(
    title: widget.index == null
        ? 'Add address'
        : name.text.isEmpty
        ? 'Address information'
        : name.text,
    action: widget.index == null
        ? null
        : TextButton(
            onPressed: delete,
            child: const Text('Delete', style: TextStyle(color: Palette.muted)),
          ),
    bottom: PrimaryButton('Save address', save),
    child: Form(
      key: form,
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          LabeledField(
            'Name',
            controller: name,
            hint: 'Home',
            validator: requiredValue,
          ),
          LabeledField(
            'Address',
            controller: street,
            hint: 'Enter delivery address',
            validator: requiredValue,
          ),
          LabeledField(
            'Entrance',
            controller: entrance,
            keyboard: TextInputType.number,
          ),
          LabeledField(
            'Apartment number',
            controller: apartment,
            keyboard: TextInputType.number,
          ),
          LabeledField(
            'Floor',
            controller: floor,
            keyboard: TextInputType.number,
          ),
          LabeledField(
            'Comment to the courier',
            controller: comment,
            hint: 'Enter the comment',
          ),
        ],
      ),
    ),
  );
}

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, this.add = false, this.find = false});
  final bool add, find;
  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final input = TextEditingController();
  String query = '';
  @override
  void dispose() {
    input.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final suggestions = query.trim().isEmpty
        ? ['San Francisco', 'San Francisco City Hall', 'San Francisco, Cordoba']
        : [query.trim(), '$query City Hall', '$query, California'];
    return PageFrame(
      title: widget.find
          ? 'Your location'
          : widget.add
          ? 'Add address'
          : 'Change address',
      close: true,
      action: TextButton(
        onPressed: () => go(context, '/map'),
        child: const Text('Map'),
      ),
      child: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          if (widget.find) ...[
            Text(
              'Find restaurants near you',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            const Text(
              'Please enter your location to find restaurants near you',
              style: TextStyle(color: Palette.muted, fontSize: 13),
            ),
            const SizedBox(height: 24),
          ],
          TextField(
            key: const Key('location'),
            controller: input,
            onChanged: (q) => setState(() => query = q),
            decoration: const InputDecoration(
              hintText: 'Search for your location',
              prefixIcon: Icon(CupertinoIcons.search, size: 18),
            ),
          ),
          const SizedBox(height: 16),
          ...suggestions.map(
            (address) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(
                CupertinoIcons.location,
                color: Palette.muted,
              ),
              title: Text(address, style: const TextStyle(fontSize: 14)),
              subtitle: const Text(
                'California',
                style: TextStyle(fontSize: 12, color: Palette.muted),
              ),
              onTap: () {
                if (widget.add) {
                  go(context, '/address-new', arguments: address);
                } else {
                  final s = StoreScope.of(context);
                  s.addresses.add(
                    DeliveryAddress(name: 'Selected location', street: address),
                  );
                  s.selectedAddress = s.addresses.length - 1;
                  s.commit();
                  Navigator.pop(context);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});
  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Offset position = const Offset(.53, .52);
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: LayoutBuilder(
            builder: (context, size) => GestureDetector(
              onTapDown: (d) => setState(
                () => position = Offset(
                  d.localPosition.dx / size.maxWidth,
                  d.localPosition.dy / size.maxHeight,
                ),
              ),
              child: Stack(
                children: [
                  const Positioned.fill(child: Picture('map')),
                  Positioned(
                    left: position.dx * size.maxWidth - 22,
                    top: position.dy * size.maxHeight - 44,
                    child: const Icon(
                      CupertinoIcons.location_solid,
                      size: 44,
                      color: Palette.orange,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        SafeArea(
          child: IconButton(
            tooltip: 'Back',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(CupertinoIcons.chevron_left),
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
              minimum: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    StoreScope.of(context).address.street,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    'Add address',
                    () => go(
                      context,
                      '/address-new',
                      arguments: StoreScope.of(context).address.street,
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

class ReferScreen extends StatelessWidget {
  const ReferScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Refer to friends',
    child: ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Picture('referral', height: 390, fit: BoxFit.contain),
        const SizedBox(height: 24),
        Text(
          'Refer a friend, get \$10',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        const Text(
          'Get \$10 in credits when someone\nsigns up using your referral link',
          textAlign: TextAlign.center,
          style: TextStyle(color: Palette.muted),
        ),
        const SizedBox(height: 24),
        PrimaryButton('Share', () async {
          await Clipboard.setData(
            const ClipboardData(text: 'Deliver.io demo invitation: DELIVER10'),
          );
          if (context.mounted) {
            notice(context, 'Invitation code DELIVER10 copied');
          }
        }),
      ],
    ),
  );
}

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'FAQ & Support',
    child: ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        ExpansionTile(
          title: Text('How do I place an order?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Choose a restaurant, add dishes to your order and open Cart. Review your address and payment method, then confirm the demo payment.',
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Where is my order?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Open Cart, select the Active tab and tap Track order to see your courier’s route.',
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Can I change my delivery address?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Tap Deliver to on the home page, or go to Profile → Address. You can also choose an address during checkout.',
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('Will I be charged?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'This is a local demo. Payments, SMS verification, courier locations and referral credits are simulated. No money is charged and no real order is sent.',
              ),
            ),
          ],
        ),
        ExpansionTile(
          title: Text('How do I contact support?'),
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'In a connected production version, support would be available here. This demo stores your data only on this device.',
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
