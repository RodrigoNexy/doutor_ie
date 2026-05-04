import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../models/similar_book.dart';
import 'book_detail_page.dart';

class SimilarBooksPage extends ConsumerStatefulWidget {
  const SimilarBooksPage({super.key, required this.bookId});

  final int bookId;

  @override
  ConsumerState<SimilarBooksPage> createState() => _SimilarBooksPageState();
}

class _SimilarBooksPageState extends ConsumerState<SimilarBooksPage> {
  late Future<List<SimilarBook>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SimilarBook>> _load() {
    return ref.read(booksRemoteDataSourceProvider).similar(widget.bookId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Livros similares')),
      body: FutureBuilder<List<SimilarBook>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Erro ao carregar similares: ${snapshot.error}'),
            );
          }
          final items = snapshot.data ?? const <SimilarBook>[];
          if (items.isEmpty) {
            return const Center(child: Text('Nenhum livro similar encontrado.'));
          }
          return ListView.separated(
            itemCount: items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = items[index];
              return ListTile(
                title: Text(item.book.titulo),
                subtitle: Text(
                  'Similaridade: ${(item.pontuacaoSimilaridade * 100).toStringAsFixed(1)}%',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(
                      builder: (_) => BookDetailPage(bookId: item.book.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
