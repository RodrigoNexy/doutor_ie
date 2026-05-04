<?php

namespace App\Data\Books;

use App\Models\Book;

readonly class SimilarBookMatch
{
    public function __construct(
        public Book $book,
        public float $pontuacaoSimilaridade,
    ) {}
}
