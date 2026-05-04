import 'package:flutter/material.dart';

import '../../../../models/author_catalog.dart';
import '../../../../models/book.dart';

Future<void> showAuthorPreviewSheet({
  required BuildContext context,
  required AuthorCatalog author,
  required Future<void> Function(Book book) onOpenBook,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _AuthorPreviewSheet(
      author: author,
      onOpenBook: onOpenBook,
    ),
  );
}

class _AuthorPreviewSheet extends StatelessWidget {
  const _AuthorPreviewSheet({
    required this.author,
    required this.onOpenBook,
  });

  final AuthorCatalog author;
  final Future<void> Function(Book book) onOpenBook;

  @override
  Widget build(BuildContext context) {
    final initial = author.nome.trim().isEmpty
        ? '?'
        : author.nome.trim().substring(0, 1).toUpperCase();

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3D5D9),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  CircleAvatar(
                    radius: 34,
                    backgroundColor: const Color(0xFFD9DEF5),
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          author.nome,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1D1D1F),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          author.email,
                          style: const TextStyle(
                            color: Color(0xFF6E727A),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${author.books.length} livro(s) publicado(s)',
                          style: const TextStyle(
                            color: Color(0xFF6E727A),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Text(
                'Livros do autor',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(height: 10),
              if (author.books.isEmpty)
                const Expanded(
                  child: Center(child: Text('Este autor ainda não tem livros.')),
                )
              else
                Expanded(
                  child: GridView.builder(
                    itemCount: author.books.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.72,
                        ),
                    itemBuilder: (context, index) {
                      final book = author.books[index];
                      return _AuthorBookCard(
                        book: book,
                        onTap: () async {
                          Navigator.of(context).pop();
                          await onOpenBook(book);
                        },
                      );
                    },
                  ),
                ),
              const SizedBox(height: 8),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF1D1D1F),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Fechar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AuthorBookCard extends StatelessWidget {
  const _AuthorBookCard({
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 1,
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
                  ],
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
