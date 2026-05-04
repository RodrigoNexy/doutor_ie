import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/stripe_colors.dart';
import '../../home/presentation/home_page.dart';
import 'login_page.dart';

class AuthGate extends ConsumerWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(authSessionProvider);

    if (!session.bootstrapped) {
      return const Scaffold(
        backgroundColor: StripeColors.surface,
        body: Center(
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: StripeColors.purple,
          ),
        ),
      );
    }

    if (session.isAuthenticated) {
      return const HomePage(title: 'Doutor IE');
    }

    return const LoginPage();
  }
}
