import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/stripe_colors.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../models/book.dart';
import '../../books/presentation/book_form_page.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _deleting = false;

  Future<void> _reloadBooks() async {
    await ref.read(homeBookListProvider.notifier).load();
    await ref.read(catalogBookListProvider.notifier).load();
  }

  Future<void> _deleteBook(Book book) async {
    if (_deleting) {
      return;
    }

    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Excluir livro'),
              content: Text(
                'Tem certeza que deseja excluir "${book.titulo}"? '
                'Essa ação não pode ser desfeita.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  style: FilledButton.styleFrom(
                    backgroundColor: StripeColors.errorRuby,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Excluir'),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed || !mounted) {
      return;
    }

    setState(() => _deleting = true);
    try {
      await ref.read(booksRemoteDataSourceProvider).delete(book.id);
      await _reloadBooks();
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro excluído com sucesso.')),
      );
    } on Object catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Falha ao excluir: $e')));
    } finally {
      if (mounted) {
        setState(() => _deleting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(authSessionProvider);
    final state = ref.watch(homeBookListProvider);

    ref.listen(authSessionProvider, (previous, next) {
      if (!next.isAuthenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });

    final myBooks = state.books
        .where((book) => book.usuarioPublicador?.id == session.currentUserId)
        .toList(growable: false);
    final userName = myBooks.isNotEmpty
        ? (myBooks.first.usuarioPublicador?.nome ?? 'Usuário')
        : 'Usuário';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Meu perfil'),
        actions: [
          IconButton(
            onPressed: _reloadBooks,
            icon: const Icon(Icons.refresh),
          ),
          IconButton(
            onPressed: () async {
              await ref.read(authSessionProvider.notifier).signOut();
              if (!context.mounted) {
                return;
              }
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil('/login', (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentTab: AppTab.profile),
      body: Builder(
        builder: (context) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state.errorMessage != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  state.errorMessage!,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFFD9DEF5),
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 34,
                        color: Color(0xFF3A3D44),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D1D1F),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${myBooks.length} livro(s) publicado(s)',
                            style: const TextStyle(
                              color: Color(0xFF6E727A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Meus livros',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(height: 12),
              if (myBooks.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text('Você ainda não publicou livros.'),
                )
              else
                ...myBooks.map((book) {
                  final palette = _coverPalette(book.id);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF4F5F7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 68,
                              height: 92,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: palette,
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Center(
                                child: Text(
                                  book.titulo,
                                  maxLines: 4,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book.titulo,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1D1D1F),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${book.numeroPaginas} páginas',
                                    style: const TextStyle(
                                      color: Color(0xFF6E727A),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: _deleting
                                    ? null
                                    : () async {
                                        await Navigator.of(context).push(
                                          MaterialPageRoute<void>(
                                            builder: (_) =>
                                                BookFormPage(existingBook: book),
                                          ),
                                        );
                                        await _reloadBooks();
                                      },
                                icon: const Icon(Icons.edit),
                                label: const Text('Editar'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _deleting
                                    ? null
                                    : () => _deleteBook(book),
                                style: FilledButton.styleFrom(
                                  backgroundColor: StripeColors.errorRuby,
                                  foregroundColor: Colors.white,
                                ),
                                icon: const Icon(Icons.delete_outline),
                                label: Text(_deleting ? 'Excluindo...' : 'Excluir'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

List<Color> _coverPalette(int seed) {
  const palettes = <List<Color>>[
    [Color(0xFF5E60CE), Color(0xFF6930C3)],
    [Color(0xFF3A86FF), Color(0xFF4361EE)],
    [Color(0xFF2A9D8F), Color(0xFF1D7874)],
    [Color(0xFFEF476F), Color(0xFFFF7B00)],
    [Color(0xFF6A4C93), Color(0xFF3C6997)],
    [Color(0xFF0077B6), Color(0xFF00B4D8)],
  ];

  final idx = seed.abs() % palettes.length;
  return palettes[idx];
}
