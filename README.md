# Dicionário Linguístico

Este projeto é um dicionário colaborativo para descrição de uma língua não documentada.

## Estrutura

- `frontend/` - Código do frontend em Elm (elm-land 0.20.1)
- `backend/` - Código do backend em Haskell (cabal, GHC 9.10.2)
- `project/` - Documentação e planejamento do projeto

## Setup

### Dependências

- Elm 0.19.1
- Elm Land 0.20.1
- Haskell com ghcup (GHC 9.10.2) e cabal

### Frontend

```bash
cd frontend
elm-land server
```

### Backend

```bash
cd backend
cabal build
cabal run linguistic-dictionary-backend
```

## Documentação

Ver `project/` para detalhes da API, UI e estratégias de programação.