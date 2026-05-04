<div align="center">

# 📚 Doutor IE — Gestão de Livros

**API REST em Laravel 12 + App Flutter**

[![PHP](https://img.shields.io/badge/PHP-≥8.2-777BB4?logo=php&logoColor=white)](https://php.net)
[![Laravel](https://img.shields.io/badge/Laravel-12-FF2D20?logo=laravel&logoColor=white)](https://laravel.com)
[![Flutter](https://img.shields.io/badge/Flutter-stable-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![MySQL](https://img.shields.io/badge/MySQL-compatible-4479A1?logo=mysql&logoColor=white)](https://mysql.com)
[![SQLite](https://img.shields.io/badge/SQLite-dev-003B57?logo=sqlite&logoColor=white)](https://sqlite.org)

Projeto full stack desenvolvido para teste técnico. Backend com API REST autenticada via Sanctum, app Flutter com navegação por abas e gestão completa de livros com índices hierárquicos.

</div>

---

## 🖼️ Capturas de Ecrã


### Fluxo de autenticação

<img width="387" height="828" alt="image" src="https://github.com/user-attachments/assets/dea782ab-f842-4b56-9ebb-258a709519cc" />


<img width="387" height="830" alt="image" src="https://github.com/user-attachments/assets/ee8e40bd-4f18-4abb-afb8-df1af66f116b" />


### Navegação principal

<img width="377" height="827" alt="image" src="https://github.com/user-attachments/assets/e30813f1-9f03-46d0-8194-0d2f5d6dea24" />


<img width="379" height="117" alt="image" src="https://github.com/user-attachments/assets/810ad3dc-783b-4e70-bad4-7121799a1d50" />


### Livros

<img width="386" height="827" alt="image" src="https://github.com/user-attachments/assets/2a59cdd4-c1b6-483c-94ac-89958ba180e5" />

<img width="386" height="827" alt="image" src="https://github.com/user-attachments/assets/bf592371-468e-424d-bb5f-b54b08db0e23" />

<img width="381" height="829" alt="image" src="https://github.com/user-attachments/assets/eeb8415c-5f94-469b-bfe0-00a8fde6c4b4" />

### Autores e perfil

<img width="383" height="826" alt="image" src="https://github.com/user-attachments/assets/207bb76d-688e-45ab-a357-1ccacb50441d" />

<img width="383" height="823" alt="image" src="https://github.com/user-attachments/assets/28b597e6-dca1-4cf3-a5a8-12c21877324a" />


---

## 📁 Estrutura do Repositório

```
.
├── backend/     # API Laravel (php artisan serve)
├── mobile/      # Aplicação Flutter
├── docs/        # Prints e documentação auxiliar
└── teste.md     # Enunciado e checklist de tarefas
```

---

## ⚙️ Requisitos

| Tecnologia | Versão |
|-----------|--------|
| PHP | ≥ 8.2 |
| Composer | latest |
| Flutter SDK | stable |
| Dart | incluído no Flutter |
| MySQL | ex.: XAMPP (ou SQLite para dev) |
| Android SDK | para emulador Android |

> Node.js é opcional (apenas para assets Vite do Laravel).

---

## 🚀 Backend (Laravel)

### 1. Instalação

```bash
cd backend
composer install
copy .env.example .env
php artisan key:generate
```

### 2. Configuração da Base de Dados

Edita `backend/.env` conforme o teu ambiente:

<details>
<summary><strong>SQLite (desenvolvimento rápido)</strong></summary>

```env
DB_CONNECTION=sqlite
# Comenta ou remove as variáveis DB_HOST, DB_DATABASE, etc.
```

</details>

<details>
<summary><strong>MySQL (XAMPP / produção)</strong></summary>

```env
DB_CONNECTION=mysql
DB_DATABASE=doutor_ie
DB_USERNAME=root
DB_PASSWORD=
```

Cria a base de dados `doutor_ie` no teu servidor MySQL antes de migrar.

</details>

### 3. Migrações

```bash
php artisan migrate
```

Inclui tabelas de utilizadores, cache, jobs, sessões, Sanctum (`personal_access_tokens`), **livros** e **índices**.

### 4. Seed

Popula a base com dados de demonstração (~10 autores, ~20 livros):

```bash
php artisan db:seed
```

Para recriar tudo do zero e popular:

```bash
php artisan migrate:fresh --seed
```

### 5. Iniciar o Servidor

```bash
php artisan serve
# → http://127.0.0.1:8000
```

Todas as rotas da API estão sob o prefixo `/api`.

### 6. Testes Automatizados

```bash
# Todos os testes
php artisan test

# Apenas autenticação
php artisan test --filter=AuthTest
```

---

## 🧱 Arquitetura da API (Laravel)

Esta API foi estruturada para manter regras de negócio fora dos controllers, com baixo acoplamento e foco em testabilidade.

### Organização de pastas (backend)

```text
backend/app
├── Contracts/
│   ├── Auth/
│   └── Books/
├── Http/
│   ├── Controllers/Api/
│   ├── Requests/Auth/
│   ├── Requests/Book/
│   └── Resources/
├── Models/
├── Observers/
├── Policies/
└── Services/
    ├── Auth/
    └── Books/
```

### Responsabilidade de cada camada

- `Http/Controllers/Api`: camada HTTP fina, apenas recebe pedido, delega e devolve resposta.
- `Http/Requests`: validação e autorização por endpoint (entrada consistente e previsível).
- `Http/Resources`: formato de saída da API (padroniza contrato JSON).
- `Services/*`: casos de uso e regras de negócio (criar, listar, atualizar, similaridade, auth).
- `Contracts/*`: abstrações para DIP (facilita testes e troca de implementação).
- `Policies`: regras de autorização por recurso (ex.: só o dono edita/apaga livro).
- `Observers`: automações de domínio (normalização de título ao persistir).
- `Models`: persistência e relacionamentos Eloquent.

### Fluxo de uma operação (ex.: atualizar livro)

1. Request chega em `BookController@update`.
2. `UpdateBookRequest` valida payload e autorização.
3. Controller chama `BookManagementServiceInterface`.
4. Service aplica regra de negócio e coordena escrita da árvore de índices.
5. `BookResource` serializa a resposta no padrão da API.

### Benefícios práticos dessa arquitetura

- regras críticas centralizadas em serviços (evita duplicação);
- facilidade para testes unitários e de integração;
- controllers pequenos e de fácil manutenção;
- autorização consistente via policy/request;
- evolutividade para trocar algoritmos (ex.: similaridade) sem quebrar endpoints.

---

## 🔐 API — Autenticação (Sanctum)

Todas as rotas respondem em JSON. As rotas **protegidas** exigem:

```http
Authorization: Bearer {token}
Accept: application/json
```

### `POST /api/register`

Cria utilizador e devolve token de acesso pessoal.

**Corpo:**
```json
{
  "name": "Maria",
  "email": "maria@example.com",
  "password": "secret123",
  "password_confirmation": "secret123"
}
```

**Resposta `201 Created`:**
```json
{
  "token": "1|xxxxxxxxxxxxxxxxxxxxxxxx",
  "token_type": "Bearer",
  "user": {
    "id": 1,
    "nome": "Maria",
    "email": "maria@example.com"
  }
}
```

---

### `POST /api/login`

**Corpo:**
```json
{
  "email": "maria@example.com",
  "password": "secret123"
}
```

**Resposta `200 OK`:** mesmo formato que o registo (`token`, `token_type`, `user`).  
**Resposta `401 Unauthorized`:** credenciais inválidas.

---

### `POST /api/logout` 🔒

Revoga o token atual.

**Resposta `204 No Content`**

---

### `GET /api/me` 🔒

Devolve o utilizador autenticado.

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

---

### Arquitetura da Autenticação

| Componente | Responsabilidade |
|-----------|-----------------|
| `AuthController` | Orquestra HTTP (controller fino) |
| `AuthService` / `AuthServiceInterface` | Regras de negócio (DIP) |
| `RegisterUserRequest` / `LoginUserRequest` | Validação de entrada |
| `UserResource` | Formato da resposta (`nome` ← `users.name`) |

---

## 📖 API — Livros (CRUD)

> Todas as rotas exigem `auth:sanctum`.

As respostas seguem o envelope padrão do Laravel Resource: objeto único em `data`, listas como array em `data`.

---

### `GET /api/books`

Lista livros com filtros opcionais:

| Query param | Descrição |
|-------------|-----------|
| `titulo` | Filtra por título (normalizado: sem acento, minúsculas) |
| `titulo_do_indice` | Filtra por título de índice; retorna apenas o caminho da raiz até ao índice correspondente |

---

### `POST /api/books`

Cria um livro para o utilizador autenticado.

**Corpo:**
```json
{
  "titulo": "Introdução ao Laravel",
  "numero_paginas": 320,
  "indices": [
    {
      "titulo": "Capítulo 1",
      "pagina": 1,
      "subindices": [
        { "titulo": "Instalação", "pagina": 3, "subindices": [] }
      ]
    }
  ]
}
```

**Resposta `201 Created`:** livro com `id`, `titulo`, `numero_paginas`, `usuario_publicador`, `indices`.

---

### `GET /api/books/{id}`

Detalhe completo do livro com índices em árvore.

---

### `GET /api/books/{id}/similar` 🔒

Lista livros com título semanticamente semelhante ao livro `{id}`.

**Resposta `200 OK`:**
```json
{
  "data": [
    {
      "id": 5,
      "titulo": "Introdução ao Symfony",
      "pontuacao_similaridade": 0.87
    }
  ]
}
```

> Algoritmo: distância de **Levenshtein** sobre títulos normalizados, com pré-filtro SQL para eficiência em grandes volumes.

---

### `PUT /api/books/{id}` 🔒

Atualiza título, páginas e **substitui toda a árvore de índices**.

**Resposta `200 OK`:** livro atualizado.  
**Resposta `403 Forbidden`:** livro pertence a outro utilizador.

---

### `DELETE /api/books/{id}` 🔒

Remove o livro e os seus índices (cascata na BD).

**Resposta `204 No Content`**

---

### Arquitetura dos Livros

| Componente | Responsabilidade |
|-----------|-----------------|
| `BookManagementService` | Casos de uso: criar, listar, atualizar, apagar |
| `BookIndexPayloadWriter` | Escrita recursiva da árvore a partir do JSON |
| `BookIndexNestedSerializer` | Leitura em árvore + poda com `titulo_do_indice` |
| `TitleNormalizer` | Normalização de títulos (livro e índice) |
| `BookObserver` / `BookIndexObserver` | Preenchem `title_normalized` ao guardar |
| `LevenshteinBookTitleSimilarityScorer` | Cálculo de similaridade (substituível) |
| `SimilarBooksFinder` | Seleciona candidatos na BD e aplica o scorer |
| `BookPolicy` | Qualquer auth pode ver/listar; só o dono edita/apaga |
| `ValidNestedBookIndices` | Validação recursiva da árvore de índices (máx. 100 níveis) |

---

## 📱 Frontend (Flutter)

## 🧩 Arquitetura do Mobile (Flutter)

O app segue uma divisão por **features** e por **camadas de infraestrutura**, mantendo responsabilidades claras (SRP) e dependências via providers.

### Organização de pastas (mobile/lib)

```text
mobile/lib
├── core/
│   ├── providers.dart
│   ├── theme/
│   └── widgets/
├── features/
│   ├── auth/
│   │   ├── application/
│   │   └── presentation/
│   ├── books/
│   │   ├── application/
│   │   └── presentation/
│   ├── authors/
│   │   ├── application/
│   │   └── presentation/
│   ├── home/presentation/
│   └── profile/presentation/
├── models/
├── services/
│   ├── auth/
│   ├── books/
│   ├── network/
│   └── storage/
└── main.dart
```

### Responsabilidade de cada área

- `core/`: configuração transversal (tema, providers globais, widgets compartilhados).
- `features/*/presentation`: UI (telas, widgets, navegação, interação do utilizador).
- `features/*/application`: estado e orquestração de ações da feature.
- `services/*`: integração externa (HTTP, storage local, fábrica do cliente Dio).
- `models/`: contratos de dados da app (serialização/desserialização).

### Fluxo de dados no app

1. UI dispara ação (`login`, `filtrar`, `criar livro`, etc.).
2. Notifier da feature processa estado (loading/sucesso/erro).
3. Notifier delega para `RemoteDataSource` (camada de serviço).
4. Resposta é convertida em `models`.
5. Estado é atualizado e a UI reage via Riverpod.

### Sessão e autorização na UI

- token + `userId` persistidos em `shared_preferences`;
- sessão restaurada ao abrir app (`AuthSessionNotifier`);
- em `Unauthenticated`, logout automático e retorno ao login;
- ações sensíveis (editar/excluir) aparecem apenas para o dono do livro.

---

### Instalação

```bash
cd mobile
flutter pub get
```

### Configuração da URL da API

Edita `mobile/lib/config/api_config.dart`:

| Ambiente | URL |
|---------|-----|
| Emulador Android | `http://10.0.2.2:8000/api` |
| Web / Windows | `http://127.0.0.1:8000/api` |
| Override via CLI | `flutter run --dart-define=API_BASE_URL=https://exemplo.com/api` |

### Correr o App

```bash
# Android (emulador já aberto)
cd mobile
flutter run

# Web (sem emulador)
flutter run -d chrome
```

### Navegação

O app possui menu inferior com quatro abas:

| Aba | Conteúdo |
|----|---------|
| 🏠 Home | Ecrã inicial |
| 📚 Livros | Listagem e detalhe de livros |
| 👤 Autores | Listagem de autores |
| 🔑 Perfil | Dados do utilizador + livros publicados (editar/excluir) |

### Sessão e Autenticação

- Token persistido localmente via `shared_preferences`
- Sessão restaurada automaticamente ao abrir o app
- Em token inválido/expirado, logout automático e redireccionamento para login
- `userId` da sessão controla permissões de UI (botões editar/excluir visíveis apenas para o dono do livro)

---

## 🏗️ Decisões Técnicas

| Tópico | Escolha |
|--------|---------|
| Autenticação | Laravel Sanctum (tokens Bearer) |
| Rotas API | `routes/api.php`, prefixo `/api` |
| Arquitetura | SRP: controllers finos; serviços por domínio; contratos + implementações (DIP) |
| Base de Dados | Migrações Laravel; MySQL em produção; SQLite para testes CI |
| Similaridade | Levenshtein sobre `title_normalized` com pré-filtro SQL |
| Flutter | `ApiConfig` por plataforma; sessão com token + `userId`; navegação por abas |

---

## 🎯 Decisões técnicas (com racional)

### Backend

- **Controllers finos + Services**
  - **Por quê:** separa transporte HTTP da regra de negócio.
  - **Ganho:** manutenção e testes mais simples.
  - **Trade-off:** mais ficheiros/classes para navegar.

- **Contracts + Implementações (DIP)**
  - **Por quê:** depender de abstrações facilita evolução.
  - **Ganho:** troca de implementação com impacto mínimo.
  - **Trade-off:** exige disciplina de organização.

- **Form Requests para validação/autorização**
  - **Por quê:** evitar validação espalhada em controller/service.
  - **Ganho:** entradas consistentes e regras explícitas por endpoint.
  - **Trade-off:** curva inicial para mapear requests.

- **Policies para regras de acesso**
  - **Por quê:** centralizar autorização no domínio do recurso.
  - **Ganho:** previsibilidade e segurança (dono edita/apaga).
  - **Trade-off:** precisa manter alinhado com comportamento da UI.

- **Observers para `title_normalized`**
  - **Por quê:** garantir normalização sempre que persistir dados.
  - **Ganho:** filtros e similaridade consistentes.
  - **Trade-off:** regra fica implícita para quem não conhece observers.

- **Levenshtein + pré-filtro SQL**
  - **Por quê:** simplicidade de implementação com custo controlado.
  - **Ganho:** boa relação precisão/esforço para o teste técnico.
  - **Trade-off:** não é semântico profundo como embeddings.

### Mobile

- **Riverpod (`StateNotifier`)**
  - **Por quê:** gestão de estado previsível e testável.
  - **Ganho:** UI reativa com baixo acoplamento.
  - **Trade-off:** requer disciplina no desenho dos providers.

- **Dio + fábrica de cliente + interceptor de token**
  - **Por quê:** centralizar configuração de rede/autorização.
  - **Ganho:** menos duplicação e comportamento uniforme.
  - **Trade-off:** depuração exige conhecer pipeline de interceptores.

- **Persistência local da sessão (`shared_preferences`)**
  - **Por quê:** melhorar UX ao reabrir app.
  - **Ganho:** sessão contínua e recuperação de contexto.
  - **Trade-off:** cuidado adicional com invalidação de token.

- **Navegação por abas com menu inferior**
  - **Por quê:** acesso direto às áreas principais do produto.
  - **Ganho:** fluxo mais rápido entre Home, Livros, Autores e Perfil.
  - **Trade-off:** exige sincronização de estado entre abas.

- **Perfil com ações de gestão dos próprios livros**
  - **Por quê:** concentrar operações de ownership num único lugar.
  - **Ganho:** UX clara para editar/excluir o que é do utilizador.
  - **Trade-off:** precisa manter consistência com as policies do backend.

---
