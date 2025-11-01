# Backend (Haskell)

Este diretório contém o esqueleto do backend em Haskell. O projeto foi inicializado com ferramentas Haskell (hpack/cabal). Use uma das toolchains abaixo para compilar e executar:

Requisitos recomendados

- ghcup (para instalar GHC e cabal-install)
- GHC 9.10.2 (recomendado conforme `PROJECT.md`) ou compatível
- cabal-install (v3.x+)

Executando com cabal (recomendado)

```zsh
cd backend
# registrar o ambiente (opcional)
# ghcup install ghc 9.10.2
# ghcup set ghc 9.10.2

# atualizar lista de pacotes e compilar
cabal v2-build all

# executar o executável gerado (nome do executable conforme .cabal)
cabal v2-run backend-exe
```

Executando com Stack (alternativa)

Se preferir `stack`:

```zsh
cd backend
stack setup
stack build
stack run
```

Notas

- Se o build falhar por dependências, instale GHC/cabal via `ghcup` e rode `cabal v2-build` novamente.
- O arquivo principal do executável está em `app/Main.hs`. O código de biblioteca está em `src/`.
- Consulte `backend/backend.cabal` para detalhes do pacote e nomes dos executáveis.
# backend
