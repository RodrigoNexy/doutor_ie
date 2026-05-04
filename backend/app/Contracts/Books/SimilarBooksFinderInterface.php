<?php

namespace App\Contracts\Books;

use App\Data\Books\SimilarBookMatch;
use App\Models\Book;
use Illuminate\Support\Collection;

interface SimilarBooksFinderInterface
{
    public function findSimilarTo(Book $reference): Collection;
}
