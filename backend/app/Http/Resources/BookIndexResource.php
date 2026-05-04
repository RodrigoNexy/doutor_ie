<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Collection;

final class BookIndexResource extends JsonResource
{
    public function __construct($resource)
    {
        parent::__construct($resource);
    }

    public function toArray(Request $request): array
    {
        $node = $this->resource;

        $children = $node['subindices'] ?? [];

        return [
            'titulo' => $node['titulo'],
            'pagina' => $node['pagina'],
            'subindices' => Collection::make($children)
                ->map(fn (mixed $child): array => (new self(
                    is_array($child) ? $child : []
                ))->toArray($request))
                ->all(),
        ];
    }
}
