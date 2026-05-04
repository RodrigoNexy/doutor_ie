<?php

namespace App\Services\Books;

use App\Contracts\Books\BookIndexPayloadWriterInterface;
use App\Models\Book;
use App\Models\BookIndex;

final class BookIndexPayloadWriter implements BookIndexPayloadWriterInterface
{
    public function replaceTreeFromPayload(Book $book, array $indicesTree): void
    {
        BookIndex::query()
            ->where('book_id', $book->id)
            ->whereNull('parent_id')
            ->get()
            ->each(function (BookIndex $root): void {
                $root->delete();
            });

        $this->insertRecursive($book, $indicesTree, null);
    }

    private function insertRecursive(Book $book, array $nodes, ?int $parentId): void
    {
        foreach ($nodes as $node) {
            $index = BookIndex::query()->create([
                'book_id' => $book->id,
                'parent_id' => $parentId,
                'title' => $node['titulo'],
                'page' => $node['pagina'],
            ]);

            $children = $node['subindices'] ?? [];
            if ($children !== []) {
                $this->insertRecursive($book, $children, $index->id);
            }
        }
    }
}
