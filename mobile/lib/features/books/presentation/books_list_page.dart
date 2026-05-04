import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../models/book.dart';
import 'book_detail_page.dart';
import 'book_form_page.dart';
import 'widgets/book_preview_sheet.dart';

class BooksListPage extends ConsumerStatefulWidget {
  const BooksListPage({super.key});

  @override
  ConsumerState<BooksListPage> createState() => _BooksListPageState();
}

class _BooksListPageState extends ConsumerState<BooksListPage> {
  late final TextEditingController _bookTitleController;
  late final TextEditingController _indexTitleController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(catalogBookListProvider);
    _bookTitleController = TextEditingController(text: state.filtroTitulo);
    _indexTitleController = TextEditingController(text: state.filtroTituloIndice);
  }

  @override
  void dispose() {
    _bookTitleController.dispose();
    _indexTitleController.dispose();
    super.dispose();
  }

  Future<void> _applyFilters() async {
    ref.read(catalogBookListProvider.notifier).setFiltros(
      titulo: _bookTitleController.text.trim(),
      tituloIndice: _indexTitleController.text.trim(),
    );
    await ref.read(catalogBookListProvider.notifier).load();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(catalogBookListProvider);
    final width = MediaQuery.sizeOf(context).width;
    final crossAxisCount = width > 900 ? 5 : (width > 700 ? 4 : 3);

    ref.listen(authSessionProvider, (previous, next) {
      if (!next.isAuthenticated) {
        Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os livros'),
        actions: [
          IconButton(
            onPressed: () async {
              final created = await Navigator.of(context).push<bool>(
                MaterialPageRoute<bool>(
                  builder: (_) => const BookFormPage(),
                ),
              );
              if (created == true) {
                await ref.read(catalogBookListProvider.notifier).load();
                await ref.read(homeBookListProvider.notifier).load();
              }
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () => ref.read(catalogBookListProvider.notifier).load(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(currentTab: AppTab.books),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Catálogo',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF8A8A8D),
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'Todos os livros',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1D1D1F),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF4F5F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  TextField(
                    controller: _bookTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por livro',
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _indexTitleController,
                    decoration: const InputDecoration(
                      labelText: 'Filtrar por índice',
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            _bookTitleController.clear();
                            _indexTitleController.clear();
                            await _applyFilters();
                          },
                          child: const Text('Limpar'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: FilledButton(
                          onPressed: _applyFilters,
                          child: const Text('Filtrar'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Expanded(
              child: Builder(
                builder: (context) {
                  if (state.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state.errorMessage != null) {
                    return Center(
                      child: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Color(0xFFE05A5A)),
                      ),
                    );
                  }
                  if (state.books.isEmpty) {
                    return const Center(child: Text('Nenhum livro encontrado.'));
                  }

                  return GridView.builder(
                    itemCount: state.books.length,
                    padding: const EdgeInsets.only(bottom: 18),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.58,
                    ),
                    itemBuilder: (context, index) {
                      final book = state.books[index];
                      return _BookGridCard(
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
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BookGridCard extends StatelessWidget {
  const _BookGridCard({
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
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
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            book.titulo,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1D1D1F),
            ),
          ),
          const SizedBox(height: 2),
          const _StarsRow(),
        ],
      ),
    );
  }
}

class _StarsRow extends StatelessWidget {
  const _StarsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        Icon(Icons.star, size: 14, color: Color(0xFFFFB400)),
        Icon(Icons.star, size: 14, color: Color(0xFFFFB400)),
        Icon(Icons.star, size: 14, color: Color(0xFFFFB400)),
        Icon(Icons.star, size: 14, color: Color(0xFFFFB400)),
        Icon(Icons.star, size: 14, color: Color(0xFFFFB400)),
      ],
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
