# Especificação de UI — Linguistic Dictionary

## 1. Visão Geral

A interface deve permitir:

- Listar, buscar e filtrar lexemas.
- Visualizar detalhes de um lexema, incluindo sentidos, paradigmas, exemplos e mídia.
- Criar, editar e excluir lexemas, sentidos, paradigmas, exemplos e tags (conforme permissões).
- Visualizar histórico de revisões e restaurar versões anteriores.
- Upload e visualização de áudio.
- Gerenciamento de tags e métricas administrativas (para usuários admin).

## 2. Telas e Componentes

### 2.1. Tela Inicial / Dashboard

- Acesso rápido para busca de lexemas.
- Estatísticas rápidas (corpus_size, audio_bytes, avg_latency_ms).

### 2.2. Listagem de Lexemas

- Tabela com colunas: Lemma, Língua, Part of Speech, Tags, Ações.
- Filtros: idioma, part of speech, tag, presença de áudio/paradigma, ordenação.
- Paginação (cursor/limit).
- Botão "Novo Lexema".

### 2.3. Busca Avançada

- Campo de busca com suporte a DSL (ex: `lemma:sul* pos:noun`).
- Filtros adicionais: campos a pesquisar, idioma, tags.
- Resultados em lista, com destaques dos termos buscados.

### 2.4. Detalhe do Lexema

- Exibe todos os campos do schema Lexeme.
- Abas ou seções para:
  - Senses (sentidos)
  - Paradigmas
  - Exemplos
  - Áudio (player embutido)
  - Revisões (lista e diff)
- Botões para editar, excluir, restaurar, adicionar sentido/paradigma/exemplo/áudio.

### 2.5. Formulários de Criação/Edição

- Formulários dinâmicos baseados nos schemas `LexemeCreate`, `SenseCreate`, `ParadigmCreate`, `ExampleCreate`.
- Validação de campos obrigatórios.
- Upload de arquivos (áudio).
- Seleção de tags (autocomplete).

### 2.6. Revisões

- Lista de revisões com data, autor, motivo.
- Visualização de diff entre revisões.
- Botão para restaurar versão.

### 2.7. Administração

- Gerenciamento de tags (listar, criar, editar, excluir).
- Visualização de métricas administrativas.

## 3. Componentes Reutilizáveis

- Autocomplete para campos lemma, gloss, definition.
- Player de áudio.
- Modal de confirmação para exclusão/restauração.
- Paginação baseada em cursor.
- Mensagens de erro e feedback do servidor.

## 4. Fluxos Principais

- Listar lexemas → Detalhar lexema → Editar/Excluir/Restaurar.
- Criar lexema → Adicionar sentidos/paradigmas/exemplos/áudio.
- Buscar lexema → Visualizar resultados → Detalhar.
- Gerenciar tags/administração.

## 5. Considerações de Segurança

-

## 6. Mapeamento de Páginas e URLs

| Página / Seção                | URL                                      | Descrição                                                        |
|-------------------------------|------------------------------------------|------------------------------------------------------------------|
| Dashboard                     | `/`                                      | Tela inicial, busca rápida, estatísticas gerais                   |
| Listagem de Lexemas           | `/lexemes`                               | Lista, filtros e paginação de lexemas                             |
| Busca Avançada                | `/search`                                | Busca com DSL e filtros avançados                                 |
| Criar Novo Lexema             | `/lexemes/new`                           | Formulário para criação de lexema                                 |
| Detalhe do Lexema             | `/lexemes/:lexemeId`                     | Visualização detalhada de um lexema                               |
| Editar Lexema                 | `/lexemes/:lexemeId/edit`                | Formulário de edição de lexema                                    |
| Adicionar Sentido             | `/lexemes/:lexemeId/senses/new`          | Formulário para adicionar sentido                                 |
| Editar Sentido                | `/senses/:senseId/edit`                  | Formulário de edição de sentido                                   |
| Adicionar Paradigma           | `/lexemes/:lexemeId/paradigms/new`       | Formulário para adicionar paradigma                               |
| Editar Paradigma              | `/paradigms/:paradigmId/edit`            | Formulário de edição de paradigma                                 |
| Adicionar Exemplo             | `/lexemes/:lexemeId/examples/new`        | Formulário para adicionar exemplo                                 |
| Upload de Áudio               | `/lexemes/:lexemeId/audio/upload`        | Upload de áudio para o lexema                                     |
| Revisões do Lexema            | `/lexemes/:lexemeId/revisions`           | Lista de revisões e opção de restaurar                            |
| Diff de Revisões              | `/lexemes/:lexemeId/diff?from=...&to=...`| Visualização de diferenças entre revisões                         |
| Administração de Tags         | `/admin/tags`                            | Listar, criar, editar, excluir tags                               |
| Editar Tag                    | `/admin/tags/:tagId/edit`                | Formulário de edição de tag                                       |
| Métricas Administrativas      | `/admin/metrics`                         | Visualização de métricas administrativas                          |
| Login/OAuth                   | `/login`                                 | Fluxo de autenticação                                             |

- Fluxo de autenticação OAuth2.
- Exibir/ocultar ações conforme escopo do usuário (read, write, admin).
