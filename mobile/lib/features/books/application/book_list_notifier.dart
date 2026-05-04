import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../models/book.dart';
import '../../../services/auth/auth_login_exception.dart';
import '../../../services/books/books_remote_data_source.dart';

class BookListState {
  const BookListState({
    this.isLoading = false,
    this.books = const <Book>[],
    this.errorMessage,
    this.filtroTitulo = '',
    this.filtroTituloIndice = '',
  });

  final bool isLoading;
  final List<Book> books;
  final String? errorMessage;
  final String filtroTitulo;
  final String filtroTituloIndice;

  BookListState copyWith({
    bool? isLoading,
    List<Book>? books,
    Object? errorMessage = _sentinel,
    String? filtroTitulo,
    String? filtroTituloIndice,
  }) {
    return BookListState(
      isLoading: isLoading ?? this.isLoading,
      books: books ?? this.books,
      errorMessage: identical(errorMessage, _sentinel)
          ? this.errorMessage
          : errorMessage as String?,
      filtroTitulo: filtroTitulo ?? this.filtroTitulo,
      filtroTituloIndice: filtroTituloIndice ?? this.filtroTituloIndice,
    );
  }
}

const Object _sentinel = Object();

class BookListNotifier extends StateNotifier<BookListState> {
  BookListNotifier(
    this._remote, {
    Future<void> Function()? onUnauthorized,
  })  : _onUnauthorized = onUnauthorized,
        super(const BookListState());

  final BooksRemoteDataSource _remote;
  final Future<void> Function()? _onUnauthorized;

  Future<void> load() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      final books = await _remote.list(
        titulo: state.filtroTitulo,
        tituloDoIndice: state.filtroTituloIndice,
      );
      state = state.copyWith(isLoading: false, books: books);
    } on AuthLoginException catch (e) {
      if (_isUnauthorized(e.message)) {
        await _onUnauthorized?.call();
        state = state.copyWith(
          isLoading: false,
          books: const <Book>[],
          errorMessage: null,
        );
        return;
      }
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } on Object {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Erro ao carregar livros.',
      );
    }
  }

  void setFiltros({
    required String titulo,
    required String tituloIndice,
  }) {
    state = state.copyWith(
      filtroTitulo: titulo,
      filtroTituloIndice: tituloIndice,
      errorMessage: null,
    );
  }

  Future<void> deleteBook(int bookId) async {
    try {
      await _remote.delete(bookId);
      await load();
    } on AuthLoginException catch (e) {
      if (_isUnauthorized(e.message)) {
        await _onUnauthorized?.call();
        state = state.copyWith(errorMessage: null, books: const <Book>[]);
        return;
      }
      state = state.copyWith(errorMessage: e.message);
    } on Object {
      state = state.copyWith(errorMessage: 'Erro ao excluir livro.');
    }
  }

  bool _isUnauthorized(String message) {
    final normalized = message.trim().toLowerCase();
    return normalized.contains('unauthenticated');
  }
}
