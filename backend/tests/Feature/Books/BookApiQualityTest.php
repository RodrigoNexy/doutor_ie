<?php

namespace Tests\Feature\Books;

use App\Models\Book;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BookApiQualityTest extends TestCase
{
    use RefreshDatabase;

    private function authHeaders(User $user): array
    {
        $token = $user->createToken('test')->plainTextToken;

        return [
            'Authorization' => 'Bearer '.$token,
            'Accept' => 'application/json',
        ];
    }

    public function test_list_books_returns_unauthenticated_without_token(): void
    {
        $this->getJson('/api/books')->assertUnauthorized();
    }

    public function test_store_returns_validation_error_when_titulo_missing(): void
    {
        $user = User::factory()->create();

        $response = $this->postJson('/api/books', [
            'numero_paginas' => 100,
        ], $this->authHeaders($user));

        $response->assertUnprocessable()
            ->assertJsonValidationErrors(['titulo']);
    }

    public function test_show_returns_not_found_for_unknown_id(): void
    {
        $user = User::factory()->create();

        $this->getJson('/api/books/99999', $this->authHeaders($user))
            ->assertNotFound();
    }

    public function test_show_requires_authentication(): void
    {
        $book = Book::factory()->create();

        $this->getJson('/api/books/'.$book->id)->assertUnauthorized();
    }

    public function test_destroy_returns_forbidden_for_non_owner(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $book = Book::factory()->create(['user_id' => $owner->id]);

        $this->deleteJson('/api/books/'.$book->id, [], $this->authHeaders($other))
            ->assertForbidden();
    }

    public function test_similar_requires_authentication(): void
    {
        $book = Book::factory()->create();

        $this->getJson('/api/books/'.$book->id.'/similar')->assertUnauthorized();
    }
}
