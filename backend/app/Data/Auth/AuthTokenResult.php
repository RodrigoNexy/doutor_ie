<?php

namespace App\Data\Auth;

use App\Models\User;

readonly class AuthTokenResult
{
    public function __construct(
        public string $plainTextToken,
        public User $user,
    ) {}
}
