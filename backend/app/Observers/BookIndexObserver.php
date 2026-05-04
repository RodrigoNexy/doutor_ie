<?php

namespace App\Observers;

use App\Contracts\Books\TitleNormalizerInterface;
use App\Models\BookIndex;

final class BookIndexObserver
{
    public function __construct(
        private readonly TitleNormalizerInterface $titleNormalizer,
    ) {}

    public function saving(BookIndex $bookIndex): void
    {
        if ($bookIndex->isDirty('title')) {
            $bookIndex->title_normalized = $this->titleNormalizer->normalize($bookIndex->title);
        }
    }
}
