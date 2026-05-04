<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('book_indices', function (Blueprint $table) {
            $table->id();
            $table->foreignId('book_id')->constrained()->cascadeOnDelete();
            $table->foreignId('parent_id')->nullable()->constrained('book_indices')->cascadeOnDelete();
            $table->string('title');
            $table->unsignedInteger('page');
            $table->timestamps();

            $table->index('book_id', 'idx_book_indices_book_id');
            $table->index('parent_id', 'idx_book_indices_parent_id');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('book_indices');
    }
};
