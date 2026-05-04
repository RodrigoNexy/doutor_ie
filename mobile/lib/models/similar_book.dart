import 'book.dart';

class SimilarBook {
  const SimilarBook({
    required this.book,
    required this.pontuacaoSimilaridade,
  });

  final Book book;
  final double pontuacaoSimilaridade;

  factory SimilarBook.fromJson(Map<String, dynamic> json) {
    final scoreRaw = json['pontuacao_similaridade'];
    final score = scoreRaw is num
        ? scoreRaw.toDouble()
        : double.tryParse(scoreRaw?.toString() ?? '') ?? 0;

    return SimilarBook(
      book: Book.fromJson(json),
      pontuacaoSimilaridade: score,
    );
  }
}
