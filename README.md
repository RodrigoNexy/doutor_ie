# Doutor IE — Gestão de livros (Laravel + Flutter)

Projeto full stack para o teste técnico: API REST em **Laravel 12**, app em **Flutter**, base de dados **MySQL** ou **SQLite** (desenvolvimento).

## Estrutura do repositório

| Pasta | Descrição |
|-------|-----------|
| `backend/` | API Laravel (`php artisan serve`) |
| `mobile/` | Aplicação Flutter |
| `teste.md` | Enunciado e checklist de tarefas |

## Requisitos

- **PHP** ≥ 8.2, **Composer**
- **Node** (opcional, para assets Vite do Laravel)
- **Flutter** SDK (stable), **Dart**
- **MySQL** (ex.: XAMPP) *ou* SQLite para desenvolvimento rápido
- **Android SDK / emulador** (para correr o app em Android)

---

## Backend (Laravel)

### Configuração

```bash
cd backend
composer install
copy .env.example .env   # Windows: já podes ter .env criado
php artisan key:generate
```

Ajusta `backend/.env`:

- **SQLite (rápido):** `DB_CONNECTION=sqlite` e comenta `DB_HOST`… ou define `DB_DATABASE` para o caminho do ficheiro `.sqlite`.
- **MySQL (XAMPP):** cria a base (ex. `doutor_ie`), define `DB_CONNECTION=mysql`, `DB_DATABASE`, `DB_USERNAME`, `DB_PASSWORD`, sobe o serviço MySQL.

### Migrações

```bash
php artisan migrate
```

Inclui utilizadores Laravel, tabelas padrão (cache, jobs, sessões), **Sanctum** (`personal_access_tokens`), **livros** e **índices** (quando as migrações estiverem aplicadas).

### Seed (obrigatório antes de subir o servidor)

Para já iniciar com autores e livros padrão no SQLite/MySQL de desenvolvimento, rode:

```bash
php artisan db:seed
```

Se quiser recriar tudo do zero e já popular:

```bash
php artisan migrate:fresh --seed
```

Seeder atual de demonstração:

- cerca de **10 autores**
- cerca de **20 livros**

### Servidor de desenvolvimento

Depois de migrar e popular com seed:

```bash
php artisan serve
```

Por defeito: `http://127.0.0.1:8000`. As rotas HTTP da API estão sob o prefixo **`/api`**.

### Testes automatizados

```bash
php artisan test
# só auth:
php artisan test --filter=AuthTest
```

---

## API — Autenticação (Sanctum)

Todas as rotas abaixo respondem em JSON. Rotas **protegidas** exigem cabeçalho:

```http
Authorization: Bearer {token}
Accept: application/json
```

### `POST /api/register`

Cria utilizador e devolve token de acesso pessoal (Sanctum).

**Corpo (JSON):**

| Campo | Regras |
|-------|--------|
| `name` | obrigatório, string, máx. 255 |
| `email` | obrigatório, email único |
| `password` | obrigatório, confirmado (`password_confirmation`), regras de `Password::defaults()` |

**Resposta `201 Created`:**

```json
{
  "token": "1|xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "nome": "Maria",
    "email": "maria@example.com"
  }
}
```

### `POST /api/login`

**Corpo (JSON):**

| Campo | Regras |
|-------|--------|
| `email` | obrigatório, email |
| `password` | obrigatório |

**Resposta `200 OK`:** mesmo formato que o registo (`token`, `token_type`, `user`).

**Resposta `401 Unauthorized`:** credenciais inválidas (`message` alinhada a `auth.failed`).

### `POST /api/logout`

- **Middleware:** `auth:sanctum`
- Revoga apenas o **token atual** (o enviado no header).

**Resposta `204 No Content`** (sem corpo).

### `GET /api/me`

- **Middleware:** `auth:sanctum`
- Devolve o utilizador autenticado no mesmo formato de `UserResource`.

**Resposta `200 OK`:**

```json
{
  "data": {
    "id": 1,
    "nome": "Maria",
    "email": "maria@example.com"
  }
}
```

### Arquitetura da auth (decisão técnica)

- **Controller fino** (`AuthController`): só orquestra HTTP.
- **Regras de negócio** em `AuthService`, exposto via **`AuthServiceInterface`** (inversão de dependência, testável).
- **Validação** em `RegisterUserRequest` e `LoginUserRequest`.
- **Formato do utilizador** na API com `UserResource` (campo `nome` mapeado de `users.name`, alinhado ao enunciado).

---

## API — Livros (CRUD)

Todas as rotas exigem **`auth:sanctum`** (mesmo header `Authorization` / `Accept`).

As respostas usam o envelope padrão do Laravel **`Resource`**: objeto único em `data`, listas em `data` como array.

### `GET /api/books`

| Query | Descrição |
|-------|-----------|
| `titulo` | Filtra livros cujo título normalizado contém o termo (sem acento, minúsculas). |
| `titulo_do_indice` | Filtra livros que tenham algum índice cujo título normalizado contém o termo. Na resposta, o campo `indices` de cada livro vem **apenas com o caminho da raiz até ao índice correspondente** (ascendentes + ramo). |

### `POST /api/books`

Cria livro para o utilizador autenticado (publicador).

**Corpo (JSON):**

| Campo | Descrição |
|-------|-----------|
| `titulo` | string, obrigatório |
| `numero_paginas` | inteiro ≥ 1 |
| `indices` | array opcional; cada nó: `titulo`, `pagina`, `subindices` (array, pode ser vazio). Profundidade máxima 100. |

**Resposta `201 Created`:** `data` com `id`, `titulo`, `numero_paginas`, `usuario_publicador`, `indices`.

### `GET /api/books/{id}`

Detalhe do livro com índices em árvore completa.

### `GET /api/books/{id}/similar`

Lista **outros livros** com título semanticamente parecido ao livro `{id}` (comparação sobre `title_normalized`: sem acento, minúsculas).

- **Autorização:** mesma regra que ver detalhe (`BookPolicy::similar`).
- **Resposta `200 OK`:** `data` como array; cada item inclui os campos habituais do livro (como em `BookResource`) mais **`pontuacao_similaridade`** (0 a 1, maior = mais parecido).
- **Algoritmo:** distância de **Levenshtein** em PHP sobre títulos já normalizados. Para escalar com muitos registos, aplica-se primeiro um **pré-filtro SQL** (igualdade exacta do normalizado, prefixo dos primeiros caracteres, ou comprimento semelhante) com limite de candidatos, e só depois o score.

O campo **`title_normalized`** do livro é preenchido automaticamente nos observers ao criar/editar (já descrito na secção de arquitetura).

### `PUT /api/books/{id}`

Atualiza título e páginas e **substitui toda a árvore de índices** pelo payload (remove nós antigos que não existam no novo JSON e recria a estrutura).

**Resposta `200 OK`:** `data` com o livro atualizado.

**`403 Forbidden`:** livro de outro utilizador.

> No app Flutter, os botões de **editar/excluir** são exibidos apenas para livros do utilizador autenticado.

### `DELETE /api/books/{id}`

Remove o livro; índices são removidos em cascata pela BD.

**Resposta `204 No Content`.**

### Arquitetura dos livros (decisão técnica)

- **`BookManagementServiceInterface` / `BookManagementService`**: casos de uso (criar, listar, atualizar, apagar).
- **`BookIndexPayloadWriterInterface`**: escrita recursiva da árvore a partir do JSON da API.
- **`BookIndexNestedSerializerInterface`**: leitura em árvore + poda quando há `titulo_do_indice`.
- **`TitleNormalizerInterface`**: normalização única (título de livro e de índice).
- **`BookObserver` / `BookIndexObserver`**: preenchem `title_normalized` ao guardar.
- **`BookTitleSimilarityScorerInterface`** + **`LevenshteinBookTitleSimilarityScorer`**: cálculo de similaridade (substituível, p.ex. trigram no futuro).
- **`SimilarBooksFinderInterface`** + **`SimilarBooksFinder`**: escolhe candidatos na BD e aplica o scorer.
- **`BookSimilarityController`**: única ação HTTP para `GET .../similar`.
- **`BookPolicy`**: qualquer utilizador autenticado pode **ver** e **listar**; só o dono **atualiza** ou **apaga**; **similar** alinhado a **view**.
- **Validação** aninhada: regra `ValidNestedBookIndices` + Form Requests em `App\Http\Requests\Book`.
- **Coluna `book_indices.title_normalized`**: migração `2026_05_04_160000_add_title_normalized_to_book_indices_table` para filtros eficientes.

---

## Frontend (Flutter)

### Configuração

```bash
cd mobile
flutter pub get
```

URL base da API: `mobile/lib/config/api_config.dart`.

- **Emulador Android:** `http://10.0.2.2:8000/api` (mapeia para o `localhost` do PC onde corre o Laravel).
- **Web / Windows:** `http://127.0.0.1:8000/api`.
- **Override:** `flutter run --dart-define=API_BASE_URL=https://exemplo.com/api`

### Navegação

O app possui menu inferior com quatro abas principais:

- **Home**
- **Livros**
- **Autores**
- **Perfil**

A aba **Perfil** mostra o utilizador (mock avatar + nome) e a lista de livros publicados por ele, com ações de editar/excluir.

### Sessão e autenticação no app

- Token de autenticação persistido localmente (`shared_preferences`).
- Sessão restaurada ao abrir o app.
- Em token inválido/expirado (`Unauthenticated`), o app faz logout automático e redireciona para login.
- O `userId` da sessão é usado para controlar permissões de UI (ex.: mostrar botão de editar/excluir apenas para o dono do livro).

### Correr a app

Com o emulador **já aberto** ou outro dispositivo listado em `flutter devices`:

```bash
cd mobile
flutter run
```

Alternativa sem emulador Android:

```bash
flutter run -d chrome
```

---

## Decisões técnicas (resumo)

| Tópico | Escolha |
|--------|---------|
| Auth API | **Laravel Sanctum** (tokens tipo Bearer) |
| Rotas API | Ficheiro `routes/api.php`, prefixo `/api` |
| Princípios | SRP: controllers finos; serviços por domínio (auth, livros); contratos + implementações (DIP) |
| BD | Migrações Laravel; MySQL em produção/dev real; SQLite aceite para testes CI |
| Flutter | `ApiConfig` por plataforma; sessão com token + `userId` persistidos no app; navegação por abas (Home/Livros/Autores/Perfil) |

---