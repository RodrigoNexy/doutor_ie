<?php

namespace App\Contracts\Books;

interface BookTitleSimilarityScorerInterface
{
    public function similarityBetweenNormalized(string $a, string $b): float;
}
