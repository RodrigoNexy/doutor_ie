<?php

namespace App\Providers;

use App\Contracts\Auth\AuthServiceInterface;
use App\Services\Auth\AuthService;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(AuthServiceInterface::class, AuthService::class);
    }

    public function boot(): void
    {
        //
    }
}
