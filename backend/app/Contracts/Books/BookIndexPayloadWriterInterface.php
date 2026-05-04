<?php

namespace App\Contracts\Books;

use App\Models\Book;

interface BookIndexPayloadWriterInterface
{
    public function replaceTreeFromPayload(Book $book, array $indicesTree): void;
}
