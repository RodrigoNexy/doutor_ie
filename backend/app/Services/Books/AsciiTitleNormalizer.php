<?php

namespace App\Services\Books;

use App\Contracts\Books\TitleNormalizerInterface;
use Illuminate\Support\Str;

final class AsciiTitleNormalizer implements TitleNormalizerInterface
{
    public function normalize(string $title): string
    {
        return Str::lower(Str::ascii(trim($title)));
    }
}
