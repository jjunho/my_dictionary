# Dicionário Linguístico — instruções rápidas

Este repositório contém:

- `frontend/` — código do frontend em Elm (projeto gerado por Elm Land)
- `backend/` — código do backend em Haskell (hpack/cabal)
- `project/` — documentação e planejamento (API, UX, schemas)

Requisitos básicos

- Node.js (para ferramentas do frontend/elm-land)
- elm-land v0.20.1 (instalado globalmente ou via npx)
- ghcup (recomendado) + GHC 9.10.2 + cabal-install (para Haskell)

Rodando o frontend (Elm Land)

```zsh
cd frontend
# se tiver elm-land global
elm-land server
# ou com npx (quando não instalado globalmente)
npx elm-land server
```

Rodando o backend (cabal)

```zsh
cd backend
# compilar
cabal v2-build all
# executar (nome do executável conforme backend/backend.cabal)
cabal v2-run backend-exe
```

Alternativa (Stack)

```zsh
cd backend
stack setup
stack build
stack run
```

Notas

- A documentação da API, esquemas e UX estão em `project/`.
- Se houver problemas de toolchain Haskell, instale GHC/cabal via `ghcup`.
 
Git hooks

This repository includes a lightweight hooks directory at `.githooks/` containing a `pre-commit` script that runs a few fast checks (elm-format validation, `hlint` on `backend/`, and a quick `cabal` dependency build).

To enable these hooks locally for your clone run:

```zsh
# from repo root
git config core.hooksPath .githooks
```

Make sure you have `elm-format`, `hlint`, and `cabal` installed for the checks to run. The hook is intentionally conservative (it skips checks if tools are missing).