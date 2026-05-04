import 'book_index_node.dart';

class BookIndexDraft {
  BookIndexDraft({
    required this.id,
    this.titulo = '',
    this.pagina = '',
    List<BookIndexDraft>? filhos,
  }) : filhos = filhos ?? <BookIndexDraft>[];

  final String id;
  String titulo;
  String pagina;
  final List<BookIndexDraft> filhos;

  factory BookIndexDraft.empty(String id) {
    return BookIndexDraft(id: id);
  }

  factory BookIndexDraft.fromNode(BookIndexNode node, String id) {
    return BookIndexDraft(
      id: id,
      titulo: node.titulo,
      pagina: node.pagina.toString(),
      filhos: node.subindices
          .asMap()
          .entries
          .map(
            (entry) => BookIndexDraft.fromNode(
              entry.value,
              '${id}_${entry.key}',
            ),
          )
          .toList(),
    );
  }

  Map<String, dynamic> toPayload() {
    final page = int.tryParse(pagina.trim()) ?? 1;
    return {
      'titulo': titulo.trim(),
      'pagina': page,
      'subindices': filhos.map((item) => item.toPayload()).toList(),
    };
  }
}
