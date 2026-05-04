<?php

namespace App\Contracts\Auth;

use App\Data\Auth\AuthTokenResult;
use App\Models\User;

interface AuthServiceInterface
{
    public function register(string $name, string $email, string $password): AuthTokenResult;

    public function login(string $email, string $password): AuthTokenResult;

    public function logout(User $user): void;
}
