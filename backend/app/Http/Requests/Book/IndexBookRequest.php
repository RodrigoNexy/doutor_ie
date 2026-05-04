<?php

namespace App\Http\Requests\Book;

use App\Models\Book;
use Illuminate\Foundation\Http\FormRequest;

class IndexBookRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user() !== null && $this->user()->can('viewAny', Book::class);
    }

    public function rules(): array
    {
        return [
            'titulo' => ['sometimes', 'nullable', 'string', 'max:255'],
            'titulo_do_indice' => ['sometimes', 'nullable', 'string', 'max:255'],
        ];
    }

    public function validationData(): array
    {
        return $this->query();
    }
}
