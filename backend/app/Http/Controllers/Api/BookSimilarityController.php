<?php

namespace App\Http\Controllers\Api;

use App\Contracts\Books\SimilarBooksFinderInterface;
use App\Http\Controllers\Controller;
use App\Http\Requests\Book\SimilarBooksRequest;
use App\Http\Resources\SimilarBookResource;
use App\Models\Book;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;

final class BookSimilarityController extends Controller
{
    public function __construct(
        private readonly SimilarBooksFinderInterface $similarBooksFinder,
    ) {}

    public function __invoke(SimilarBooksRequest $request, Book $book): AnonymousResourceCollection
    {
        $matches = $this->similarBooksFinder->findSimilarTo($book);

        return SimilarBookResource::collection($matches);
    }
}
