# Documentação do app_filmes

A documentação segue o [Diátaxis](https://diataxis.fr/): quatro tipos de
texto, cada um para uma necessidade diferente.

| Tipo | Para quando você quer… | Pasta |
| --- | --- | --- |
| Tutorial | aprender fazendo, do começo ao fim | [`tutoriais/`](tutoriais/) |
| Guia | resolver uma tarefa que você já entende | [`guias/`](guias/) |
| Referência | consultar um fato: parâmetro, constante, arquivo | [`referencia/`](referencia/) |
| Explicação | entender por que algo é como é | [`explicacao/`](explicacao/) |

## Tutoriais

- [Crie um widget traduzido](tutoriais/criar-um-widget-traduzido.md)

## Guias

- [Configurar o ambiente](guias/configurar-o-ambiente.md)
- [Adicionar um texto traduzido](guias/adicionar-um-texto-traduzido.md)
- [Adicionar um idioma](guias/adicionar-um-idioma.md)
- [Adicionar um endpoint do TMDB](guias/adicionar-um-endpoint-do-tmdb.md)
- [Verificar uma mudança no app de verdade](guias/verificar-no-app.md)

## Referência

- [Configuração](referencia/configuracao.md): `.env`, constantes, traduções, `pubspec.yaml`
- [Repositório](referencia/repositorio.md): métodos, cache, o que `null` significa
- [Telas e widgets](referencia/widgets.md): parâmetros, chaves de teste, formatadores
- [Testes](referencia/testes.md): arquivos, fakes e fixtures

## Explicação

- [Arquitetura](explicacao/arquitetura.md)
- [Plataformas](explicacao/plataformas.md)
- [Internacionalização](explicacao/internacionalizacao.md)
- [Onde assistir](explicacao/onde-assistir.md)
- [Favoritos](explicacao/favoritos.md): por que SQLite local, e o que muda com login

## Onde colocar um texto novo

- Ensina, passo a passo, alguém que está começando? **Tutorial.** Todo passo
  precisa funcionar; rode o tutorial inteiro antes de publicar.
- Responde "como eu faço X?" para quem já conhece o projeto? **Guia.**
- Descreve algo que existe no código, sem opinião? **Referência.** Atualize
  junto com o código.
- Responde "por quê?"? **Explicação.**

Não misture os tipos num mesmo arquivo: ligue um ao outro com links.

Escreva em português, com frases curtas e voz ativa.
