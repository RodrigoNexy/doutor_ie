import 'package:dio/dio.dart';

import '../../models/book.dart';
import '../../models/book_index_draft.dart';
import '../../models/similar_book.dart';
import '../auth/auth_login_exception.dart';
import 'books_remote_data_source.dart';

class DioBooksRemoteDataSource implements BooksRemoteDataSource {
  DioBooksRemoteDataSource(this._dio);

  final Dio _dio;

  @override
  Future<List<Book>> list({
    String? titulo,
    String? tituloDoIndice,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        '/books',
        queryParameters: {
          if (titulo != null && titulo.trim().isNotEmpty) 'titulo': titulo,
          if (tituloDoIndice != null && tituloDoIndice.trim().isNotEmpty)
            'titulo_do_indice': tituloDoIndice,
        },
      );
      final data = _readDataList(response.data);
      return data.map(Book.fromJson).toList();
    } on DioException catch (e) {
      throw AuthLoginException(_messageFromDio(e));
    }
  }

  @override
  Future<Book> show(int bookId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/books/$bookId');
      return Book.fromJson(_readDataMap(response.data));
    } on DioException catch (e) {
      throw AuthLoginException(_messageFromDio(e));
    }
  }

  @override
  Future<Book> create({
    required String titulo,
    required int numeroPaginas,
    required List<BookIndexDraft> indices,
  }) async {
    return _save(
      path: '/books',
      method: 'POST',
      titulo: titulo,
      numeroPaginas: numeroPaginas,
      indices: indices,
    );
  }

  @override
  Future<Book> update({
    required int bookId,
    required String titulo,
    required int numeroPaginas,
    required List<BookIndexDraft> indices,
  }) async {
    return _save(
      path: '/books/$bookId',
      method: 'PUT',
      titulo: titulo,
      numeroPaginas: numeroPaginas,
      indices: indices,
    );
  }

  Future<Book> _save({
    required String path,
    required String method,
    required String titulo,
    required int numeroPaginas,
    required List<BookIndexDraft> indices,
  }) async {
    try {
      final body = {
        'titulo': titulo.trim(),
        'numero_paginas': numeroPaginas,
        'indices': indices.map((item) => item.toPayload()).toList(),
      };

      final response = await _dio.request<Map<String, dynamic>>(
        path,
        data: body,
        options: Options(method: method),
      );
      return Book.fromJson(_readDataMap(response.data));
    } on DioException catch (e) {
      throw AuthLoginException(_messageFromDio(e));
    }
  }

  @override
  Future<void> delete(int bookId) async {
    try {
      await _dio.delete<void>('/books/$bookId');
    } on DioException catch (e) {
      throw AuthLoginException(_messageFromDio(e));
    }
  }

  @override
  Future<List<SimilarBook>> similar(int bookId) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/books/$bookId/similar');
      final data = _readDataList(response.data);
      return data.map(SimilarBook.fromJson).toList();
    } on DioException catch (e) {
      throw AuthLoginException(_messageFromDio(e));
    }
  }

  List<Map<String, dynamic>> _readDataList(Map<String, dynamic>? json) {
    final data = json?['data'];
    if (data is! List) {
      return const [];
    }
    final out = <Map<String, dynamic>>[];
    for (final item in data) {
      if (item is Map<String, dynamic>) {
        out.add(item);
      }
    }
    return out;
  }

  Map<String, dynamic> _readDataMap(Map<String, dynamic>? json) {
    final data = json?['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    throw const AuthLoginException('Resposta inválida da API.');
  }

  String _messageFromDio(DioException e) {
    final data = e.response?.data;
    if (data is Map<String, dynamic>) {
      final message = data['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      final errors = data['errors'];
      if (errors is Map) {
        final parts = <String>[];
        for (final entry in errors.entries) {
          final value = entry.value;
          if (value is List && value.isNotEmpty) {
            parts.add(value.first.toString());
          }
        }
        if (parts.isNotEmpty) {
          return parts.join(' ');
        }
      }
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Sem ligação ao servidor. Verifique a API.';
    }
    return 'Falha ao carregar dados dos livros.';
  }
}
