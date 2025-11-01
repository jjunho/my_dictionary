# Playbook Elm Land — CLI‑first (Consolidado)

> Documento de referência para treinar/orientar uma IA (e humanos) a programar em **Elm Land** priorizando **CLI** e **Elm puro**. Ports (JS/TS) apenas quando inevitável.

---

## 0) Objetivo

### Escopo & Não‑objetivos

**Cobertura:** fluxo CLI‑first, TEA com Elm puro, HTTP/JSON, estrutura de pastas, `Shared`, padrões de teste e `elm-review`, ports mínimos quando inevitáveis.
**Fora do escopo:** SSR, autenticação avançada (OAuth/JWT), i18n completo, animações complexas/WebGL, gráficos avançados, testes E2E, GraphQL/WS, otimizações de bundler além do padrão do Elm Land.

### Versões alvo

* **Elm:** 0.19.1
* **Elm Land:** v0.20.1
* **Node:** 20 LTS (recomendado)
* **Ferramentas:** `elm-test`, `elm-review`, `elm-format` compatíveis com Elm 0.19.1.

### Sumário

- [Playbook Elm Land — CLI‑first (Consolidado)](#playbook-elm-land--clifirst-consolidado)
  - [0) Objetivo](#0-objetivo)
    - [Escopo \& Não‑objetivos](#escopo--nãoobjetivos)
    - [Versões alvo](#versões-alvo)
    - [Sumário](#sumário)
  - [1) Prioridade (ordem não negociável)](#1-prioridade-ordem-não-negociável)
  - [2) Decisão em árvore (rápida)](#2-decisão-em-árvore-rápida)
  - [3) Fluxo CLI‑driven (sempre igual)](#3-fluxo-clidriven-sempre-igual)
  - [4) Estrutura de pastas (CLI para Pages; módulos internos à vontade)](#4-estrutura-de-pastas-cli-para-pages-módulos-internos-à-vontade)
  - [5) Skeletons canônicos](#5-skeletons-canônicos)
    - [5.1 `Lib/Remote.elm`](#51-libremoteelm)
    - [5.2 `Api/Types.elm` (IDs opacos)](#52-apitypeselm-ids-opacos)
    - [5.3 `Api/Decode.elm` (Pipeline para 9+ campos)](#53-apidecodeelm-pipeline-para-9-campos)
    - [5.4 `Api/Http.elm` (Effects do Elm Land)](#54-apihttpelm-effects-do-elm-land)
    - [5.5 Exemplo de página `element` consumindo a minilibraria](#55-exemplo-de-página-element-consumindo-a-minilibraria)
  - [6) Cheatsheet de CLI (operacional)](#6-cheatsheet-de-cli-operacional)
  - [7) Rotina de verificação (antes de PR)](#7-rotina-de-verificação-antes-de-pr)
  - [8) Troubleshooting (CLI‑first)](#8-troubleshooting-clifirst)
  - [9) Protocolo de Fallback via Ports (último caso)](#9-protocolo-de-fallback-via-ports-último-caso)
    - [9.1 Contrato de porta (versão, timeouts, fila, erros estruturados)](#91-contrato-de-porta-versão-timeouts-fila-erros-estruturados)
    - [9.2 Exemplo mínimo (Storage)](#92-exemplo-mínimo-storage)
  - [10) NPM scripts / Makefile / CI](#10-npm-scripts--makefile--ci)
  - [11) Exercícios de treino (avaliáveis por CLI)](#11-exercícios-de-treino-avaliáveis-por-cli)
  - [12) Anti‑padrões (evitar)](#12-antipadrões-evitar)
  - [13) Checklists](#13-checklists)
  - [14) Testes canônicos (`elm-test`) — exemplos mínimos](#14-testes-canônicos-elm-test--exemplos-mínimos)
  - [15) `elm-review` — preset recomendado](#15-elm-review--preset-recomendado)
  - [16) Rotas e convenções](#16-rotas-e-convenções)
  - [17) Padrões de formulário (sem ports)](#17-padrões-de-formulário-sem-ports)
  - [18) `Shared` — estado global com parcimônia](#18-shared--estado-global-com-parcimônia)
  - [19) Git e PR — padrão de equipe](#19-git-e-pr--padrão-de-equipe)
  - [20) Deploy rápido](#20-deploy-rápido)
  - [21) Acessibilidade \& UX (check rápido)](#21-acessibilidade--ux-check-rápido)
    - [Resumo final](#resumo-final)

Ensinar uma IA a entregar mudanças pequenas, seguras e verificáveis em projetos Elm Land, usando passos curtos, o compilador como oráculo, testes como critério de aceite e artefatos consistentes (format, review, build).

**Regras de ouro:**

0. **CLI first** → sempre comece pela CLI, evitando edições manuais sempre que possível.
1. **Seja organizado e metódico** → siga este playbook passo a passo e não pule etapas.
2. **Seja limpo** → nunca deixe código quebrado, testes falhando ou arquivos antigos/inutilizados.
3. **Planeje primeiro** → registre um mini‑plano (3–7 bullets) antes de editar.
4. **Small diff** → uma mudança por PR/commit (≈100–150 linhas máx.).
5. **Cadência** → `elm-format`, `elm-review`, `elm-test`, `elm-land build` a cada passo.
6. **Mensagens do compilador** guiam a próxima alteração.
7. **Sem TODOs órfãos** → se criar, abra issue vinculada no PR.
8. **Sempre criar branches** para mudanças (nunca direto na main).
9. **Commits frequentes** → sempre que compilar com sucesso e a build estiver limpa, fazer commit semântico claro.
10. **Commit inicial** → assim que o projeto rodar sem erros, commitar com mensagem clara do escopo/tema do projeto.

---

## 1) Prioridade (ordem não negociável)

1. **Elm Land (CLI e convenções)**
2. **Elm puro** (TEA; pacotes oficiais; módulos internos)
3. **Ports** (JS/TS) **só** se 1+2 forem realmente impossíveis

---

## 2) Decisão em árvore (rápida)

**P1 — A CLI resolve o esqueleto?**
✔️ Use `elm-land add …` / `elm-land customize …`.
❌ Reenquadre o problema para caber em `page:view/sandbox/element`, `layout`, `shared`, `effect`.

**P2 — Dá para implementar só com Elm?**
✔️ Continue com Elm (HTTP, JSON, view, Shared, Subscriptions).
❌ **Comprove** a impossibilidade (Web API não exposta, biblioteca Elm inexistente) → Ports.

**P3 — Existe pacote Elm confiável?**

* HTTP: `elm/http`
* JSON Pipeline: `NoRedInk/elm-json-decode-pipeline`
* URL/Query: `elm/url`
* Data/Time: `elm/time`, `rtfeldman/elm-iso8601-date-strings`
* UUID: `TSFoster/elm-uuid` (ou back‑end)

**P4 — Ainda impossível?**
Aplique o **Protocolo de Ports** (ver §9).

---

## 3) Fluxo CLI‑driven (sempre igual)

> **Notas rápidas**
>
> * **`generate`**: inspeção/CI rápido (gera só o código Elm Land, sem bundle/minificação). Útil antes de `elm-test`/`elm-review`.
> * **`build`**: artefatos de **produção** em `./dist` (minificados, prontos para deploy).
> * **Ambiente**: padronize **Node 20 LTS** com `.nvmrc` e documente **`npm ci`** no README para reprodutibilidade.

```bash
# criar projeto
elm-land new my-app
cd my-app

# servidor (Vite embutido)
elm-land server
# Para expor na rede: HOST=0.0.0.0 PORT=5173 elm-land server

# build de produção → ./dist
elm-land build

# gerar apenas código Elm Land (sem bundle/minificação)
elm-land generate

# listar rotas
elm-land routes

# scaffold de páginas
elm-land add page:view /about
elm-land add page:sandbox /counter
elm-land add page:element /products

# layouts e personalizações
elm-land add layout Default
elm-land customize shared
elm-land customize not-found
elm-land customize view:elm-ui   # ou view, view:elm-css
elm-land customize effect
elm-land customize js
elm-land customize ts

# dependências Elm (não JS)
elm install elm/http
elm install NoRedInk/elm-json-decode-pipeline
```

---

## 4) Estrutura de pastas (CLI para Pages; módulos internos à vontade)

```
src/
├── Pages/                       # ✅ SOMENTE via CLI
│   ├── Home_.elm
│   └── Products_.elm
│
├── Layouts/                     # ✅ via CLI: add layout
│   └── Default.elm
│
├── Shared/                      # ✅ via CLI: customize shared
│   ├── Model.elm
│   ├── Msg.elm
│   └── Shared.elm
│
├── Api/                         # 👇 minibibliotecas internas (criar manualmente)
│   ├── Types.elm
│   ├── Decode.elm
│   ├── Encode.elm
│   └── Http.elm
│
├── Domain/                      # Regras de negócio puras (sem Http/Effect/ports)
│   └── Cart.elm
│
├── View/                        # Componentes de apresentação (sem lógica de negócio)
│   └── Components/              # Botões, cartões, listas, etc. (puros/reutilizáveis)
│
├── Lib/                         # Utilidades puras reutilizáveis
│   ├── Remote.elm               # Remote(NotAsked|Loading|Success|Failure)
│   └── Format.elm               # ex.: formatar preço, datas
│
├── RoutePath.elm                # Helpers de caminhos tipados (centraliza paths)
│
└── Interop/                     # Ports (último recurso)
    └── Storage.elm
```

**Convenções**

* Nome de módulo = caminho: `src/Api/Http.elm` → `module Api.Http …`
* **Domínio é puro**: módulos em `Domain/` **nunca** importam `Http`/`Effect`/`Ports`; `View/` **não** contém lógica de negócio.
* Centralize paths em `RoutePath.elm` e use helpers tipados para evitar strings soltas.
* Expose mínimo nos módulos de fronteira.
* Aliases sugeridos: `import Api.Types as Api`, `import Api.Http as ApiHttp`, `import Domain.Cart as Cart`, `import Lib.Remote as R`, `import RoutePath as Path`, `import View.Components as C`.

---

## 5) Skeletons canônicos

### 5.1 `Lib/Remote.elm`

```elm
module Lib.Remote exposing (Remote(..), map, withDefault)

type Remote a = NotAsked | Loading | Success a | Failure String

map : (a -> b) -> Remote a -> Remote b
map f r = case r of Success a -> Success (f a); NotAsked -> NotAsked; Loading -> Loading; Failure e -> Failure e

withDefault : a -> Remote a -> a
withDefault d r = case r of Success a -> a; _ -> d
```

### 5.2 `Api/Types.elm` (IDs opacos)

```elm
module Api.Types exposing (Product, ProductId, productId, unProductId)

type ProductId = ProductId Int
productId : Int -> ProductId
productId n = ProductId n
unProductId : ProductId -> Int
unProductId (ProductId n) = n

type alias Product =
    { id : ProductId
    , name : String
    , price : Float
    , image : String
    , inStock : Bool
    }
```

### 5.3 `Api/Decode.elm` (Pipeline para 9+ campos)

```elm
module Api.Decode exposing (product, products)

import Api.Types as Api
import Json.Decode as D
import Json.Decode.Pipeline exposing (required)

product : D.Decoder Api.Product
product =
    D.succeed (\id name price image inStock ->
        { id = Api.productId id
        , name = name
        , price = price
        , image = image
        , inStock = inStock
        }
    )
        |> required "id" D.int
        |> required "name" D.string
        |> required "price" D.float
        |> required "image" D.string
        |> required "inStock" D.bool

products : D.Decoder (List Api.Product)
products = D.list product
```

### 5.4 `Api/Http.elm` (Effects do Elm Land)

```elm
module Api.Http exposing (listProducts, getProduct)

import Api.Decode as Decode
import Api.Types as Api
import Effect exposing (Effect)
import Http

listProducts :
    { onResponse : Result Http.Error (List Api.Product) -> msg }
    -> Effect msg
listProducts opts =
    Http.get
        { url = "/products"
        , expect = Http.expectJson opts.onResponse Decode.products
        }
        |> Effect.sendCmd

getProduct :
    { id : Api.ProductId
    , onResponse : Result Http.Error Api.Product -> msg
    }
    -> Effect msg
getProduct opts =
    let
        url = "/products/" ++ String.fromInt (Api.unProductId opts.id)
    in
    Http.get { url = url, expect = Http.expectJson opts.onResponse Decode.product }
        |> Effect.sendCmd
```

### 5.5 Exemplo de página `element` consumindo a minilibraria

```elm
module Pages.Products_ exposing (Model, Msg, page)

import Api.Http as ApiHttp
import Api.Types as Api
import Effect exposing (Effect)
import Http
import Lib.Remote as R
import Page
import Route
import Shared
import View exposing (View)

type alias Model =
    { data : R.Remote (List Api.Product) }

type Msg
    = Fetched (Result Http.Error (List Api.Product))
    | Refresh

page : Shared.Model -> Route () -> Page.Page Model Msg
page _ _ =
    Page.new
        { init = \_ -> init
        , update = update
        , subscriptions = \_ -> Sub.none
        , view = view
        }

init : ( Model, Effect Msg )
init =
    ( { data = R.Loading }
    , ApiHttp.listProducts { onResponse = Fetched }
    )

update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        Fetched (Ok xs) ->
            ( { model | data = R.Success xs }, Effect.none )

        Fetched (Err e) ->
            ( { model | data = R.Failure (httpErr e) }, Effect.none )

        Refresh ->
            ( { model | data = R.Loading }
            , ApiHttp.listProducts { onResponse = Fetched }
            )

view : Model -> View Msg
view model =
    View.column
        [ case model.data of
            R.Loading -> View.text "Carregando…"
            R.Failure e -> View.text ("Erro: " ++ e)
            R.NotAsked -> View.text "…"
            R.Success xs ->
                View.column (List.map (\p -> View.text p.name) xs)
        , View.button [ View.onClick Refresh ] [ View.text "Atualizar" ]
        ]

httpErr : Http.Error -> String
httpErr e =
    case e of
        Http.BadUrl u -> "URL inválida: " ++ u
        Http.Timeout -> "Tempo esgotado"
        Http.NetworkError -> "Sem rede"
        Http.BadStatus _ -> "Erro de status HTTP"
        Http.BadBody _ -> "JSON inesperado"
```

---

## 6) Cheatsheet de CLI (operacional)

* **Projeto & servidor**
  `elm-land new <nome>` → `elm-land server`
* **Build**
  `elm-land build` (gera `./dist`)
* **Geração de código**
  `elm-land generate`
* **Rotas**
  `elm-land routes`
* **Páginas**
  `elm-land add page:view /...`
  `elm-land add page:sandbox /...`
  `elm-land add page:element /...`
* **Layouts**
  `elm-land add layout <Nome>`
* **Customizações**
  `elm-land customize shared|not-found|view|view:elm-ui|view:elm-css|effect|js|ts`
* **Deps Elm**
  `elm install elm/http`
  `elm install NoRedInk/elm-json-decode-pipeline`

---

## 7) Rotina de verificação (antes de PR)

```bash
elm-land routes
npx elm-format --validate .
npx elm-review
npx elm-test
elm-land build
```

**Aceite mínimo**

* Sem `Debug.*`
* Sem warnings
* `elm-review` limpo (`NoUnused.*`, `NoDebug.*`, etc.)
* Testes passando (decoders + branches críticos de `update`)

---

## 8) Troubleshooting (CLI‑first)

* **"Couldn't find a project in this folder"** → está na pasta errada. Procure `elm-land.json`/`elm.json`.
* **"Folder not empty"** → Prefira criar um novo projeto limpo em um novo diretório.
* **"elm.json dependencies"** → não edite `elm.json` manualmente; use `elm install`.
* **"elm/http not installed"** → `elm install elm/http` e recompile.
* **Decoder 9+ campos** → evite `map8 + andThen`; use **Pipeline**.
* **Rota não aparece** → `elm-land routes` e verifique o underscore (`Pages/Foo_.elm`).
* **Proxy/CORS** → prefira URL absoluta no dev; teste com `curl -H "Origin: http://localhost:5173" ...`.

---

## 9) Protocolo de Fallback via Ports (último caso)

**Quando**: Web API não disponível no Elm; ausência de pacote Elm; exigência de integração nativa.

**Regras**

1. Superfície mínima (tipos simples).
2. Uma porta por assunto (ex.: storage).
3. Converter tudo para tipos de domínio antes de sair de Interop/.
4. Incluir retry/cancel, timeouts e erros legíveis.
5. Fila única por assunto para evitar race conditions.
6. Segurança: mesma origem, sem eval, nada de interpolar dados de ports no DOM sem sanitização.

### 9.1 Contrato de porta (versão, timeouts, fila, erros estruturados)

Envelope padrão recomendado:

* version : Int — versão do contrato
* op : String — operação, por exemplo set ou get
* reqId : String — id único por requisição
* payload : Json — dados da operação
* timeoutMs : Int — tempo máximo para resposta

Resposta (JS para Elm):

* { version, reqId, ok: Json ou null, err: { code: String, message: String } ou null }

Códigos sugeridos: E_TIMEOUT, E_INVALID_OP, E_STORAGE_DENIED, E_UNKNOWN.

**Elm (ports e decoder em Interop/)**

```elm
port module Interop.Storage exposing (toJs, fromJs, ToJs, FromJs, sendSet, decodeFromJs)

import Json.Decode as D
import Json.Encode as E

-- Envelope

type alias ToJs =
    { version : Int
    , op : String
    , reqId : String
    , payload : E.Value
    , timeoutMs : Int
    }

type alias FromJs =
    { version : Int
    , reqId : String
    , ok : Maybe D.Value
    , err : Maybe { code : String, message : String }
    }

port toJs : ToJs -> Cmd msg
port fromJs : (D.Value -> msg) -> Sub msg

toErr : String -> String -> { code : String, message : String }
toErr c m = { code = c, message = m }

decodeFromJs : D.Decoder FromJs
decodeFromJs =
    D.map4 FromJs
        (D.field "version" D.int)
        (D.field "reqId" D.string)
        (D.maybe (D.field "ok" D.value))
        (D.maybe (D.field "err" (D.map2 toErr (D.field "code" D.string) (D.field "message" D.string))))

sendSet : { key : String, value : Maybe String } -> String -> Cmd msg
sendSet args reqId =
    let
        payload =
            E.object
                [ ( "key", E.string args.key )
                , ( "value", Maybe.withDefault E.null (Maybe.map E.string args.value) )
                ]
    in
    toJs
        { version = 1
        , op = "set"
        , reqId = reqId
        , payload = payload
        , timeoutMs = 1500
        }
```

Nota: ports não transportam union types diretamente. Use DTO e Json.Decode em Interop/ para converter a resposta ao seu tipo de domínio, por exemplo `type StorageErr = Timeout | Denied | Unknown String`.

**Host TS (versão, fila por assunto, timeout e backoff exponencial com jitter)**

```ts
// Fila única por assunto (storage)
const queue: Array<{ msg: any; t: number }> = [];
let processing = false;

function processQueue(app: any) {
  if (processing || queue.length === 0) return;
  processing = true;
  const { msg } = queue.shift()!;

  const { version, op, reqId, payload, timeoutMs } = msg;
  if (version !== 1) {
    app.ports.fromJs.send({ version, reqId, ok: null, err: { code: "E_INVALID_VERSION", message: "Unsupported contract" } });
    processing = false;
    return processQueue(app);
  }

  const timeout = setTimeout(() => {
    app.ports.fromJs.send({ version, reqId, ok: null, err: { code: "E_TIMEOUT", message: `Timeout after ${timeoutMs}ms` } });
    processing = false;
    processQueue(app);
  }, timeoutMs);

  try {
    if (op === "set") {
      const key = String(payload.key || "");
      const val = payload.value == null ? null : String(payload.value);
      // segurança básica
      if (!location || location.origin !== window.origin) throw new Error("cross-origin");
      if (val == null) localStorage.removeItem(key);
      else localStorage.setItem(key, val);
      clearTimeout(timeout);
      app.ports.fromJs.send({ version, reqId, ok: null, err: null });
    } else if (op === "get") {
      const key = String(payload.key || "");
      const v = localStorage.getItem(key);
      clearTimeout(timeout);
      app.ports.fromJs.send({ version, reqId, ok: v, err: null });
    } else {
      clearTimeout(timeout);
      app.ports.fromJs.send({ version, reqId, ok: null, err: { code: "E_INVALID_OP", message: `op=${op}` } });
    }
  } catch (e: any) {
    clearTimeout(timeout);
    app.ports.fromJs.send({ version, reqId, ok: null, err: { code: "E_STORAGE_DENIED", message: String(e?.message || e) } });
  } finally {
    processing = false;
    processQueue(app);
  }
}

function backoff(attempt: number, base = 150): number {
  const jitter = Math.random() * 50;
  return Math.min(2000, base * Math.pow(2, attempt)) + jitter;
}

export function bindPorts(app: any) {
  let attempt = 0;
  app.ports.toJs.subscribe((msg: any) => {
    queue.push({ msg, t: Date.now() });
    processQueue(app);
  });

  // exemplo de reprocessamento sob falha eventual
  if (app.ports.fromJs) {
    app.ports.fromJs.subscribe((res: any) => {
      if (res?.err?.code === "E_STORAGE_DENIED" && attempt < 3) {
        setTimeout(() => processQueue(app), backoff(++attempt));
      } else {
        attempt = 0;
      }
    });
  }
}
```

Segurança: garanta mesma origem, nunca use eval, valide e escape entradas antes de qualquer interação com o DOM. Para APIs externas, limite origem via cabeçalhos e use tokens com escopo mínimo.

### 9.2 Exemplo mínimo (Storage)

**Elm — envio e assinatura encapsulados**

```elm
port toJs : ToJs -> Cmd msg
port fromJs : (D.Value -> msg) -> Sub msg

onFromJs : (FromJs -> msg) -> D.Value -> msg
onFromJs tagger v =
    case D.decodeValue decodeFromJs v of
        Ok dto -> tagger dto
        Err _ -> tagger { version = 1, reqId = "", ok = Nothing, err = Just { code = "E_DECODE", message = "invalid payload" } }

subscriptions : (FromJs -> msg) -> Sub msg
subscriptions tagger =
    fromJs (onFromJs tagger)
```

**Elm — adaptadores de domínio**

```elm
type StorageErr = Timeout | InvalidOp | Denied | DecodeErr | Unknown String

fromDto : FromJs -> Result StorageErr (Maybe String)
fromDto dto =
    case ( dto.ok, dto.err ) of
        ( Just v, Nothing ) ->
            case D.decodeValue D.string v of
                Ok s -> Ok (Just s)
                Err _ -> Err DecodeErr

        ( Nothing, Nothing ) -> Ok Nothing
        ( _, Just e ) ->
            case e.code of
                "E_TIMEOUT" -> Err Timeout
                "E_INVALID_OP" -> Err InvalidOp
                "E_STORAGE_DENIED" -> Err Denied
                "E_DECODE" -> Err DecodeErr
                other -> Err (Unknown other)
```

Regra de ouro: todo dado que entra por port sai de Interop/ como tipo de domínio, nunca como String ou Value cru.

---

## 10) NPM scripts / Makefile / CI

**package.json**

Não deve ser editado manualmente. Toda mudança é feita por meio do comando `elm`.

**Makefile (opcional)**

```make
dev:        ## servidor de dev
  elm-land server

build:      ## build prod
  elm-land build

routes:     ## lista rotas
  elm-land routes

page-view:  ## make page-view PATH=/about
  elm-land add page:view $(PATH)

page-sandbox:
  elm-land add page:sandbox $(PATH)

page-element:
  elm-land add page:element $(PATH)

check:      ## lint+test+build
  elm-format --validate .
  elm-review
  elm-test
  elm-land build
```

**CI (GitHub Actions)**

```yaml
name: ci
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-node@v4
        with: { node-version: 20 }
      - run: npm ci || npm i
      - run: npx elm-format --validate .
      - run: npx elm-review
      - run: npx elm-test
      - run: elm-land build
```

---

## 11) Exercícios de treino (avaliáveis por CLI)

1. **View route**
   `elm-land add page:view /status` → renderizar "OK"; `elm-land routes` lista `/status`.
2. **Sandbox counter**
   `elm-land add page:sandbox /counter` → +1/−1; build verde.
3. **Element + HTTP**
   `elm-land add page:element /products` + `elm install` deps → listar, estados Loading/Erro/Success; testes de decoder.
4. **Shared cart**
   `elm-land customize shared` → `Shared.Msg` com `AddToCart ProductId`; páginas disparam; header mostra contagem.
5. **Port opcional**
   Persistir carrinho em `localStorage` via Ports seguindo o protocolo do §9.

---

## 12) Anti‑padrões (evitar)

* Criar arquivos sob `Pages/` sem a CLI.
* Resolver no JS o que Elm/Elm Land já cobre (HTTP/JSON, validação, URL, estado).
* `String` para IDs em todo lugar (prefira tipos opacos).
* Decoders longos com `map8 + andThen` ilegível (use Pipeline).
* Jogar tudo em `Shared` sem critério (apenas o que é global de verdade).
* Não rodar `elm-land routes` após tocar em rotas/arquivos.

---

## 13) Checklists

**Novo recurso (feature pequena)**

*

**Integração com API (HTTP)**

*

**Refactor seguro (sem mudar comportamento)**

*

**Bugfix/Hotfix**

*

**Uso de ****************`Shared`**************** (estado global)**

*

**Ports (último recurso)**

*

**Acessibilidade & UX**

*

**Artefatos obrigatórios no PR**

*

---

## 14) Testes canônicos (`elm-test`) — exemplos mínimos

**Agregação & script padrão**

* Crie um **agregador** `tests/Tests.elm` reunindo todos os módulos de teste (ex.: `DecodeProductTest`, `CounterUpdateTest`, `FuzzProductTest`, `CounterInvariantTest`).
* Padronize a execução com `npm pkg set scripts.test=\"elm-test\"` (ou adicione manualmente `\"test\": \"elm-test\"` no `package.json`).

**Fuzz (property‑based) — `FuzzProductTest.elm`**

```elm
module FuzzProductTest exposing (tests)

import Api.Decode as Decode
import Expect
import Fuzz exposing (..)
import Json.Decode as D
import Json.Encode as E
import Test exposing (..)

-- Gera produtos válidos e verifica propriedade (ex.: price >= 0)
productTuple : Fuzzer ( Int, String, Float, String, Bool )
productTuple =
    tuple5 (intRange 1 100000) (string) (floatRange 0 100000) (string) bool

tests : Test
tests =
    describe "Api.Decode.product (fuzz)"
        [ fuzz productTuple "decodifica produtos gerados e mantém invariantes" <|
            \( id, name, price, image, inStock ) ->
                let
                    json =
                        E.encode 0 <|
                            E.object
                                [ ( "id", E.int id )
                                , ( "name", E.string name )
                                , ( "price", E.float price )
                                , ( "image", E.string image )
                                , ( "inStock", E.bool inStock )
                                ]
                in
                case D.decodeString Decode.product json of
                    Ok p ->
                        Expect.all
                            [ \_ -> Expect.equal name p.name
                            , \_ -> Expect.atLeast 0.0 p.price
                            ]
                    Err e ->
                        Expect.fail (D.errorToString e)
        ]
```

**Invariantes de `update` — `CounterInvariantTest.elm`**

```elm
module CounterInvariantTest exposing (tests)

import Expect
import Fuzz exposing (..)
import Pages.Counter_ as C -- página sandbox gerada pelo CLI
import Test exposing (..)

-- Invariante: contador final == soma dos passos (+1/-1) a partir de 0
step : Fuzzer Int
step = oneOf [ constant 1, constant -1 ]

apply : Int -> C.Model -> C.Model
apply s m =
    let
        msg = if s == 1 then C.Increment else C.Decrement
        ( m2, _ ) = C.update msg m
    in
    m2

tests : Test
tests =
    describe "Counter.update (invariantes)"
        [ fuzz (listOfLengthBetween 0 200 step) "soma de passos == estado final" <|
            \steps ->
                let
                    ( m0, _ ) = C.init ()
                    mN = List.foldl apply m0 steps
                    expected = List.sum steps
                in
                Expect.equal expected mN.count
        ]
```

**Agregador — `tests/Tests.elm`**

```elm
module Tests exposing (tests)

import CounterInvariantTest
import CounterUpdateTest
import DecodeProductTest
import FuzzProductTest
import Test exposing (..)

tests : Test
tests =
    describe "All"
        [ DecodeProductTest.tests
        , FuzzProductTest.tests
        , CounterUpdateTest.tests
        , CounterInvariantTest.tests
        ]
```

**Estrutura**

```
./tests/
├── DecodeProductTest.elm
└── CounterUpdateTest.elm
```

**`DecodeProductTest.elm`** (decoder feliz e falho)

```elm
module DecodeProductTest exposing (tests)

import Api.Decode as Decode
import Expect
import Json.Decode as D
import Test exposing (..)

tests : Test
tests =
    describe "Api.Decode.product"
        [ test "decodifica product válido" <|
            \_ ->
                let json = "{""id"":1,""name"":""A"",""price"":9.9,""image"":""/a.png"",""inStock"":true}"
                in
                case D.decodeString Decode.product json of
                    Ok p -> Expect.equal 1 (p.id |> \(Api.Types.ProductId n) -> n)
                    Err e -> Expect.fail (D.errorToString e)
        , test "rejeita product com price string" <|
            \_ ->
                let bad = "{""id"":1,""name"":""A"",""price"":""9.9"",""image"":""/a.png"",""inStock"":true}"
                in
                case D.decodeString Decode.product bad of
                    Ok _ -> Expect.fail "deveria falhar"
                    Err _ -> Expect.pass
        ]
```

**`CounterUpdateTest.elm`** (branch coverage em `update`)

```elm
module CounterUpdateTest exposing (tests)

import Expect
import Pages.Counter_ as C -- página sandbox gerada
import Test exposing (..)

tests : Test
tests =
    describe "Counter.update"
        [ test "+1" <|
            \_ ->
                let ( model0, _ ) = C.init ()
                    ( model1, _ ) = C.update C.Increment model0
                in Expect.equal 1 model1.count
        , test "-1" <|
            \_ ->
                let ( model0, _ ) = C.init ()
                    ( model1, _ ) = C.update C.Decrement model0
                in Expect.equal (-1) model1.count
        ]
```

> Regra: **todo novo decoder** e **todo novo branch não-trivial de****`update`** deve ter pelo menos um teste.

---

## 15) `elm-review` — preset recomendado

**Instalação**

```bash
elm install jfmengels/elm-review-config
npx elm-review --init jfmengels/elm-review-config --template jfmengels/elm-review-config/example
```

**Ativar regras úteis** (exemplos)

* `NoUnused.Variables`, `NoUnused.Exports`, `NoUnused.CustomTypeConstructors`
* `NoDebug.Log`, `NoDebug.Todo`
* `NoExposingEverything`
* `NoBooleanCase`, `NoImportingEverything`

> Política: PR só é aceito com **`elm-review`****limpo**.

---

## 16) Rotas e convenções

* Arquivos de rota **sempre** terminam com underscore: `Pages/Foo_.elm`.
* Use `elm-land routes` como **fonte de verdade** dos caminhos.
* **Segmentos dinâmicos**: prefira construir a string do caminho de forma tipada (ex.: usar `String.fromInt (unProductId id)` em helpers) e **centralizar** em um módulo `RoutePath.elm` para evitar "string solta".
* Links: componha via view library escolhida (ex.: `View.link [ View.href "/products/42" ] [ View.text "Ver" ]`).

---

## 17) Padrões de formulário (sem ports)

Esqueleto de formulário controlado (sandbox):

```elm
type alias Model = { name : String, saving : Bool }

type Msg = SetName String | Save | Saved (Result Http.Error ())

update msg m =
    case msg of
        SetName s -> ({ m | name = s }, Effect.none)
        Save -> ({ m | saving = True }, Effect.none) -- trocar por Effect HTTP quando integrar
        Saved (Ok _) -> ({ m | saving = False }, Effect.none)
        Saved (Err e) -> ({ m | saving = False }, Effect.none)

view m =
    View.column
        [ View.input [ View.value m.name, View.onInput SetName ] []
        , View.button [ View.disabled m.saving, View.onClick Save ] [ View.text "Salvar" ]
        ]
```

---

## 18) `Shared` — estado global com parcimônia

**Regra:** apenas informações realmente globais (ex.: sessão do usuário, carrinho, tema).

Passos mínimos:

1. `elm-land customize shared`
2. Em `Shared/Msg.elm`, declare mensagens como `AddToCart ProductId`.
3. Em páginas, **nunca** mutar globais diretamente: emita mensagens do `Shared` via APIs expostas.

---

## 19) Git e PR — padrão de equipe

* **Branches**: `feat/<escopo>`, `fix/<escopo>`, `chore/<escopo>`.
* **Conventional Commits** (exemplos):

  * `feat(cart): add AddToCart to Shared.Msg`
  * `fix(products): handle timeout as retriable error`
* **PR mínimo**:

  * Checklist passado (§13)
  * Escopo pequeno (≤150 linhas)
  * Descrição com mini‑plano e evidências (prints do `routes`, `elm-test`)

---

## 20) Deploy rápido

1. `elm-land build` → gera `./dist`
2. Sirva como **static site** (Nginx, Apache, GitHub Pages, Netlify, Vercel)
3. Para SPA com rotas limpas no servidor, garanta fallback para `index.html`.

---

## 21) Acessibilidade & UX (check rápido)

* Texto de botões **descritivo** (não "OK").
* Foco visível, navegação por teclado.
* `aria-label` para ícones sem texto.
* Evitar apenas cor para estados (erro/sucesso).

---

### Resumo final

* **Tudo começa e termina na CLI do Elm Land.**
* **Elm puro** resolve 90% dos casos com pacotes oficiais e arquitetura limpa (`Api/`, `Domain/`, `Lib/`).
* **Ports** são a fronteira mínima para o inevitável — e só.
* Ciclo de qualidade: `routes → format → review → test → build`.
