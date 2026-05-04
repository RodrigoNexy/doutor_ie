<?php

namespace App\Models;

use Database\Factories\BookFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Book extends Model
{
    use HasFactory;
    protected $fillable = [
        'user_id',
        'title',
        'num_pages',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function indices(): HasMany
    {
        return $this->hasMany(BookIndex::class);
    }
}
