<?php

namespace App\Http\Requests\Book;

use App\Models\Book;
use Illuminate\Foundation\Http\FormRequest;

class SimilarBooksRequest extends FormRequest
{
    public function authorize(): bool
    {
        $book = $this->route('book');

        return $book instanceof Book && $this->user() !== null && $this->user()->can('similar', $book);
    }

    public function rules(): array
    {
        return [];
    }
}
