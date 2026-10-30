# Avaliações

O usuário avalia os filmes que já assistiu: uma nota de 1 a 5, uma reação de
humor, ou as duas. A seção "Sua avaliação" fica na tela de detalhes, logo
abaixo da sinopse. Esta página explica as escolhas por trás dela.

## Para que servem

As avaliações vão alimentar o algoritmo de recomendação (os cards da IA,
MOVIEAI-36). Ele ainda não existe. Por isso a avaliação hoje só é guardada e
mostrada de volta, e nenhuma tela as lista.

## Nota e humor separados

A nota diz o quanto o usuário gostou. O humor diz como o filme o fez se
sentir: dois filmes de nota 5 podem ser um "Divertido" e um "Tenso". O
algoritmo pode usar os dois sinais.

Os dois são opcionais e independentes. Dá para marcar só o humor, sem nota.
Tocar de novo na nota ou no humor marcado o desmarca. Sem nenhum dos dois, a
avaliação é apagada.

Os humores são `Mood.loved` (😍 Amei), `funny` (😂 Divertido), `moved`
(😢 Emocionante), `tense` (😱 Tenso) e `bored` (😴 Entediante). O ticket não
fixava a lista; ela foi escolhida para cobrir reações que a nota não
captura. O banco guarda o nome do valor (`tense`), não o texto: trocar o
texto ou o emoji é só mexer na UI. Renomear ou tirar um valor faz quem já o
escolheu ficar sem humor, sem erro.

## Onde ficam

No mesmo banco SQLite dos favoritos (`AppDatabase`), na tabela `ratings`,
que entrou na versão 2 do esquema. Quem já tinha o app ganha a tabela na
atualização, sem perder os favoritos. Os motivos do SQLite local são os
mesmos dos [favoritos](favoritos.md#por-que-sqlite-no-aparelho), e também o
plano para quando houver login: o endpoint da conta, com o SQLite como cache.

A tabela guarda só o id do filme, a nota, o humor e a data. Os favoritos
guardam o resumo do filme para abrir a lista sem rede; as avaliações não
têm lista. O algoritmo busca no TMDB o que precisar do filme (gêneros, por
exemplo).

## Uma view model por tela

A `MovieRatingViewModel` é criada para cada tela de detalhes, por uma
fábrica do `main.dart` que passa pela home e pelos favoritos, como a
`MovieDetailsViewModel`. Ela fica separada da view model dos detalhes: a
avaliação é dado do usuário no aparelho, os detalhes vêm do TMDB, e cada uma
falha e é testada por conta própria.

## Veja também

- [Referência: repositório](../referencia/repositorio.md#ratingsrepository)
- [Favoritos](favoritos.md)
