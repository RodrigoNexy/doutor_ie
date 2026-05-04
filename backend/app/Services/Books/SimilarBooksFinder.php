<?php

namespace App\Services\Books;

use App\Contracts\Books\BookTitleSimilarityScorerInterface;
use App\Contracts\Books\SimilarBooksFinderInterface;
use App\Data\Books\SimilarBookMatch;
use App\Models\Book;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

final class SimilarBooksFinder implements SimilarBooksFinderInterface
{
    private const CANDIDATE_CAP = 400;

    private const MIN_SIMILARITY = 0.72;

    public function __construct(
        private readonly BookTitleSimilarityScorerInterface $similarityScorer,
    ) {}

    public function findSimilarTo(Book $reference): Collection
    {
        $needle = $reference->title_normalized;
        $len = mb_strlen($needle);
        $prefixLen = min(4, max(1, $len));
        $prefix = mb_substr($needle, 0, $prefixLen);

        $minLength = max(1, $len - 4);
        $maxLength = $len + 4;

        $candidates = Book::query()
            ->where('id', '!=', $reference->id)
            ->where(function ($q) use ($needle, $prefix, $minLength, $maxLength): void {
                $q->where('title_normalized', $needle)
                    ->orWhere('title_normalized', 'like', $prefix.'%')
                    ->orWhereBetween(DB::raw('LENGTH(title_normalized)'), [$minLength, $maxLength]);
            })
            ->with(['user', 'indices'])
            ->limit(self::CANDIDATE_CAP)
            ->get();

        return $candidates
            ->map(function (Book $candidate) use ($needle): ?SimilarBookMatch {
                $score = $this->similarityScorer->similarityBetweenNormalized(
                    $needle,
                    $candidate->title_normalized,
                );

                if ($score < self::MIN_SIMILARITY) {
                    return null;
                }

                return new SimilarBookMatch($candidate, $score);
            })
            ->filter()
            ->sortByDesc(fn (SimilarBookMatch $m): float => $m->pontuacaoSimilaridade)
            ->values();
    }
}
