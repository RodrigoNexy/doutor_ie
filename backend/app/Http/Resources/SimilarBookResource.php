<?php

namespace App\Http\Resources;

use App\Data\Books\SimilarBookMatch;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class SimilarBookResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        /** @var SimilarBookMatch $match */
        $match = $this->resource;

        return array_merge(
            (new BookResource($match->book))->toArray($request),
            [
                'pontuacao_similaridade' => round($match->pontuacaoSimilaridade, 4),
            ],
        );
    }
}
