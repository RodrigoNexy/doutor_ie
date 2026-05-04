<?php

namespace App\Contracts\Books;

use App\Models\Book;
use App\Models\User;
use Illuminate\Support\Collection;

interface BookManagementServiceInterface
{
    public function createBook(User $publisher, array $payload): Book;

    public function updateBook(Book $book, array $payload): Book;

    public function deleteBook(Book $book): void;

    public function listBooks(?string $titulo, ?string $tituloDoIndice): Collection;
}
