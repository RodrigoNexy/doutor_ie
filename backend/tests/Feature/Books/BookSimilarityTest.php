<?php

namespace Tests\Feature\Books;

use App\Models\Book;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class BookSimilarityTest extends TestCase
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

    public function test_similar_returns_books_with_close_titles(): void
    {
        $user = User::factory()->create();

        $reference = Book::factory()->create([
            'user_id' => $user->id,
            'title' => 'Clean Code',
        ]);

        $typo = Book::factory()->create([
            'user_id' => $user->id,
            'title' => 'Clene Code',
        ]);

        Book::factory()->create([
            'user_id' => $user->id,
            'title' => 'História da Arte',
        ]);

        $response = $this->getJson('/api/books/'.$reference->id.'/similar', $this->authHeaders($user));

        $response->assertOk();
        $ids = collect($response->json('data'))->pluck('id')->all();

        $this->assertContains($typo->id, $ids);
        $this->assertNotContains($reference->id, $ids);
    }

    public function test_similar_includes_pontuacao_similaridade(): void
    {
        $user = User::factory()->create();
        $reference = Book::factory()->create(['user_id' => $user->id, 'title' => 'Hello World']);
        Book::factory()->create(['user_id' => $user->id, 'title' => 'Hello Werld']);

        $response = $this->getJson('/api/books/'.$reference->id.'/similar', $this->authHeaders($user));

        $response->assertOk();
        $first = $response->json('data.0');
        $this->assertArrayHasKey('pontuacao_similaridade', $first);
        $this->assertGreaterThan(0.7, $first['pontuacao_similaridade']);
    }
}
