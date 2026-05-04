<?php

namespace App\Contracts\Books;

use App\Models\Book;

interface BookIndexNestedSerializerInterface
{
    public function toApiTree(Book $book, ?string $tituloDoIndiceFilter): array;
}
