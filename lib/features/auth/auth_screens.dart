import 'dart:async';

import 'package:flutter/cupertino.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme.dart';
import '../../core/widgets.dart';
import '../../data/app_store.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, this.automatic = true});
  final bool automatic;
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? timer;
  @override
  void initState() {
    super.initState();
    if (widget.automatic) {
      timer = Timer(const Duration(milliseconds: 1400), () {
        if (mounted) {
          Navigator.of(context).pushReplacementNamed(
            StoreScope.of(context).signedIn ? '/home' : '/login',
          );
        }
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Picture('logo', width: 119, height: 96, fit: BoxFit.contain),
          const SizedBox(height: 14),
          RichText(
            text: const TextSpan(
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 23,
                fontWeight: FontWeight.w600,
                color: Palette.ink,
              ),
              children: [
                TextSpan(text: 'Deliver'),
                TextSpan(
                  text: '.io',
                  style: TextStyle(color: Palette.orange),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, this.register = false});
  final bool register;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final phone = TextEditingController();
  final form = GlobalKey<FormState>();
  @override
  void dispose() {
    phone.dispose();
    super.dispose();
  }

  void continueLogin() {
    if (!form.currentState!.validate()) return;
    final store = StoreScope.of(context);
    store.phone = phone.text;
    store.commit();
    go(context, '/sms');
  }

  @override
  Widget build(BuildContext context) {
    final store = StoreScope.of(context);
    return Scaffold(
      body: Stack(
        children: [
          Picture(
            widget.register ? 'register' : 'login',
            height: 260,
            width: double.infinity,
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(top: 170),
              child: Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 36, 24, 24),
                  child: Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            widget.register
                                ? 'Create an account'
                                : 'Login to your account',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          widget.register
                              ? 'Welcome friend, enter your details so lets get started in ordering food.'
                              : 'Welcome to deliver.io, enter your details below to continue ordering.',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Palette.muted,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 26),
                        const Text(
                          'Enter your phone',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          key: const Key('phone'),
                          controller: phone,
                          keyboardType: TextInputType.phone,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9 +()-]'),
                            ),
                          ],
                          validator: (s) =>
                              (s ?? '').replaceAll(RegExp(r'\D'), '').length < 7
                              ? 'Enter a valid phone number'
                              : null,
                          decoration: InputDecoration(
                            hintText: 'Enter your phone',
                            prefixIcon: TextButton(
                              onPressed: () => go(context, '/country'),
                              child: Text(
                                '🇺🇸 ${store.countryCode}',
                                style: const TextStyle(
                                  color: Palette.ink,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton('Continue', continueLogin),
                        const SizedBox(height: 32),
                        const Row(
                          children: [
                            Expanded(child: Divider()),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text(
                                'OR',
                                style: TextStyle(
                                  color: Palette.muted,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 28),
                        PrimaryButton(
                          'G   Continue With Google',
                          () => notice(
                            context,
                            'Google sign-in needs a connected authentication service. Use your phone for this demo.',
                          ),
                          soft: true,
                        ),
                        const SizedBox(height: 14),
                        PrimaryButton(
                          'Continue with Apple',
                          () => notice(
                            context,
                            'Apple sign-in needs a connected authentication service. Use your phone for this demo.',
                          ),
                          icon: Icons.apple,
                          soft: true,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: TextButton(
                            onPressed: () => Navigator.of(context)
                                .pushReplacementNamed(
                                  widget.register ? '/login' : '/register',
                                ),
                            child: Text.rich(
                              TextSpan(
                                style: const TextStyle(
                                  color: Palette.ink,
                                  fontSize: 12,
                                ),
                                children: [
                                  TextSpan(
                                    text: widget.register
                                        ? 'Already have an account? '
                                        : 'Don’t have an account? ',
                                  ),
                                  TextSpan(
                                    text: widget.register
                                        ? 'Log In'
                                        : 'Sign Up',
                                    style: const TextStyle(
                                      color: Palette.orange,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CountryScreen extends StatefulWidget {
  const CountryScreen({super.key});
  @override
  State<CountryScreen> createState() => _CountryScreenState();
}

class _CountryScreenState extends State<CountryScreen> {
  String query = '';
  static const countries = [
    ('🇦🇫', 'Afghanistan', '+93'),
    ('🇦🇱', 'Albania', '+355'),
    ('🇩🇿', 'Algeria', '+213'),
    ('🇦🇸', 'America Samoa', '+1684'),
    ('🇦🇩', 'Andorra', '+376'),
    ('🇦🇴', 'Angola', '+244'),
    ('🇦🇮', 'Anguilla', '+1264'),
    ('🇨🇳', 'China', '+86'),
    ('🇯🇵', 'Japan', '+81'),
    ('🇬🇧', 'United Kingdom', '+44'),
    ('🇺🇸', 'United States', '+1'),
  ];
  @override
  Widget build(BuildContext context) => PageFrame(
    title: 'Select country code',
    child: Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(24),
          child: TextField(
            onChanged: (s) => setState(() => query = s),
            decoration: const InputDecoration(
              hintText: 'Search',
              prefixIcon: Icon(CupertinoIcons.search, size: 19),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            children: countries
                .where(
                  (c) =>
                      c.$2.toLowerCase().contains(query.toLowerCase()) ||
                      c.$3.contains(query),
                )
                .map(
                  (c) => ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 24),
                    leading: Text(c.$1, style: const TextStyle(fontSize: 23)),
                    title: Text(c.$2, style: const TextStyle(fontSize: 14)),
                    trailing: Text(
                      c.$3,
                      style: const TextStyle(color: Palette.muted),
                    ),
                    onTap: () {
                      final s = StoreScope.of(context);
                      s.countryCode = c.$3;
                      s.commit();
                      Navigator.pop(context);
                    },
                  ),
                )
                .toList(),
          ),
        ),
      ],
    ),
  );
}

class SmsScreen extends StatefulWidget {
  const SmsScreen({
    super.key,
    this.changePhone = false,
    this.initialError = false,
  });
  final bool changePhone, initialError;
  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final code = TextEditingController();
  bool error = false;
  int seconds = 149;
  Timer? timer;
  @override
  void initState() {
    super.initState();
    error = widget.initialError;
    timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted && seconds > 0) setState(() => seconds--);
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    code.dispose();
    super.dispose();
  }

  void verify(String value) {
    if (value.length != 4) return;
    if (value != '1234') {
      setState(() => error = true);
      return;
    }
    final s = StoreScope.of(context);
    s.signedIn = true;
    s.commit();
    if (widget.changePhone) {
      Navigator.pop(context, true);
    } else {
      Navigator.of(context).pushReplacementNamed('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        const Picture('sms', height: 280, width: double.infinity),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 175),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  Center(
                    child: Text(
                      'SMS code',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Enter verification code from SMS, which sent to ${StoreScope.of(context).countryCode} ${StoreScope.of(context).phone}${widget.changePhone ? '. To change your current phone number' : ''}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Palette.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 30),
                  TextField(
                    key: const Key('sms_code'),
                    controller: code,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    onChanged: verify,
                    decoration: InputDecoration(
                      hintText: 'SMS Code',
                      counterText: '',
                      errorText: error
                          ? 'The code was entered incorrectly'
                          : null,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: seconds == 0
                          ? () {
                              setState(() {
                                seconds = 149;
                                error = false;
                              });
                              notice(context, 'Demo verification code: 1234');
                            }
                          : null,
                      child: Text(
                        'Resend code (${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')})',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Demo verification code: 1234',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Palette.muted, fontSize: 11),
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

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key, this.initialPage = 0});
  final int initialPage;
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late int page = widget.initialPage;
  static const titles = [
    'Order from your favourite\nstores or vendors',
    'Choose from a wide range of delicious meals',
    'Enjoy instant delivery\nand payment',
  ];
  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Picture('onboarding${page + 1}', width: double.infinity, height: 300),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 175),
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
                      child: Column(
                        children: [
                          Text(
                            titles[page],
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 20),
                          Picture(
                            'preview${page + 1}',
                            height: 250,
                            fit: BoxFit.contain,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(
                              3,
                              (i) => Container(
                                width: i == page ? 20 : 7,
                                height: 5,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 3,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: i == page
                                      ? Palette.orange
                                      : Palette.soft,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          PrimaryButton('Continue', () {
                            if (page < 2) {
                              setState(() => page++);
                            } else {
                              home(context);
                            }
                          }),
                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () => home(context),
                            child: const Text(
                              'Skip',
                              style: TextStyle(color: Palette.ink),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
