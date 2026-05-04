<?php

namespace App\Contracts\Books;

interface TitleNormalizerInterface
{
    public function normalize(string $title): string;
}
