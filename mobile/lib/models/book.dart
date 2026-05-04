import 'auth_user.dart';
import 'book_index_node.dart';

class Book {
  const Book({
    required this.id,
    required this.titulo,
    required this.numeroPaginas,
    required this.indices,
    this.usuarioPublicador,
  });

  final int id;
  final String titulo;
  final int numeroPaginas;
  final List<BookIndexNode> indices;
  final AuthUser? usuarioPublicador;

  factory Book.fromJson(Map<String, dynamic> json) {
    final rawIndices = json['indices'];
    final indices = <BookIndexNode>[];
    if (rawIndices is List) {
      for (final item in rawIndices) {
        if (item is Map<String, dynamic>) {
          indices.add(BookIndexNode.fromJson(item));
        }
      }
    }

    final numeroRaw = json['numero_paginas'];
    final numeroPaginas = numeroRaw is int
        ? numeroRaw
        : int.tryParse(numeroRaw?.toString() ?? '') ?? 0;

    AuthUser? user;
    final rawUser = json['usuario_publicador'];
    if (rawUser is Map<String, dynamic>) {
      user = AuthUser.fromJson(rawUser);
    }

    return Book(
      id: (json['id'] as num).toInt(),
      titulo: json['titulo']?.toString() ?? '',
      numeroPaginas: numeroPaginas,
      indices: indices,
      usuarioPublicador: user,
    );
  }
}
