<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class BookIndex extends Model
{
    protected $fillable = [
        'book_id',
        'parent_id',
        'title',
        'page',
    ];

    public function book(): BelongsTo
    {
        return $this->belongsTo(Book::class);
    }

    public function parent(): BelongsTo
    {
        return $this->belongsTo(BookIndex::class, 'parent_id');
    }

    public function children(): HasMany
    {
        return $this->hasMany(BookIndex::class, 'parent_id');
    }
}
