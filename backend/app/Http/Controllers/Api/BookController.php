<?php

namespace App\Http\Controllers\Api;

use App\Contracts\Books\BookManagementServiceInterface;
use App\Http\Controllers\Controller;
use App\Http\Requests\Book\IndexBookRequest;
use App\Http\Requests\Book\StoreBookRequest;
use App\Http\Requests\Book\UpdateBookRequest;
use App\Http\Resources\BookResource;
use App\Models\Book;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Resources\Json\AnonymousResourceCollection;
use Symfony\Component\HttpFoundation\Response;

final class BookController extends Controller
{
    public function __construct(
        private readonly BookManagementServiceInterface $bookManagement,
    ) {}

    public function index(IndexBookRequest $request): AnonymousResourceCollection
    {
        $this->authorize('viewAny', Book::class);

        $validated = $request->validated();
        $books = $this->bookManagement->listBooks(
            isset($validated['titulo']) ? (string) $validated['titulo'] : null,
            isset($validated['titulo_do_indice']) ? (string) $validated['titulo_do_indice'] : null,
        );

        return BookResource::collection($books);
    }

    public function store(StoreBookRequest $request): JsonResponse
    {
        $this->authorize('create', Book::class);

        $book = $this->bookManagement->createBook($request->user(), $request->validated());

        return BookResource::make($book)
            ->response()
            ->setStatusCode(Response::HTTP_CREATED);
    }

    public function show(Book $book): BookResource
    {
        $this->authorize('view', $book);

        $book->loadMissing(['user', 'indices']);

        return BookResource::make($book);
    }

    public function update(UpdateBookRequest $request, Book $book): BookResource
    {
        $updated = $this->bookManagement->updateBook($book, $request->validated());

        return BookResource::make($updated);
    }

    public function destroy(Book $book): JsonResponse
    {
        $this->authorize('delete', $book);

        $this->bookManagement->deleteBook($book);

        return response()->json(null, Response::HTTP_NO_CONTENT);
    }
}
