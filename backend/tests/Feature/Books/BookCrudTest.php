<?php

namespace Tests\Feature\Books;

use App\Models\Book;
use App\Models\BookIndex;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BookCrudTest extends TestCase
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

    public function test_store_creates_book_with_nested_indices(): void
    {
        $user = User::factory()->create();

        $response = $this->postJson('/api/books', [
            'titulo' => 'Clean Code',
            'numero_paginas' => 450,
            'indices' => [
                [
                    'titulo' => 'Capítulo 1',
                    'pagina' => 1,
                    'subindices' => [
                        [
                            'titulo' => 'Introdução',
                            'pagina' => 2,
                            'subindices' => [],
                        ],
                    ],
                ],
            ],
        ], $this->authHeaders($user));

        $response->assertCreated()
            ->assertJsonPath('data.titulo', 'Clean Code')
            ->assertJsonPath('data.numero_paginas', 450)
            ->assertJsonPath('data.usuario_publicador.nome', $user->name);

        $this->assertDatabaseHas('books', ['title' => 'Clean Code', 'user_id' => $user->id]);
        $this->assertSame(2, BookIndex::query()->count());
    }

    public function test_index_filters_by_titulo(): void
    {
        $user = User::factory()->create();
        Book::factory()->create(['user_id' => $user->id, 'title' => 'Alpha Guide']);
        Book::factory()->create(['user_id' => $user->id, 'title' => 'Beta Handbook']);

        $response = $this->getJson('/api/books?titulo=alpha', $this->authHeaders($user));

        $response->assertOk();
        $this->assertCount(1, $response->json('data'));
        $this->assertSame('Alpha Guide', $response->json('data.0.titulo'));
    }

    public function test_index_filters_by_titulo_do_indice_prunes_tree(): void
    {
        $user = User::factory()->create();
        $book = Book::factory()->create(['user_id' => $user->id, 'title' => 'Livro']);

        $root = BookIndex::query()->create([
            'book_id' => $book->id,
            'parent_id' => null,
            'title' => 'Parte A',
            'page' => 1,
        ]);

        BookIndex::query()->create([
            'book_id' => $book->id,
            'parent_id' => $root->id,
            'title' => 'Secção X',
            'page' => 5,
        ]);

        BookIndex::query()->create([
            'book_id' => $book->id,
            'parent_id' => $root->id,
            'title' => 'Outra',
            'page' => 10,
        ]);

        $response = $this->getJson('/api/books?titulo_do_indice=secção', $this->authHeaders($user));

        $response->assertOk();
        $indices = $response->json('data.0.indices');
        $this->assertCount(1, $indices);
        $this->assertSame('Parte A', $indices[0]['titulo']);
        $this->assertCount(1, $indices[0]['subindices']);
        $this->assertSame('Secção X', $indices[0]['subindices'][0]['titulo']);
    }

    public function test_update_replaces_indices(): void
    {
        $user = User::factory()->create();
        $book = Book::factory()->create(['user_id' => $user->id, 'title' => 'Old', 'num_pages' => 10]);

        BookIndex::query()->create([
            'book_id' => $book->id,
            'parent_id' => null,
            'title' => 'Cap velho',
            'page' => 1,
        ]);

        $response = $this->putJson('/api/books/'.$book->id, [
            'titulo' => 'New Title',
            'numero_paginas' => 200,
            'indices' => [
                ['titulo' => 'Novo cap', 'pagina' => 3, 'subindices' => []],
            ],
        ], $this->authHeaders($user));

        $response->assertOk()
            ->assertJsonPath('data.titulo', 'New Title')
            ->assertJsonPath('data.numero_paginas', 200);

        $this->assertDatabaseHas('books', ['id' => $book->id, 'title' => 'New Title']);
        $this->assertSame(1, BookIndex::query()->where('book_id', $book->id)->count());
    }

    public function test_destroy_deletes_book_and_indices(): void
    {
        $user = User::factory()->create();
        $book = Book::factory()->create(['user_id' => $user->id]);
        BookIndex::query()->create([
            'book_id' => $book->id,
            'parent_id' => null,
            'title' => 'Cap',
            'page' => 1,
        ]);

        $this->deleteJson('/api/books/'.$book->id, [], $this->authHeaders($user))
            ->assertNoContent();

        $this->assertDatabaseMissing('books', ['id' => $book->id]);
        $this->assertDatabaseMissing('book_indices', ['book_id' => $book->id]);
    }

    public function test_update_returns_forbidden_for_non_owner(): void
    {
        $owner = User::factory()->create();
        $other = User::factory()->create();
        $book = Book::factory()->create(['user_id' => $owner->id]);

        $this->putJson('/api/books/'.$book->id, [
            'titulo' => 'Hack',
            'numero_paginas' => 1,
            'indices' => [],
        ], $this->authHeaders($other))
            ->assertForbidden();
    }
}
