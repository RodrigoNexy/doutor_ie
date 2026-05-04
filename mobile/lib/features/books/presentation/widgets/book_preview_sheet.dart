import 'package:flutter/material.dart';

import '../../../../models/book.dart';
import '../../../../models/book_index_node.dart';

Future<void> showBookPreviewSheet({
  required BuildContext context,
  required Book book,
  required VoidCallback onOpenDetails,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _BookPreviewSheet(
      book: book,
      onOpenDetails: onOpenDetails,
    ),
  );
}

class _BookPreviewSheet extends StatelessWidget {
  const _BookPreviewSheet({
    required this.book,
    required this.onOpenDetails,
  });

  final Book book;
  final VoidCallback onOpenDetails;

  @override
  Widget build(BuildContext context) {
    final author = book.usuarioPublicador?.nome ?? 'Autor não informado';
    final resume = _buildResume(book);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: const BoxDecoration(
        color: Color(0xFFF5F5F6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 52,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD3D5D9),
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Center(
                child: Container(
                  width: 170,
                  height: 230,
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF87B8F9), Color(0xFF6C4DE6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: Text(
                      book.titulo,
                      textAlign: TextAlign.center,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                book.titulo,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                author,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF5E6168),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                resume,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF6E727A),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Avaliação',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1D1D1F),
                ),
              ),
              const SizedBox(height: 6),
              const Row(
                children: [
                  Icon(Icons.star, color: Color(0xFFFFB400)),
                  Icon(Icons.star, color: Color(0xFFFFB400)),
                  Icon(Icons.star, color: Color(0xFFFFB400)),
                  Icon(Icons.star, color: Color(0xFFFFB400)),
                  Icon(Icons.star, color: Color(0xFFFFB400)),
                  SizedBox(width: 8),
                  Text(
                    '(5.0)',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: onOpenDetails,
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF1D1D1F),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Ver detalhes'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFF1D1D1F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text('Fechar'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _buildResume(Book book) {
    final flatIndices = <String>[];
    void walk(List<BookIndexNode> nodes) {
      for (final node in nodes) {
        if (node.titulo.trim().isNotEmpty) {
          flatIndices.add(node.titulo.trim());
        }
        if (node.subindices.isNotEmpty) {
          walk(node.subindices);
        }
      }
    }

    walk(book.indices);
    final topics = flatIndices.take(3).join(', ');
    if (topics.isEmpty) {
      return 'Livro com ${book.numeroPaginas} páginas cadastrado no app.';
    }
    return 'Livro com ${book.numeroPaginas} páginas. Conteúdo cadastrado: $topics.';
  }
}
