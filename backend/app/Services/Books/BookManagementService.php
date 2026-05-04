<?php

namespace App\Services\Books;

use App\Contracts\Books\BookIndexPayloadWriterInterface;
use App\Contracts\Books\BookManagementServiceInterface;
use App\Contracts\Books\TitleNormalizerInterface;
use App\Models\Book;
use App\Models\User;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

final class BookManagementService implements BookManagementServiceInterface
{
    public function __construct(
        private readonly TitleNormalizerInterface $titleNormalizer,
        private readonly BookIndexPayloadWriterInterface $indexPayloadWriter,
    ) {}

    public function createBook(User $publisher, array $payload): Book
    {
        return DB::transaction(function () use ($publisher, $payload): Book {
            $book = Book::query()->create([
                'user_id' => $publisher->id,
                'title' => $payload['titulo'],
                'num_pages' => $payload['numero_paginas'],
            ]);

            $this->indexPayloadWriter->replaceTreeFromPayload($book, $payload['indices'] ?? []);

            return $book->fresh(['user', 'indices']) ?? $book;
        });
    }

    public function updateBook(Book $book, array $payload): Book
    {
        return DB::transaction(function () use ($book, $payload): Book {
            $book->update([
                'title' => $payload['titulo'],
                'num_pages' => $payload['numero_paginas'],
            ]);

            $book = $book->fresh() ?? $book;

            $this->indexPayloadWriter->replaceTreeFromPayload($book, $payload['indices'] ?? []);

            return $book->fresh(['user', 'indices']) ?? $book;
        });
    }

    public function deleteBook(Book $book): void
    {
        $book->delete();
    }

    public function listBooks(?string $titulo, ?string $tituloDoIndice): Collection
    {
        $query = Book::query()->with(['user', 'indices'])->orderByDesc('id');

        if ($titulo !== null && trim($titulo) !== '') {
            $norm = $this->titleNormalizer->normalize($titulo);
            $query->where('title_normalized', 'like', '%'.$norm.'%');
        }

        if ($tituloDoIndice !== null && trim($tituloDoIndice) !== '') {
            $needle = $this->titleNormalizer->normalize($tituloDoIndice);
            $query->whereHas('indices', function ($q) use ($needle): void {
                $q->where('title_normalized', 'like', '%'.$needle.'%');
            });
        }

        return $query->get();
    }
}
