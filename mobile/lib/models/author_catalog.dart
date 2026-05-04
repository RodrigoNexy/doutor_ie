import 'book.dart';

class AuthorCatalog {
  const AuthorCatalog({
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
