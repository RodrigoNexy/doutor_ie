class BookIndexNode {
  const BookIndexNode({
    required this.titulo,
    required this.pagina,
    required this.subindices,
  });

  final String titulo;
  final int pagina;
  final List<BookIndexNode> subindices;

  factory BookIndexNode.fromJson(Map<String, dynamic> json) {
    final rawChildren = json['subindices'];
    final children = <BookIndexNode>[];
    if (rawChildren is List) {
      for (final child in rawChildren) {
        if (child is Map<String, dynamic>) {
          children.add(BookIndexNode.fromJson(child));
        }
      }
    }

    final paginaRaw = json['pagina'];
    final pagina = paginaRaw is int
        ? paginaRaw
        : int.tryParse(paginaRaw?.toString() ?? '') ?? 1;

    return BookIndexNode(
      titulo: json['titulo']?.toString() ?? '',
      pagina: pagina,
      subindices: children,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'titulo': titulo,
      'pagina': pagina,
      'subindices': subindices.map((item) => item.toJson()).toList(),
    };
  }
}
