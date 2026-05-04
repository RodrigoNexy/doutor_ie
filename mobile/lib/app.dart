import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/authors/presentation/authors_page.dart';
import 'features/auth/presentation/auth_gate.dart';
import 'features/auth/presentation/login_page.dart';
import 'features/auth/presentation/register_page.dart';
import 'features/books/presentation/books_list_page.dart';
import 'features/home/presentation/home_page.dart';
import 'features/profile/presentation/profile_page.dart';

class DoutorIeApp extends StatelessWidget {
  const DoutorIeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Doutor IE',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      routes: {
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/home': (context) => const HomePage(title: 'Doutor IE'),
        '/books': (context) => const BooksListPage(),
        '/authors': (context) => const AuthorsPage(),
        '/profile': (context) => const ProfilePage(),
      },
      home: const AuthGate(),
    );
  }
}
