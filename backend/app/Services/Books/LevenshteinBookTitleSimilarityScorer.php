<?php

namespace App\Services\Books;

use App\Contracts\Books\BookTitleSimilarityScorerInterface;

final class LevenshteinBookTitleSimilarityScorer implements BookTitleSimilarityScorerInterface
{
    public function similarityBetweenNormalized(string $a, string $b): float
    {
        if ($a === $b) {
            return 1.0;
        }

        if ($a === '' || $b === '') {
            return 0.0;
        }

        $distance = levenshtein($a, $b);
        $maxLen = max(mb_strlen($a), mb_strlen($b), 1);

        return max(0.0, 1.0 - ($distance / $maxLen));
    }
}
