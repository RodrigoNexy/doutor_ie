<?php

namespace App\Http\Requests\Book;

use App\Models\Book;
use App\Rules\ValidNestedBookIndices;
use Illuminate\Foundation\Http\FormRequest;

class UpdateBookRequest extends FormRequest
{
    public function authorize(): bool
    {
        $book = $this->route('book');

        return $book instanceof Book && $this->user() !== null && $this->user()->can('update', $book);
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
