# Dicionário

Nosso projeto é um dicionário para descrição de uma língua ainda não documentada.

- Sempre escrever código limpo, DRY, YAGNI, KISS, SOLID, seguindo boas práticas de programação funcional.
- Sempre escrever código idiomático para a linguagem usada (Elm no frontend, Haskell no backend). NUNCA traduzir ao pé da letra padrões de outras linguagens. Haskell e Elm são linguagens funcionais com paradigmas diferentes de linguagens imperativas/OO.
- Nunca criar código muito indentado. Sempre preferir funções auxiliares, composição de funções; quando necessário, uso de `let`/`where` para evitar níveis excessivos de indentação.
- Sempre documentar o código de forma clara e concisa, utilizando comentários e documentação apropriada para facilitar a compreensão e manutenção.
- Sempre realizar testes automatizados para garantir a qualidade e o funcionamento correto do código. E sempre ter certeza de que os testes estão corretos e completos.
- Nunca deixar código "morto" ou não utilizado. Sempre remover código que não é mais necessário.

## Estrutura

LER COM ATENÇÃO O CONTEÚDO DE CADA ARQUIVO.

- ./project/elm_elmland/elm_programming_strategies.md: Estratégias de programação em Elm.
- ./project/elm_elmland/about_elm.md: links com recursos sobre Elm.

Nosso projeto utiliza Elm no frontend e Haskell no backend.

./frontend/... - código do frontend em Elm.
./backend/... - código do backend em Haskell.
./project/... - informações do projeto.

O frontend usa o dialeto elm-land 0.20.1 do elm.
O backend usa Haskell rodando com cabal por meio do ghcup (GHC 9.10.2)

## Conteúdo do projeto

- ./project/planejamento/API.md: Documentação da API.
- ./project/planejamento/dicionario.yaml: Esquemas e definições da API do dicionário.
- ./project/planejamento/UX.md: Documentação da experiência do usuário.
