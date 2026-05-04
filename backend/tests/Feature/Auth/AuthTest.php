<?php

namespace Tests\Feature\Auth;

use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class AuthTest extends TestCase
{
    use RefreshDatabase;

    public function test_register_returns_bearer_token_and_user(): void
    {
        $response = $this->postJson('/api/register', [
            'name' => 'Maria',
            'email' => 'maria@example.com',
            'password' => 'Password123!',
            'password_confirmation' => 'Password123!',
        ]);

        $response->assertCreated()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonStructure([
                'token',
                'token_type',
                'user' => ['id', 'nome', 'email'],
            ]);

        $this->assertDatabaseHas('users', ['email' => 'maria@example.com']);
    }

    public function test_login_returns_token_when_credentials_are_valid(): void
    {
        $user = User::factory()->create([
            'email' => 'joao@example.com',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'joao@example.com',
            'password' => 'password',
        ]);

        $response->assertOk()
            ->assertJsonPath('token_type', 'Bearer')
            ->assertJsonStructure(['token', 'user' => ['id', 'nome', 'email']]);
    }

    public function test_login_returns_unauthorized_when_password_is_wrong(): void
    {
        User::factory()->create([
            'email' => 'joao@example.com',
        ]);

        $response = $this->postJson('/api/login', [
            'email' => 'joao@example.com',
            'password' => 'wrong-password',
        ]);

        $response->assertUnauthorized();
    }

    public function test_logout_deletes_current_access_token(): void
    {
        $user = User::factory()->create();
        $plainTextToken = $user->createToken('api')->plainTextToken;

        $this->assertSame(1, $user->tokens()->count());

        $this->withHeader('Authorization', 'Bearer '.$plainTextToken)
            ->postJson('/api/logout')
            ->assertNoContent();

        $this->assertSame(0, $user->fresh()->tokens()->count());
    }
}
