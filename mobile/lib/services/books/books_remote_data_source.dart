import '../../models/book.dart';
import '../../models/book_index_draft.dart';
import '../../models/similar_book.dart';

abstract class BooksRemoteDataSource {
  Future<List<Book>> list({
    String? titulo,
    String? tituloDoIndice,
  });

  Future<Book> show(int bookId);

  Future<Book> create({
    required String titulo,
    required int numeroPaginas,
    required List<BookIndexDraft> indices,
  });

  Future<Book> update({
    required int bookId,
    required String titulo,
    required int numeroPaginas,
    required List<BookIndexDraft> indices,
  });

  Future<void> delete(int bookId);

  Future<List<SimilarBook>> similar(int bookId);
}
