<?php

namespace App\Http\Resources;

use App\Contracts\Books\BookIndexNestedSerializerInterface;
use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class BookResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        $tituloDoIndice = $request->query('titulo_do_indice');
        $filter = is_string($tituloDoIndice) ? $tituloDoIndice : null;

        $indices = app(BookIndexNestedSerializerInterface::class)->toApiTree($this->resource, $filter);

        return [
            'id' => $this->id,
            'titulo' => $this->title,
            'usuario_publicador' => new UserResource($this->whenLoaded('user')),
            'numero_paginas' => $this->num_pages,
            'indices' => $indices,
        ];
    }
}
