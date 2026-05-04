<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{

    public function up(): void
    {
        Schema::create('books', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('title_normalized');
            $table->unsignedInteger('num_pages');
            $table->timestamps();

            $table->index('title_normalized', 'idx_books_title_normalized');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('books');
    }
};
