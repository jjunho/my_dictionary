# Haskell Playbook — mapeamento do Playbook Elm Land

Este documento traduz os princípios do `project/elm_elmland/elm_programming_strategy.md` para práticas operacionais e recomendações para o backend Haskell do projeto.

Resumo rápido

- Prioridade: CLI-first, pequenas mudanças verificáveis, testes e linter/format no CI.
- Ferramentas recomendadas: ghcup, cabal/stack, ormolu (ou brittany), hlint, hspec, QuickCheck, hedgehog.
- JSON: Aeson com encoders/decoders bem tipados e testes de round-trip.

1. Filosofia e regras transversais

- Small diffs & commits semânticos: siga Conventional Commits (feat/fix/chore/docs/chore/dev). Faça commits pequenos e testáveis.
- CLI-first: prefira tarefas via ferramenta (cabal/stack) e scripts (Makefile/dev scripts) em vez de edições manuais de artefatos gerados.
- Testes obrigatórios: novos decoders/encoders ou mudanças de API exigem testes unitários e, quando aplicável, property tests (QuickCheck).
- Remova código morto; use `hlint` para detectar padrões suspeitos.

2. Projeto e estrutura recomendada

Raiz do backend (`backend/`):

- `app/` — executáveis (ex.: `Main.hs`) que ligam a aplicação (servidor web).
- `src/` — código da biblioteca (módulos `Api`, `Domain`, `Store`, `Web.Server`, `Web.Handler`).
- `test/` — testes HSpec / QuickCheck.
- `backend.cabal` ou `package.yaml` (hpack) para descrição do pacote.

3. Formatação e lint

- Formatter: `ormolu` (ou `brittany`/`stylish-haskell`). Execute antes do commit:

  ormolu --mode inplace -r src app test

- Linter: `hlint` com regras de equipe. Exemplo de uso:

  hlint src || true

Crie `backend/hlint.yaml` com regras específicas do time (sugerir fixes automáticos somente quando seguro).

4. Testes

- Unit tests: `hspec` para handlers, parsers, e lógica de domínio.
- Property tests: `QuickCheck` ou `hedgehog` para invariantes (round-trip JSON, idempotência de import/export, ordenação estável de cursors).
- Test runner:

  cabal v2-test --test-show-details=direct

Estrutura de testes mínima (`test/Spec.hs`): agregador HSpec que roda todos os módulos de teste.

5. API & JSON (Aeson)

- Defina tipos explícitos e `ToJSON`/`FromJSON` manuais quando houver regras (p.ex. ULID, datas RFC3339). Teste round-trip e casos de erro.
- Use `aeson` + `aeson-schemas` ou validação adicional quando necessário.

6. Concurrency, ETag e idempotência

- Para updates use ETag + `If-Match` semanticamente (Servant/Warp: ler header e validar). Teste cenários de conflito e responses RFC7807 para erros estruturados.
- Para import em massa (NDJSON) use job/operation pattern (aceitar `202 Accepted` + `Operation-Location`). Teste reexecução idempotente.

7. CI (recomendado)

- GitHub Actions pipeline (exemplo mínimo):
  - Setup GHC via ghcup or actions/setup-haskell
  - `cabal v2-build all` (ou `stack build`)
  - Run `hlint` (fail on issues) and `ormolu` check
  - `cabal v2-test` (run hspec / quickcheck)
  - Frontend checks: `npx elm-format --validate .`, `npx elm-review`, `npx elm-test`, `elm-land build`

8. Dev ergonomics

- Scripts: `Makefile` + `scripts/dev.sh` (já presentes) para `make frontend`, `make backend`, `make dev`.
- Use `ghcup` para padronizar GHC/cabal localmente nos desenvolvedores.

9. Review checklist (PR)

- Compila e passa em `cabal v2-build`.
- Testes unitários passam (`cabal v2-test`).
- `hlint` sem avisos relevantes.
- Código formatado com `ormolu`.
- Mudanças de API documentadas e migradas (se necessário) e contratos JSON testados.

10. Exemplos de comandos úteis

```zsh
# instalar/usar ghcup
curl --proto '=https' --tlsv1.2 -sSf https://get-ghcup.haskell.org | sh

# build & test
cd backend
cabal v2-build all
cabal v2-test --test-show-details=direct

# lint/format
hlint src
ormolu --mode inplace -r src app test
```

11. Próximos passos sugeridos (baixo risco)

- Adicionar `backend/hlint.yaml` e `test/Spec.hs` com skeleton HSpec.
- Incluir workflow CI em `.github/workflows/ci.yml` que execute os checks acima.
- Scaffoldar um endpoint Servant `/api/v1/lexemes` com teste HSpec de integração leve.

---

Este playbook é um ponto de partida. Posso aplicar automaticamente os itens de baixo risco (adicionar `hlint` config, `test/Spec.hs` e o workflow CI) se quiser — diga qual passo quer primeiro.
