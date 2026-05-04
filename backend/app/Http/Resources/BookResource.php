<?php

namespace App\Http\Resources;

use App\Contracts\Books\BookIndexNestedSerializerInterface;
use App\Models\Book;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;
use Illuminate\Support\Collection;


class BookResource extends JsonResource
{
    private readonly ?BookIndexNestedSerializerInterface $indexSerializer;

    public function __construct($resource, mixed $indexSerializerOrMapIntoKey = null)
    {
        parent::__construct($resource);

        $this->indexSerializer = $indexSerializerOrMapIntoKey instanceof BookIndexNestedSerializerInterface
            ? $indexSerializerOrMapIntoKey
            : null;
    }

    public function toArray(Request $request): array
    {
        $serializer = $this->indexSerializer ?? resolve(BookIndexNestedSerializerInterface::class);

        $tituloDoIndice = $request->query('titulo_do_indice');
        $filter = is_string($tituloDoIndice) ? $tituloDoIndice : null;

        $tree = $serializer->toApiTree($this->resource, $filter);

        $indices = Collection::make($tree)
            ->map(fn (array $node): array => (new BookIndexResource($node))->toArray($request))
            ->all();

        return [
            'id' => $this->id,
            'titulo' => $this->title,
            'usuario_publicador' => new UserResource($this->whenLoaded('user')),
            'numero_paginas' => $this->num_pages,
            'indices' => $indices,
        ];
    }
}
