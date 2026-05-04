<?php

namespace App\Providers;

use App\Contracts\Auth\AuthServiceInterface;
use App\Contracts\Books\BookIndexNestedSerializerInterface;
use App\Contracts\Books\BookIndexPayloadWriterInterface;
use App\Contracts\Books\BookManagementServiceInterface;
use App\Contracts\Books\TitleNormalizerInterface;
use App\Models\Book;
use App\Models\BookIndex;
use App\Observers\BookIndexObserver;
use App\Observers\BookObserver;
use App\Policies\BookPolicy;
use App\Services\Auth\AuthService;
use App\Services\Books\AsciiTitleNormalizer;
use App\Services\Books\BookIndexNestedSerializer;
use App\Services\Books\BookIndexPayloadWriter;
use App\Services\Books\BookManagementService;
use Illuminate\Support\Facades\Gate;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    public function register(): void
    {
        $this->app->singleton(AuthServiceInterface::class, AuthService::class);
        $this->app->singleton(TitleNormalizerInterface::class, AsciiTitleNormalizer::class);
        $this->app->singleton(BookIndexPayloadWriterInterface::class, BookIndexPayloadWriter::class);
        $this->app->singleton(BookIndexNestedSerializerInterface::class, BookIndexNestedSerializer::class);
        $this->app->singleton(BookManagementServiceInterface::class, BookManagementService::class);
    }

    public function boot(): void
    {
        Book::observe(BookObserver::class);
        BookIndex::observe(BookIndexObserver::class);

        Gate::policy(Book::class, BookPolicy::class);
    }
}
