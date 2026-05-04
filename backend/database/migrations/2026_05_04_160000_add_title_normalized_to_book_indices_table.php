<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Str;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('book_indices', function (Blueprint $table): void {
            $table->string('title_normalized')->default('')->after('title');
            $table->index('title_normalized', 'idx_book_indices_title_normalized');
        });

        DB::table('book_indices')->orderBy('id')->chunkById(100, function ($rows): void {
            foreach ($rows as $row) {
                DB::table('book_indices')->where('id', $row->id)->update([
                    'title_normalized' => self::normalizeTitle((string) $row->title),
                ]);
            }
        });
    }

    public function down(): void
    {
        Schema::table('book_indices', function (Blueprint $table): void {
            $table->dropIndex('idx_book_indices_title_normalized');
            $table->dropColumn('title_normalized');
        });
    }

    private static function normalizeTitle(string $title): string
    {
        return Str::lower(Str::ascii(trim($title)));
    }
};
