<?php

namespace Database\Seeders;

use App\Models\Book;
use App\Models\BookIndex;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Str;

class BookCatalogSeeder extends Seeder
{
    public function run(): void
    {
        $authors = [
            [
                'name' => 'Ana Martins',
                'email' => 'ana.martins@example.com',
            ],
            [
                'name' => 'Bruno Lima',
                'email' => 'bruno.lima@example.com',
            ],
            [
                'name' => 'Carla Souza',
                'email' => 'carla.souza@example.com',
            ],
            [
                'name' => 'Diego Rocha',
                'email' => 'diego.rocha@example.com',
            ],
            [
                'name' => 'Elisa Nogueira',
                'email' => 'elisa.nogueira@example.com',
            ],
            [
                'name' => 'Felipe Ramos',
                'email' => 'felipe.ramos@example.com',
            ],
            [
                'name' => 'Gabriela Reis',
                'email' => 'gabriela.reis@example.com',
            ],
            [
                'name' => 'Henrique Prado',
                'email' => 'henrique.prado@example.com',
            ],
            [
                'name' => 'Isabela Duarte',
                'email' => 'isabela.duarte@example.com',
            ],
            [
                'name' => 'Joao Tavares',
                'email' => 'joao.tavares@example.com',
            ],
        ];

        $books = [
            [
                'title' => 'Guia de Flutter Prático',
                'num_pages' => 320,
                'author_email' => 'ana.martins@example.com',
                'indices' => [
                    [
                        'title' => 'Fundamentos',
                        'page' => 1,
                        'children' => [
                            ['title' => 'Widgets básicos', 'page' => 8],
                            ['title' => 'Layouts responsivos', 'page' => 26],
                        ],
                    ],
                    [
                        'title' => 'Estado e arquitetura',
                        'page' => 70,
                        'children' => [
                            ['title' => 'Riverpod', 'page' => 78],
                            ['title' => 'Testes', 'page' => 114],
                        ],
                    ],
                ],
            ],
            [
                'title' => 'Design de Interfaces no Flutter',
                'num_pages' => 298,
                'author_email' => 'ana.martins@example.com',
                'indices' => [
                    [
                        'title' => 'Princípios visuais',
                        'page' => 12,
                    ],
                    [
                        'title' => 'Componentes reutilizáveis',
                        'page' => 64,
                    ],
                    [
                        'title' => 'Acessibilidade',
                        'page' => 141,
                    ],
                ],
            ],
            [
                'title' => 'Laravel para APIs Modernas',
                'num_pages' => 280,
                'author_email' => 'bruno.lima@example.com',
                'indices' => [
                    [
                        'title' => 'Autenticação com Sanctum',
                        'page' => 10,
                    ],
                    [
                        'title' => 'Resources e validação',
                        'page' => 55,
                    ],
                    [
                        'title' => 'Boas práticas em testes',
                        'page' => 120,
                    ],
                ],
            ],
            [
                'title' => 'Eloquent sem Mistérios',
                'num_pages' => 315,
                'author_email' => 'bruno.lima@example.com',
                'indices' => [
                    [
                        'title' => 'Modelos e relações',
                        'page' => 9,
                    ],
                    [
                        'title' => 'Query builder avançado',
                        'page' => 103,
                    ],
                    [
                        'title' => 'Performance e índices',
                        'page' => 211,
                    ],
                ],
            ],
            [
                'title' => 'Arquitetura Limpa no Dia a Dia',
                'num_pages' => 240,
                'author_email' => 'carla.souza@example.com',
                'indices' => [
                    [
                        'title' => 'SOLID aplicado',
                        'page' => 14,
                        'children' => [
                            ['title' => 'SRP', 'page' => 18],
                            ['title' => 'DIP', 'page' => 42],
                        ],
                    ],
                    [
                        'title' => 'Anti-duplicação de código',
                        'page' => 88,
                    ],
                ],
            ],
            [
                'title' => 'Refatoração sem Medo',
                'num_pages' => 226,
                'author_email' => 'carla.souza@example.com',
                'indices' => [
                    [
                        'title' => 'Code smells comuns',
                        'page' => 15,
                    ],
                    [
                        'title' => 'Estratégias de refatoração',
                        'page' => 77,
                    ],
                    [
                        'title' => 'Protegendo com testes',
                        'page' => 163,
                    ],
                ],
            ],
            [
                'title' => 'Testes de API com Laravel',
                'num_pages' => 264,
                'author_email' => 'diego.rocha@example.com',
                'indices' => [
                    [
                        'title' => 'Testes de autenticação',
                        'page' => 18,
                    ],
                    [
                        'title' => 'Factories e seeders',
                        'page' => 93,
                    ],
                    [
                        'title' => 'Qualidade e regressão',
                        'page' => 174,
                    ],
                ],
            ],
            [
                'title' => 'Documentando APIs REST',
                'num_pages' => 198,
                'author_email' => 'diego.rocha@example.com',
                'indices' => [
                    [
                        'title' => 'OpenAPI na prática',
                        'page' => 22,
                    ],
                    [
                        'title' => 'Padronização de respostas',
                        'page' => 88,
                    ],
                    [
                        'title' => 'Fluxo de versionamento',
                        'page' => 146,
                    ],
                ],
            ],
            [
                'title' => 'UX para Produtos Digitais',
                'num_pages' => 232,
                'author_email' => 'elisa.nogueira@example.com',
                'indices' => [
                    [
                        'title' => 'Pesquisa com usuários',
                        'page' => 14,
                    ],
                    [
                        'title' => 'Jornada e fluxo',
                        'page' => 67,
                    ],
                    [
                        'title' => 'Métricas de experiência',
                        'page' => 156,
                    ],
                ],
            ],
            [
                'title' => 'Microinterações que Encantam',
                'num_pages' => 186,
                'author_email' => 'elisa.nogueira@example.com',
                'indices' => [
                    [
                        'title' => 'Animações funcionais',
                        'page' => 19,
                    ],
                    [
                        'title' => 'Feedback visual',
                        'page' => 74,
                    ],
                    [
                        'title' => 'Consistência de estados',
                        'page' => 129,
                    ],
                ],
            ],
            [
                'title' => 'DevOps para Times Pequenos',
                'num_pages' => 252,
                'author_email' => 'felipe.ramos@example.com',
                'indices' => [
                    [
                        'title' => 'Pipeline de deploy',
                        'page' => 11,
                    ],
                    [
                        'title' => 'Observabilidade básica',
                        'page' => 102,
                    ],
                    [
                        'title' => 'Custos em nuvem',
                        'page' => 189,
                    ],
                ],
            ],
            [
                'title' => 'Git Avançado para Equipes',
                'num_pages' => 205,
                'author_email' => 'felipe.ramos@example.com',
                'indices' => [
                    [
                        'title' => 'Estratégias de branching',
                        'page' => 10,
                    ],
                    [
                        'title' => 'Code review efetivo',
                        'page' => 69,
                    ],
                    [
                        'title' => 'Resolução de conflitos',
                        'page' => 137,
                    ],
                ],
            ],
            [
                'title' => 'Liderança Técnica Pragmática',
                'num_pages' => 244,
                'author_email' => 'gabriela.reis@example.com',
                'indices' => [
                    [
                        'title' => 'Carreira e influência',
                        'page' => 16,
                    ],
                    [
                        'title' => 'Rituais de engenharia',
                        'page' => 84,
                    ],
                    [
                        'title' => 'Decisões arquiteturais',
                        'page' => 168,
                    ],
                ],
            ],
            [
                'title' => 'Comunicação para Engenharia',
                'num_pages' => 172,
                'author_email' => 'gabriela.reis@example.com',
                'indices' => [
                    [
                        'title' => 'Escrita técnica',
                        'page' => 12,
                    ],
                    [
                        'title' => 'Alinhamento entre áreas',
                        'page' => 71,
                    ],
                    [
                        'title' => 'Negociação de escopo',
                        'page' => 121,
                    ],
                ],
            ],
            [
                'title' => 'Performance Web Essencial',
                'num_pages' => 219,
                'author_email' => 'henrique.prado@example.com',
                'indices' => [
                    [
                        'title' => 'Core Web Vitals',
                        'page' => 17,
                    ],
                    [
                        'title' => 'Carga de assets',
                        'page' => 78,
                    ],
                    [
                        'title' => 'Caching eficiente',
                        'page' => 148,
                    ],
                ],
            ],
            [
                'title' => 'Segurança Aplicada em APIs',
                'num_pages' => 274,
                'author_email' => 'henrique.prado@example.com',
                'indices' => [
                    [
                        'title' => 'Autenticação e autorização',
                        'page' => 24,
                    ],
                    [
                        'title' => 'Validação de entrada',
                        'page' => 112,
                    ],
                    [
                        'title' => 'Monitoramento de risco',
                        'page' => 203,
                    ],
                ],
            ],
            [
                'title' => 'Produto Orientado a Dados',
                'num_pages' => 233,
                'author_email' => 'isabela.duarte@example.com',
                'indices' => [
                    [
                        'title' => 'Métricas de produto',
                        'page' => 20,
                    ],
                    [
                        'title' => 'Experimentos A/B',
                        'page' => 88,
                    ],
                    [
                        'title' => 'Priorização orientada',
                        'page' => 164,
                    ],
                ],
            ],
            [
                'title' => 'Pesquisa de Mercado para SaaS',
                'num_pages' => 191,
                'author_email' => 'isabela.duarte@example.com',
                'indices' => [
                    [
                        'title' => 'ICP e segmentação',
                        'page' => 13,
                    ],
                    [
                        'title' => 'Entrevistas com clientes',
                        'page' => 69,
                    ],
                    [
                        'title' => 'Posicionamento',
                        'page' => 127,
                    ],
                ],
            ],
            [
                'title' => 'Dart para Profissionais',
                'num_pages' => 321,
                'author_email' => 'joao.tavares@example.com',
                'indices' => [
                    [
                        'title' => 'Fundamentos da linguagem',
                        'page' => 7,
                    ],
                    [
                        'title' => 'Null safety e generics',
                        'page' => 96,
                    ],
                    [
                        'title' => 'Assíncrono avançado',
                        'page' => 211,
                    ],
                ],
            ],
            [
                'title' => 'Estruturas de Dados para Apps',
                'num_pages' => 260,
                'author_email' => 'joao.tavares@example.com',
                'indices' => [
                    [
                        'title' => 'Listas e mapas',
                        'page' => 14,
                    ],
                    [
                        'title' => 'Árvores em interfaces',
                        'page' => 101,
                    ],
                    [
                        'title' => 'Complexidade e escolhas',
                        'page' => 182,
                    ],
                ],
            ],
        ];

        foreach ($authors as $authorData) {
            User::query()->firstOrCreate(
                ['email' => $authorData['email']],
                [
                    'name' => $authorData['name'],
                    'password' => bcrypt('password'),
                ],
            );
        }

        Book::unguarded(function () use ($books): void {
            foreach ($books as $bookData) {
                $author = User::query()->where('email', $bookData['author_email'])->first();
                if ($author === null) {
                    continue;
                }

                $book = Book::query()->firstOrCreate(
                    [
                        'user_id' => $author->id,
                        'title' => $bookData['title'],
                    ],
                    [
                        'title_normalized' => Str::lower($bookData['title']),
                        'num_pages' => $bookData['num_pages'],
                    ],
                );

                $book->indices()->delete();
                $this->seedIndices($book->id, $bookData['indices']);
            }
        });
    }


    private function seedIndices(int $bookId, array $indices, ?int $parentId = null): void
    {
        foreach ($indices as $index) {
            $node = BookIndex::query()->create([
                'book_id' => $bookId,
                'parent_id' => $parentId,
                'title' => (string) $index['title'],
                'page' => (int) $index['page'],
            ]);

            $children = $index['children'] ?? [];
            if (is_array($children) && count($children) > 0) {
                $this->seedIndices($bookId, $children, $node->id);
            }
        }
    }
}
