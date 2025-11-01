# Dicionario Linguístico - Especificação da API

## 1. Metadados da API

* **Base URL:** `/api/v1`
* **Mídia:** `application/json; charset=utf-8`
* **Versão por header (opcional):** `Accept: application/vnd.ldp.v1+json`
* **Rate limit headers:** `X-RateLimit-Limit`, `-Remaining`, `-Reset`
* **Idempotência:** `Idempotency-Key` em `POST` que sejam reexecutáveis
* **Concorrência:** `ETag` + `If-Match` em `PATCH/PUT/DELETE`
* **Datas:** **RFC 3339** em UTC
* **IDs:** **ULID** (`lex_01H…`), imutáveis

## 2. Segurança

* **OAuth 2.0 (Auth Code + PKCE)** e **API Keys** (server-to-server)
* **Scopes:** `read:dictionary`, `write:lexemes`, `write:media`, `admin:tags`
* **RBAC:** `viewer`, `editor`, `reviewer`, `admin`
* **ABAC por projeto/língua:** `project_id`, `language_code`

## 3. Convenções

* **Paginação (padrão cursor):**

  ```json
  {
    "data": [ ... ],
    "page": {
      "next_cursor": "eyJpZCI6ICJsZXhf...\"",
      "prev_cursor": null,
      "limit": 50
    }
  }
  ```

  `?cursor=…&limit=…`
  (Suporte opcional a `?offset=…&limit=…`)

* **Erros (RFC 7807):**

  ```json
  {
    "type": "https://docs.example.com/errors/resource-not-found",
    "title": "Resource not found",
    "status": 404,
    "detail": "Lexeme 'lex_fake123' not found",
    "instance": "/v1/lexemes/lex_fake123",
    "errors": [
      {"path": "/lemma", "code": "missing", "message": "Required"}
    ]
  }
  ```

## 4. Esquemas (resumo)

### 4.1 `LanguageRef`

```json
{
  "language_code": "quc-Latn",  // BCP-47
  "glottocode": "kicq1236"
}
```

### 4.2 `Lexeme`

```json
{
  "id": "lex_01HZX6F8G4J4C5",
  "lemma": "sula",
  "part_of_speech": "noun",           // controlado (UD POS ou seu vocabulário)
  "language": { "language_code": "xyz" },
  "orthography": {
    "primary": "sula",
    "alternates": ["sulah", "soola"],
    "unicode_normalization": "NFC",
    "orthography_tag": "Latn-Std"
  },
  "phonology": {
    "phonemic_ipa": "/ˈsu.la/",
    "phonetic_ipa": "[ˈsu.la]",
    "syllabification": "su.la",
    "stress": {"pattern": "10", "primary_index": 0},
    "tone": "H↓",                     // esquema documentado
    "audio": [
      {
        "id": "aud_01J1...",
        "dialect": "Northern",
        "speaker_id": "spk_01A…",
        "url": "https://cdn…/sula_dialect1.mp3",
        "mime": "audio/mpeg",
        "duration_ms": 912,
        "sample_rate_hz": 44100,
        "channels": 2,
        "size_bytes": 132544,
        "sha256": "…",
        "variant": "raw"
      }
    ]
  },
  "morphology": {
    "morphemes": [
      {"text": "sul-", "gloss": "sun", "type": "root"},
      {"text": "-a", "gloss": "NOM.SG", "type": "suffix"}
    ],
    "word_formation": {"process": "inflection", "notes": "Class II"},
    "paradigm_ids": ["par_noun_class_2"]
  },
  "senses": ["sense_01HF…"],         // ou embutidos
  "etymology": {
    "text": "From Old XYZ 'sulah'",
    "source_language": "xyz-x-old"
  },
  "tags": ["core_vocabulary","nature","astronomy"],
  "sources": [
    {"type": "informant", "reference": "Speaker J. Doe, 2023-10-26", "license": "CC BY 4.0"}
  ],
  "metadata": {
    "project_id": "proj_01P…",
    "created_at": "2023-10-27T10:00:00Z",
    "updated_at": "2023-10-27T12:35:10Z",
    "latest_revision_id": "rev_98765",
    "deleted_at": null
  }
}
```

### 4.3 `Sense` (com IGT/Leipzig)

```json
{
  "id": "sense_01HZ…",
  "lexeme_id": "lex_01H…",
  "definition": "The star at the center of the solar system; the sun.",
  "gloss": "sun",
  "semantic_domain": ["astronomy","time"],
  "examples": [
    {
      "id": "ex_01Q…",
      "sentence": "Sula bena.",
      "morph_break": "Sula be-na",
      "morph_gloss": "sun shine-IPFV",
      "translation": "The sun is bright."
    }
  ],
  "relations": {
    "synonyms": ["lex_g1h2i3"], "antonyms": ["lex_j4k5l6"],
    "hypernyms": ["lex_m7n8o9"], "meronyms": ["lex_p1q2r3"]
  },
  "syntax": {
    "valency": "intransitive",
    "arguments": [{"role": "theme", "realization": "subject"}],
    "frame": "The [NOUN] shines."
  },
  "sociolinguistics": {
    "register": "formal",
    "connotation": "positive",
    "dialect": "Standard"
  },
  "usage_notes": "Poetic contexts."
}
```

### 4.4 `Paradigm`

```json
{
  "id": "par_verb_class_1_pres",
  "lexeme_id": "lex_k9j8h7…",
  "language": {"language_code": "xyz"},
  "name": "Present Indicative Active",
  "feature_system": "UD/Feat",        // ou outro vocabulário
  "features": ["person","number"],
  "inflected_forms": [
    {
      "form": "walka",
      "features": {"person": "1", "number": "sg"},
      "phonemic_ipa": "/ˈwal.ka/",
      "gloss": "1SG-walk"
    }
  ],
  "metadata": {"created_at": "…", "updated_at":"…"}
}
```

## 5. Endpoints (revisados)

### 5.1 Lexemes

* `GET /v1/lexemes?cursor=&limit=&language_code=&pos=&tag=&has=audio|paradigm`
* `POST /v1/lexemes` *(ETag na resposta, `201 Created`)*
* `GET /v1/lexemes/{id}`
* `PATCH /v1/lexemes/{id}` *(requer `If-Match: <etag>`)*
* `DELETE /v1/lexemes/{id}` *(soft delete; `204 No Content`)*
* `POST /v1/lexemes:bulk-import` *(NDJSON; assíncrono via `202 Accepted` + `Operation-Location`)*
* `GET /v1/lexemes:export.ndjson?language_code=xyz`

### 5.2 Senses

* `GET /v1/lexemes/{id}/senses`
* `POST /v1/lexemes/{id}/senses`
* `GET /v1/senses/{sense_id}`
* `PATCH /v1/senses/{sense_id}`
* `DELETE /v1/senses/{sense_id}`

### 5.3 Paradigms

* `POST /v1/lexemes/{id}/paradigms`
* `GET /v1/lexemes/{id}/paradigms`
* `GET /v1/paradigms/{paradigm_id}`
* `PATCH /v1/paradigms/{paradigm_id}`
* `DELETE /v1/paradigms/{paradigm_id}`

### 5.4 Exemplos e Mídia

* `POST /v1/lexemes/{id}/examples` *(IGT completo)*
* `POST /v1/lexemes/{id}/audio` *(multipart; campos `file`, `dialect`, `speaker_id`; resposta inclui `sha256`)*

### 5.5 Revisões e Diferenças

* `GET /v1/lexemes/{id}/revisions?cursor=&limit=`
* `GET /v1/lexemes/{id}/revisions/{rev_id}`
* `GET /v1/lexemes/{id}/diff?from=rev_a&to=rev_b`
* `POST /v1/lexemes/{id}:restore` *(restaura de `rev_id` ou desfaz soft delete)*

### 5.6 Busca, Autocomplete, Sugestões

* `GET /v1/search?q=&in=lemma,definition,morph_gloss&language_code=xyz&f=pos:noun,has:audio`
* `GET /v1/autocomplete?field=lemma&prefix=su&language_code=xyz&limit=10`
* `GET /v1/suggest?lemma=sula&language_code=xyz` *(formas relacionadas, variantes ortográficas, cognatos — se disponível)*

### 5.7 Admin (vocabulários controlados)

* `GET/POST/PATCH/DELETE /v1/admin/tags`
* `GET /v1/admin/metrics` *(ingestões, latência, tamanho de corpus, etc.)*

## 6. Busca – DSL (mini-especificação)

* **Consulta livre** em `q`.
* **Campos** (`in=`) ou **prefixos** no `q`:
  `lemma:sul* sense:def~sun morph_gloss:NOM.SG has:audio pos:noun dialect:Northern`
* **Operadores**: `AND` (implícito), `OR`, `-` (NOT), `~` (fuzzy), `*` (prefixo).
* **Ranking**: BM25 + *boost* por campo (`lemma` > `sense.definition` > `morph_gloss`).

## 7. Validações (regras úteis)

* `orthography.unicode_normalization` **NFC** obrigatório.
* `phonology.phonemic_ipa`: regex IPA básico + verificação de pares `//`, `[]`.
* `language.language_code`: **BCP-47** válido.
* `morphology.morphemes[].gloss`: recomenda-se **Leipzig**.
* `media`: exigir `sha256`, `mime`, `size_bytes`; rejeitar upload sem `speaker_id` quando política exigir consentimento.

## 8. Webhooks (opcional mas recomendado)

* `lexeme.created|updated|deleted`, `sense.updated`, `paradigm.updated`, `media.added`
* Assinatura `X-Signature-256`

---

# Mini-OpenAPI (trecho)

```yaml
openapi: 3.1.0
info:
  title: Linguistic Dictionary API
  version: "1.0"
servers:
  - url: /api/v1
paths:
  /lexemes:
    get:
      summary: List lexemes
      parameters:
        - in: query; name: cursor; schema: {type: string}
        - in: query; name: limit;  schema: {type: integer, minimum: 1, maximum: 200, default: 50}
        - in: query; name: language_code; schema: {type: string}
        - in: query; name: pos; schema: {type: string}
        - in: query; name: tag; schema: {type: string}
        - in: query; name: has; schema: {type: string, enum: [audio, paradigm]}
      responses:
        "200":
          description: OK
          headers:
            ETag: {description: Entity tag, schema: {type: string}}
          content:
            application/json:
              schema:
                type: object
                properties:
                  data:
                    type: array
                    items: {$ref: "#/components/schemas/Lexeme"}
                  page:
                    $ref: "#/components/schemas/CursorPage"
    post:
      summary: Create lexeme
      security: [{ OAuth2: [write:lexemes] }]
      requestBody:
        required: true
        content:
          application/json:
            schema: {$ref: "#/components/schemas/LexemeCreate"}
      responses:
        "201":
          description: Created
          headers:
            ETag: {schema: {type: string}}
          content:
            application/json:
              schema: {$ref: "#/components/schemas/Lexeme"}
  /search:
    get:
      summary: Full-text search with DSL
      parameters:
        - in: query; name: q; required: true; schema: {type: string}
        - in: query; name: in; schema: {type: string}
        - in: query; name: language_code; schema: {type: string}
        - in: query; name: f; description: filters (comma-separated)
      responses:
        "200":
          description: OK
          content:
            application/json:
              schema: {$ref: "#/components/schemas/SearchResult"}
components:
  securitySchemes:
    OAuth2:
      type: oauth2
      flows:
        authorizationCode:
          authorizationUrl: https://auth.example.com/authorize
          tokenUrl: https://auth.example.com/token
          scopes:
            read:dictionary: Read
            write:lexemes: Write lexemes
            write:media: Upload media
            admin:tags: Manage tags
  schemas:
    CursorPage:
      type: object
      properties:
        next_cursor: {type: string, nullable: true}
        prev_cursor: {type: string, nullable: true}
        limit: {type: integer}
    Lexeme:
      type: object
      required: [id, lemma, language]
      properties:
        id: {type: string}
        lemma: {type: string}
        language:
          type: object
          properties:
            language_code: {type: string}
            glottocode: {type: string, nullable: true}
        # … (demais campos conforme seção 4.2)
    LexemeCreate:
      allOf:
        - $ref: "#/components/schemas/Lexeme"
        - type: object
          properties:
            id: {readOnly: true}
            metadata: {readOnly: true}
    SearchResult:
      type: object
      properties:
        data:
          type: array
          items: {$ref: "#/components/schemas/Lexeme"}
        page:
          $ref: "#/components/schemas/CursorPage"
```

---

## Exemplos de requisições (úteis para QA)

**Criar lexema (idempotente):**

```
POST /api/v1/lexemes
Idempotency-Key: 5f1c2…
Content-Type: application/json

{ "lemma": "sula", "language": {"language_code": "xyz"}, "part_of_speech": "noun" }
```

**Atualizar com controle otimista:**

```
PATCH /api/v1/lexemes/lex_01HZX… 
If-Match: "W/\"e3b0c442…\""
```

**Busca por IGT e gloss:**

```
GET /api/v1/search?q=morph_gloss:NOM.SG AND lemma:sul*&in=lemma,definition,morph_gloss&language_code=xyz
```

---

## Checklist de qualidade (para implementação)

* [ ] Enforce **BCP-47** e **NFC** em *write paths*
* [ ] Responder **RFC 7807** em todos os erros
* [ ] **ETag** em `GET` e exigência de `If-Match` em `PATCH/DELETE`
* [ ] **Cursor pagination** por índice estável + `created_at,id`
* [ ] Validação de `IPA` (fonêmica `//`, fonética `[]`)
* [ ] IGT obrigatório quando `examples[].morph_break` presente
* [ ] **Licença** e **proveniência** em `sources[]` e `media`
* [ ] **Bulk import/export** em NDJSON com operação assíncrona
* [ ] **Webhooks** com assinatura HMAC (`X-Signature-256`)
* [ ] **Scopes** + **RBAC** + **ABAC** por `project_id`/`language_code`
