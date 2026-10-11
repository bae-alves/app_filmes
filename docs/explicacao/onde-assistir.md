# Onde assistir

A tela de detalhes mostra em quais serviços o filme está disponível no país
do usuário. Esta página explica de onde vêm os dados e por que a seção
funciona como funciona.

## De onde vêm os dados

Do endpoint
[`/movie/{id}/watch/providers`](https://developer.themoviedb.org/reference/movie-watch-providers)
do TMDB, que repassa dados da JustWatch. A JustWatch não tem API pública, e
os termos do TMDB exigem dar o crédito a ela. Por isso a seção termina com
"Fonte: JustWatch".

## Por que agrupar por forma de acesso

O TMDB separa os serviços em listas: assinatura, grátis, grátis com anúncios,
aluguel e compra. Para o usuário, a pergunta é "quanto vou pagar para ver
isso?". A seção mostra os grupos do mais acessível ao menos acessível e junta
grátis com anúncios em "Grátis". Um mesmo serviço pode aparecer em "Alugar" e
em "Comprar": são ofertas diferentes.

## Por que não há link para cada serviço

O TMDB não fornece deep link por serviço. Há um link por país, para a página
"onde assistir" do próprio TMDB, que leva a cada serviço. O botão "Ver onde
assistir" e os logos dos serviços abrem essa página. Links diretos exigiriam uma parceria paga com a
JustWatch.

## Por que guardar todos os países

A resposta do TMDB traz todos os países de uma vez, sem parâmetro de região.
O repositório guarda a resposta inteira por filme e só escolhe o país na
saída. Se a região do usuário mudar, a resposta já está em memória.

## Por que uma falha não aparece como "indisponível"

Se a consulta falhar, a seção diz que não foi possível carregar, e não que o
filme não está em nenhum serviço: seria um falso negativo. Não há botão de
tentar de novo, porque a seção é secundária. Reabrir a tela já tenta de novo,
já que o repositório não guarda a falha em cache.

## Por que existe o modo compacto

Os cards de recomendação da IA (MOVIEAI-36) vão mostrar onde assistir em
pouco espaço. O modo `compact` da `WatchProvidersSection` mostra só os logos,
cada serviço uma vez, sem rótulos. Quando os cards existirem, basta usar o
widget.

## Veja também

- [Referência: telas e widgets](../referencia/widgets.md#watchproviderssection)
- [Internacionalização: idioma × região](internacionalizacao.md)
