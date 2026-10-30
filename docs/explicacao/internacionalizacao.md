# Internacionalização

O app fala português e inglês. Três escolhas diferentes decidem o que o
usuário vê, e é fácil confundi-las.

## Idioma da interface, idioma do conteúdo e região

| Escolha | Decide | Vem de |
| --- | --- | --- |
| Idioma da interface | Textos do app: botões, títulos, avisos, formato de números | Idiomas preferidos do dispositivo, resolvidos pelo `MaterialApp` |
| Idioma do conteúdo | Título, sinopse, gêneros e trailer que o TMDB devolve | O mesmo idioma da interface, mapeado por `tmdbLanguages` |
| Região | Quais serviços aparecem em "onde assistir" | País da localidade do dispositivo |

Idioma e região andam separados de propósito. Quem mora em Portugal e usa o
app em inglês lê tudo em inglês, mas vê os serviços disponíveis em Portugal.
Os serviços dependem de onde a pessoa está, não da língua que ela lê.

Já os dois idiomas andam juntos. Se a interface estivesse em inglês e o
conteúdo em português, a mesma tela misturaria as duas línguas. Por isso
`tmdbLanguageFor` usa a mesma regra do `MaterialApp`
(`basicLocaleListResolution`) para escolher o idioma: os dois sempre
concordam, inclusive no caso de um dispositivo num idioma não suportado.

## Por que o gen-l10n

É a ferramenta oficial do Flutter. Os textos ficam em arquivos `.arb`, um
formato que tradutores e serviços de tradução conhecem. O código gerado dá
um método por chave, então uma chave errada é erro de compilação e não texto
faltando em produção. Plural e formato de número saem do `intl`, que conhece
as regras de cada idioma.

## Por que o português é o modelo

O time escreve em português e o app nasceu em português. O modelo é onde
cada chave nasce, com a descrição para quem traduz. Escrever primeiro na
língua do time evita que a descrição e o texto original saiam de uma tradução.

O arquivo é `app_pt.arb`, sem país: vale para qualquer variante de
português. Uma chave que falta em outro idioma aparece em português.

## Por que o inglês é o idioma reserva

Um dispositivo em espanhol, por exemplo, não tem tradução. O Flutter escolhe
o primeiro item de `supportedLocales`, que o gen-l10n gera em ordem
alfabética: `en`. O conteúdo segue a interface e vem em `en-US`, que é também
onde o TMDB costuma ter vídeos quando falta tradução — por isso o trailer usa
`en-US` como segunda tentativa.

## Por que o erro na tela não é a mensagem da exceção

O repositório descreve a falha para quem depura: "Falha ao carregar os
filmes populares (HTTP 401)". Essa frase é técnica e está em português. O
repositório não conhece o idioma da tela e não deveria conhecer.

Por isso cada tela mostra a sua própria mensagem traduzida ("Não foi
possível carregar os filmes."), e a view model manda a exceção para o log.
O usuário perde o código HTTP, que não o ajudaria, e o desenvolvedor o
encontra no console.

## Limitações conhecidas

- O idioma é lido uma vez, quando o app abre. Trocar o idioma do dispositivo
  só vale depois de reabrir o app (ou recarregar a página). A região é lida
  de novo a cada tela de detalhes aberta.
  Uma tela de preferências (MOVIEAI-8) deve tornar a escolha manual e
  imediata; o ponto de troca é `lib/utils/user_locale.dart`.
- O TMDB guarda dados diferentes por idioma. Título e sinopse são esperados,
  mas até a duração de um filme pode diferir entre `pt-BR` e `en-US`.
- Nem todo filme tem tradução no TMDB. Sem ela, o campo vem no idioma
  original ou vazio, e o app mostra "Sinopse não disponível."
- O nome do app ("App Filmes") não é traduzido.

## Veja também

- [Tutorial: crie um widget traduzido](../tutoriais/criar-um-widget-traduzido.md)
- [Como adicionar um texto traduzido](../guias/adicionar-um-texto-traduzido.md)
- [Como adicionar um idioma](../guias/adicionar-um-idioma.md)
- [Referência: configuração](../referencia/configuracao.md)
