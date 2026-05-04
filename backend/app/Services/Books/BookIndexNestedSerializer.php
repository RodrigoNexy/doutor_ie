<?php

namespace App\Services\Books;

use App\Contracts\Books\BookIndexNestedSerializerInterface;
use App\Contracts\Books\TitleNormalizerInterface;
use App\Models\Book;
use App\Models\BookIndex;
use Illuminate\Support\Collection;

final class BookIndexNestedSerializer implements BookIndexNestedSerializerInterface
{
    public function __construct(
        private readonly TitleNormalizerInterface $titleNormalizer,
    ) {}

    public function toApiTree(Book $book, ?string $tituloDoIndiceFilter): array
    {
        if (! $book->relationLoaded('indices')) {
            $book->load('indices');
        }

        $all = $book->indices->sortBy('id')->values();

        if ($tituloDoIndiceFilter === null || trim($tituloDoIndiceFilter) === '') {
            return $this->buildLevel($all, null);
        }

        $needle = $this->titleNormalizer->normalize($tituloDoIndiceFilter);
        $allowedIds = $this->collectMatchingPathIds($all, $needle);

        if ($allowedIds->isEmpty()) {
            return [];
        }

        $filtered = $all->whereIn('id', $allowedIds);

        return $this->buildLevel($filtered, null);
    }

    private function buildLevel(Collection $indices, ?int $parentId): array
    {
        return $indices
            ->filter(fn (BookIndex $index): bool => $index->parent_id === $parentId)
            ->values()
            ->map(function (BookIndex $index) use ($indices): array {
                return [
                    'titulo' => $index->title,
                    'pagina' => $index->page,
                    'subindices' => $this->buildLevel($indices, $index->id),
                ];
            })
            ->all();
    }

    private function collectMatchingPathIds(Collection $all, string $needle): Collection
    {
        $ids = collect();

        foreach ($all as $index) {
            if (! str_contains($index->title_normalized, $needle)) {
                continue;
            }

            $current = $index;
            while ($current !== null) {
                $ids->push($current->id);
                if ($current->parent_id === null) {
                    break;
                }
                $current = $all->firstWhere('id', $current->parent_id);
            }
        }

        return $ids->unique()->values();
    }
}
