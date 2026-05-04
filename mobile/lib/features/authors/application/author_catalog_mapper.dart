import '../../../models/author_catalog.dart';
import '../../../models/book.dart';

List<AuthorCatalog> mapAuthorsFromBooks(List<Book> books) {
  final map = <int, _AuthorAccumulator>{};

  for (final book in books) {
    final user = book.usuarioPublicador;
    if (user == null) {
      continue;
    }

    final current = map[user.id];
    if (current == null) {
      map[user.id] = _AuthorAccumulator(
        id: user.id,
        nome: user.nome,
        email: user.email,
        books: <Book>[book],
      );
    } else {
      current.books.add(book);
    }
  }

  final result = map.values
      .map(
        (item) => AuthorCatalog(
          id: item.id,
          nome: item.nome,
          email: item.email,
          books: item.books,
        ),
      )
      .toList(growable: false);

  result.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));
  return result;
}

class _AuthorAccumulator {
  _AuthorAccumulator({
    required this.id,
    required this.nome,
    required this.email,
    required this.books,
  });

  final int id;
  final String nome;
  final String email;
  final List<Book> books;
}
