<?php

namespace App\Observers;

use App\Contracts\Books\TitleNormalizerInterface;
use App\Models\Book;

final class BookObserver
{
    public function __construct(
        private readonly TitleNormalizerInterface $titleNormalizer,
    ) {}

    public function saving(Book $book): void
    {
        if ($book->isDirty('title')) {
            $book->title_normalized = $this->titleNormalizer->normalize($book->title);
        }
    }
}
