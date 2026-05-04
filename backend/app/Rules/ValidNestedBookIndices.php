<?php

namespace App\Rules;

use Closure;
use Illuminate\Contracts\Validation\ValidationRule;

final class ValidNestedBookIndices implements ValidationRule
{
    private const MAX_DEPTH = 100;

    public function validate(string $attribute, mixed $value, Closure $fail): void
    {
        if ($value === null) {
            return;
        }

        if (! is_array($value)) {
            $fail(__('validation.array', ['attribute' => $attribute]));

            return;
        }

        $this->validateNodes($value, $attribute, $fail, 0);
    }

    private function validateNodes(array $nodes, string $prefix, Closure $fail, int $depth): void
    {
        if ($depth > self::MAX_DEPTH) {
            $fail('A árvore de índices excede a profundidade máxima permitida.');

            return;
        }

        foreach ($nodes as $index => $node) {
            $path = "{$prefix}.{$index}";
            if (! is_array($node)) {
                $fail(__('validation.array', ['attribute' => $path]));

                return;
            }

            if (! isset($node['titulo']) || ! is_string($node['titulo']) || $node['titulo'] === '') {
                $fail(__('validation.required', ['attribute' => $path.'.titulo']));

                return;
            }

            if (mb_strlen($node['titulo']) > 255) {
                $fail(__('validation.max.string', ['attribute' => $path.'.titulo', 'max' => 255]));

                return;
            }

            if (! isset($node['pagina']) || ! is_numeric($node['pagina'])) {
                $fail(__('validation.integer', ['attribute' => $path.'.pagina']));

                return;
            }

            $page = (int) $node['pagina'];
            if ($page < 1) {
                $fail(__('validation.min.numeric', ['attribute' => $path.'.pagina', 'min' => 1]));

                return;
            }

            $children = $node['subindices'] ?? [];
            if ($children !== [] && ! is_array($children)) {
                $fail(__('validation.array', ['attribute' => $path.'.subindices']));

                return;
            }

            if (is_array($children) && $children !== []) {
                $this->validateNodes($children, "{$path}.subindices", $fail, $depth + 1);
            }
        }
    }
}
