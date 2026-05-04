<?php

namespace App\Http\Requests\Book;

use App\Models\Book;
use App\Rules\ValidNestedBookIndices;
use Illuminate\Foundation\Http\FormRequest;

class StoreBookRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null && $this->user()->can('create', Book::class);
    }

    public function rules(): array
    {
        return [
            'titulo' => ['required', 'string', 'max:255'],
            'numero_paginas' => ['required', 'integer', 'min:1'],
            'indices' => ['nullable', 'array', new ValidNestedBookIndices],
        ];
    }
}
