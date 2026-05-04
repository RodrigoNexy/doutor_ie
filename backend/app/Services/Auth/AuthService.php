<?php

namespace App\Services\Auth;

use App\Contracts\Auth\AuthServiceInterface;
use App\Data\Auth\AuthTokenResult;
use App\Models\User;
use Illuminate\Auth\AuthenticationException;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\PersonalAccessToken;

final class AuthService implements AuthServiceInterface
{
    private const TOKEN_NAME = 'api';

    public function register(string $name, string $email, string $password): AuthTokenResult
    {
        $user = User::query()->create([
            'name' => $name,
            'email' => $email,
            'password' => $password,
        ]);

        return $this->issueToken($user);
    }

    public function login(string $email, string $password): AuthTokenResult
    {
        $user = User::query()->where('email', $email)->first();

        if ($user === null || ! Hash::check($password, $user->password)) {
            throw new AuthenticationException(__('auth.failed'));
        }

        return $this->issueToken($user);
    }

    public function logout(User $user): void
    {
        $token = $user->currentAccessToken();
        if ($token instanceof PersonalAccessToken) {
            $token->delete();
        }
    }

    private function issueToken(User $user): AuthTokenResult
    {
        $plainTextToken = $user->createToken(self::TOKEN_NAME)->plainTextToken;

        return new AuthTokenResult($plainTextToken, $user);
    }
}
