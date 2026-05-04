import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/theme/stripe_colors.dart';
import '../../../models/book.dart';
import '../../../models/book_index_node.dart';
import 'book_form_page.dart';
import 'similar_books_page.dart';
import 'widgets/book_index_tree.dart';

class BookDetailPage extends ConsumerStatefulWidget {
  const BookDetailPage({
    super.key,
    required this.bookId,
  });

  final int bookId;

  @override
  ConsumerState<BookDetailPage> createState() => _BookDetailPageState();
}

class _BookDetailPageState extends ConsumerState<BookDetailPage> {
  late Future<Book> _future;
  bool _deleting = false;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Book> _load() {
    return ref.read(booksRemoteDataSourceProvider).show(widget.bookId);
  }

  Future<void> _reload() async {
    setState(() {
      _future = _load();
    });
    await _future;
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
      ref.invalidate(homeBookListProvider);
      ref.invalidate(catalogBookListProvider);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Livro excluído com sucesso.')),
      );
      Navigator.of(context).pop(true);
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhe do livro'),
        actions: [
          IconButton(
            onPressed: () => _reload(),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: FutureBuilder<Book>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Erro ao carregar livro: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final book = snapshot.data!;
          final resume = _buildResume(book);
          final coverPalette = _coverPalette(book.id);
          final canEditBook =
              session.currentUserId != null &&
              book.usuarioPublicador?.id == session.currentUserId;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: Container(
                  width: 180,
                  height: 240,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: coverPalette,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      book.titulo,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                book.titulo,
                style: const TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                book.usuarioPublicador?.nome ?? 'Autor não informado',
                style: const TextStyle(
                  color: Color(0xFF6E727A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              const _StarsRow(),
              const SizedBox(height: 14),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  _InfoChip(label: '${book.numeroPaginas} páginas'),
                  _InfoChip(label: '${book.indices.length} índice(s) raiz'),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                resume,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6E727A),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 10,
                runSpacing: 8,
                children: [
                  if (canEditBook)
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1D1F),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: _deleting
                          ? null
                          : () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BookFormPage(existingBook: book),
                          ),
                        );
                        await _reload();
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text('Editar'),
                    ),
                  if (canEditBook)
                    OutlinedButton.icon(
                      onPressed: _deleting ? null : () => _deleteBook(book),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: StripeColors.errorRuby,
                        side: const BorderSide(color: StripeColors.errorRuby),
                      ),
                      icon: const Icon(Icons.delete_outline),
                      label: Text(_deleting ? 'Excluindo...' : 'Excluir'),
                    ),
                  OutlinedButton.icon(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => SimilarBooksPage(bookId: book.id),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Livros similares'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: StripeColors.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: StripeColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Índices',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1D1D1F),
                      ),
                    ),
                    const SizedBox(height: 8),
                    BookIndexTree(indices: book.indices),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _buildResume(Book book) {
    final names = <String>[];

    void walk(List<BookIndexNode> list) {
      for (final node in list) {
        if (node.titulo.trim().isNotEmpty) {
          names.add(node.titulo.trim());
        }
        if (node.subindices.isNotEmpty) {
          walk(node.subindices);
        }
      }
    }

    walk(book.indices);
    final joined = names.take(3).join(', ');
    if (joined.isEmpty) {
      return 'Livro cadastrado no app com ${book.numeroPaginas} páginas.';
    }
    return 'Livro cadastrado no app com ${book.numeroPaginas} páginas. '
        'Principais tópicos: $joined.';
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F1F3),
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
        Icon(Icons.star, color: Color(0xFFFFB400), size: 20),
        Icon(Icons.star, color: Color(0xFFFFB400), size: 20),
        Icon(Icons.star, color: Color(0xFFFFB400), size: 20),
        Icon(Icons.star, color: Color(0xFFFFB400), size: 20),
        Icon(Icons.star, color: Color(0xFFFFB400), size: 20),
        SizedBox(width: 8),
        Text(
          '(5.0)',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
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
