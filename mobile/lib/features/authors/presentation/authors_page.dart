import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers.dart';
import '../../../core/widgets/app_bottom_nav_bar.dart';
import '../../../models/author_catalog.dart';
import '../../../models/book.dart';
import '../../../models/book_index_node.dart';
import '../../books/presentation/book_detail_page.dart';
import '../application/author_catalog_mapper.dart';
import 'widgets/author_preview_sheet.dart';

class AuthorsPage extends ConsumerStatefulWidget {
  const AuthorsPage({super.key});

  @override
  ConsumerState<AuthorsPage> createState() => _AuthorsPageState();
}

class _AuthorsPageState extends ConsumerState<AuthorsPage> {
  final _authorNameController = TextEditingController();
  final _bookNameController = TextEditingController();
  final _indexNameController = TextEditingController();

  @override
  void dispose() {
    _authorNameController.dispose();
    _bookNameController.dispose();
    _indexNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(homeBookListProvider);
    final books = _filterBooksByBookAndIndex(
      state.books,
      _bookNameController.text.trim(),
      _indexNameController.text.trim(),
    );
    final authors = _filterAuthorsByName(
      mapAuthorsFromBooks(books),
      _authorNameController.text.trim(),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos os autores'),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentTab: AppTab.authors),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF4F5F7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: _authorNameController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por autor',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _bookNameController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por livro',
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _indexNameController,
                      onChanged: (_) => setState(() {}),
                      decoration: const InputDecoration(
                        labelText: 'Filtrar por índice',
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: OutlinedButton(
                        onPressed: () {
                          _authorNameController.clear();
                          _bookNameController.clear();
                          _indexNameController.clear();
                          setState(() {});
                        },
                        child: const Text('Limpar filtros'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              if (authors.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: Text('Nenhum autor encontrado.')),
                )
              else
                ...authors.map((author) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      tileColor: const Color(0xFFF4F5F7),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      leading: Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD9DEF5),
                          borderRadius: BorderRadius.circular(99),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Color(0xFF3A3D44),
                        ),
                      ),
                      title: Text(
                        author.nome,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(
                        '${author.books.length} livro(s)',
                        style: const TextStyle(color: Color(0xFF6E727A)),
                      ),
                      trailing: const Icon(Icons.chevron_right),
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
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }

  List<Book> _filterBooksByBookAndIndex(
    List<Book> books,
    String bookQuery,
    String indexQuery,
  ) {
    final normalizedBook = bookQuery.toLowerCase();
    final normalizedIndex = indexQuery.toLowerCase();

    return books.where((book) {
      final matchesBook = normalizedBook.isEmpty ||
          book.titulo.toLowerCase().contains(normalizedBook);
      final matchesIndex = normalizedIndex.isEmpty ||
          _containsIndex(book.indices, normalizedIndex);
      return matchesBook && matchesIndex;
    }).toList(growable: false);
  }

  bool _containsIndex(List<BookIndexNode> indices, String query) {
    for (final node in indices) {
      if (node.titulo.toLowerCase().contains(query)) {
        return true;
      }
      if (node.subindices.isNotEmpty && _containsIndex(node.subindices, query)) {
        return true;
      }
    }
    return false;
  }

  List<AuthorCatalog> _filterAuthorsByName(
    List<AuthorCatalog> authors,
    String query,
  ) {
    if (query.isEmpty) {
      return authors;
    }
    final normalized = query.toLowerCase();
    return authors
        .where((author) => author.nome.toLowerCase().contains(normalized))
        .toList(growable: false);
  }
}
