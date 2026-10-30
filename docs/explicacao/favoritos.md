# Favoritos

O usuário salva filmes numa lista de favoritos (watchlist) para ver depois.
O coração na barra da tela de detalhes adiciona e remove o filme. O coração
da tela inicial abre a lista. Esta página explica onde a lista é guardada e
por quê.

## Por que SQLite no aparelho

O app ainda não tem login. Sem conta, não há onde guardar a lista fora do
aparelho, então ela vai para um banco SQLite local (`AppDatabase`, tabela
`favorites`). Ela sobrevive ao fechamento do app.

O cache de detalhes usa o `shared_preferences`, mas a lista de favoritos não
é cache: é dado do usuário, cresce sem limite e é lida em ordem. Uma tabela
atende melhor e já tem o formato que um endpoint vai querer.

No Android, o banco é um arquivo do app. Na web, o SQLite roda em
WebAssembly e fica salvo no IndexedDB do navegador. Veja
[Plataformas](plataformas.md).

## Por que guardar o resumo, e não só o id

Cada linha guarda o mesmo resumo que a listagem do TMDB devolve: título,
pôster, nota, ano. Assim a tela de favoritos abre sem nenhuma requisição,
mesmo sem internet, e usa o mesmo `MovieCard` da tela inicial. O preço é que
o resumo pode ficar desatualizado (a nota muda). A tela de detalhes sempre
busca os dados atuais, e favoritar de novo atualiza o resumo.

## Quando houver login

Com autenticação, a lista deve ser salva **também** num endpoint da conta do
usuário, para acompanhá-lo em outros aparelhos. O SQLite local continua: ele
vira o cache da lista.

- A tela abre com o que está no aparelho, na hora e sem rede.
- Favoritar grava no SQLite e envia ao endpoint por trás. Se a rede falhar,
  a mudança fica marcada como pendente e é reenviada depois.
- Ao entrar na conta, a lista local se junta à lista da conta: nada que o
  usuário salvou antes do login se perde.

A UI depende só do contrato `FavoritesRepository`. A sincronização entra numa
nova implementação (por exemplo, uma `FavoritesRepositorySynced` que usa a
local e um service HTTP) trocada no `main.dart`. Nenhuma tela muda. A tabela
provavelmente vai precisar de uma coluna de "pendente de envio", que entra
como uma nova versão do esquema em `AppDatabase`.

## Veja também

- [Referência: repositório](../referencia/repositorio.md#favoritesrepository)
- [Arquitetura](arquitetura.md)
