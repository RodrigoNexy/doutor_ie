import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/stripe_colors.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../models/author_catalog.dart';
import '../../../models/book.dart';
import '../../authors/application/author_catalog_mapper.dart';
import '../../authors/presentation/widgets/author_preview_sheet.dart';
import '../../books/presentation/book_detail_page.dart';
import '../../books/presentation/book_form_page.dart';
import '../../books/presentation/widgets/book_preview_sheet.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeBookListProvider);

    ref.listen(authSessionProvider, (previous, next) {
      if (!next.isAuthenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            onPressed: () async {
              await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => const BookFormPage(),
                ),
              );
              await ref.read(homeBookListProvider.notifier).load();
            },
            icon: const Icon(Icons.add),
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
      bottomNavigationBar: const AppBottomNavBar(currentTab: AppTab.home),
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
                  style: const TextStyle(color: StripeColors.errorRuby),
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final books = state.books;
          final featured = books.isNotEmpty ? books.first : null;
          final authors = mapAuthorsFromBooks(books);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SpecialOfferCard(featuredBook: featured),
              const SizedBox(height: 18),
              _SectionTitle(
                title: 'Todos os livros',
                onSeeAll: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/books',
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 10),
              if (books.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Center(child: Text('Nenhum livro encontrado.')),
                )
              else
                SizedBox(
                  height: 180,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: books.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 10),
                    itemBuilder: (context, index) {
                      final book = books[index];
                      return _BookCard(
                        book: book,
                        onTap: () async {
                          await showBookPreviewSheet(
                            context: context,
                            book: book,
                            onOpenDetails: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => BookDetailPage(bookId: book.id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 20),
              _SectionTitle(
                title: 'Autores',
                onSeeAll: () {
                  Navigator.of(context).pushNamedAndRemoveUntil(
                    '/authors',
                    (route) => false,
                  );
                },
              ),
              const SizedBox(height: 10),
              if (authors.isEmpty)
                const Text('Sem autores ainda.')
              else
                SizedBox(
                  height: 120,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: authors.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemBuilder: (context, index) {
                      final author = authors[index];
                      return _AuthorChip(
                        author: author,
                        onTap: () async {
                          await showAuthorPreviewSheet(
                            context: context,
                            author: author,
                            onOpenBook: (book) async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => BookDetailPage(bookId: book.id),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.onSeeAll,
  });

  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        TextButton(
          onPressed: onSeeAll,
          child: const Text('Ver todos'),
        ),
      ],
    );
  }
}

class _SpecialOfferCard extends StatelessWidget {
  const _SpecialOfferCard({required this.featuredBook});

  final Book? featuredBook;

  @override
  Widget build(BuildContext context) {
    final title = featuredBook?.titulo ?? 'Crie seu primeiro livro';
    final pages = featuredBook?.numeroPaginas ?? 0;
    final palette = _coverPalette(featuredBook?.id ?? 0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Destaque',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
                ),
                const SizedBox(height: 4),
                Text(
                  pages > 0 ? '$pages páginas' : 'Sem livros cadastrados',
                  style: const TextStyle(color: Color(0xFF666A71)),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: featuredBook == null
                      ? null
                      : () {
                          showBookPreviewSheet(
                            context: context,
                            book: featuredBook!,
                            onOpenDetails: () {
                              Navigator.of(context).pop();
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      BookDetailPage(bookId: featuredBook!.id),
                                ),
                              );
                            },
                          );
                        },
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1D1D1F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(22),
                    ),
                  ),
                  child: const Text('Ler agora'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 92,
            height: 128,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: palette,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(8),
            child: Center(
              child: Text(
                title,
                maxLines: 5,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BookCard extends StatelessWidget {
  const _BookCard({
    required this.book,
    required this.onTap,
  });

  final Book book;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final palette = _coverPalette(book.id);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 135,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 120,
              width: 135,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: palette,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.28),
                        borderRadius: BorderRadius.circular(99),
                      ),
                      child: Text(
                        '${book.numeroPaginas}p',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Text(
                        book.titulo,
                        maxLines: 3,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              book.titulo,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            Text(
              '${book.numeroPaginas} páginas',
              style: const TextStyle(color: Color(0xFF666A71)),
            ),
          ],
        ),
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

class _AuthorChip extends StatelessWidget {
  const _AuthorChip({
    required this.author,
    required this.onTap,
  });

  final AuthorCatalog author;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final trimmed = author.nome.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.substring(0, 1);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 88,
        child: Column(
          children: [
            CircleAvatar(
              radius: 34,
              backgroundColor: const Color(0xFFD9DEF5),
              child: Text(
                initial.toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              author.nome,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            Text(
              '${author.books.length} livros',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 12,
                color: Color(0xFF6E727A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
