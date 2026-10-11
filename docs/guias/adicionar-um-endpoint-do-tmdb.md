# Como adicionar um endpoint do TMDB

O caminho de um dado novo, da API até a view model. Exemplo:
`/movie/{movie_id}/credits` (elenco).

## 1. Modele a resposta

Crie `lib/data/api_models/<nome>.dart` no estilo de `video.dart`:

```dart
import 'package:json_annotation/json_annotation.dart';

part 'movie_credits.g.dart';

/// Envelope devolvido por `/movie/{movie_id}/credits`.
///
/// Referência: https://developer.themoviedb.org/reference/movie-credits
@JsonSerializable(fieldRename: FieldRename.snake)
class MovieCredits {
  const MovieCredits({this.id, this.cast});

  factory MovieCredits.fromJson(Map<String, dynamic> json) =>
      _$MovieCreditsFromJson(json);

  final int? id;
  final List<CastMember>? cast;

  Map<String, dynamic> toJson() => _$MovieCreditsToJson(this);
}
```

Deixe todos os campos anuláveis: o TMDB omite campos sem aviso.

## 2. Declare o endpoint no service

Em `lib/data/services/tmdb_rest_client.dart`:

```dart
  @GET('/movie/{movie_id}/credits')
  Future<HttpResponse<MovieCredits>> getMovieCredits(
    @Path('movie_id') int movieId, {
    @Query('language') required String language,
  });
```

Se o endpoint devolve texto, `language` é obrigatório e sem valor padrão.
Devolva `HttpResponse<T>`: o repositório confere o status antes de usar o
corpo.

## 3. Gere o código

```sh
dart run build_runner build --delete-conflicting-outputs
```

## 4. Adicione o método ao repositório

No contrato `lib/data/repositories/movies_repository.dart`:

```dart
  /// Elenco do filme [movieId].
  Future<Result<MovieCredits>> getMovieCredits(int movieId);
```

Em `movies_repository_remote.dart`, copie a forma de `getMovieDetails`:

- chame o service com `language: _language`;
- confira `_isSuccess(response.response.statusCode)`;
- devolva `Result.error(_httpException(...))` ou
  `Result.error(_asException(...))` nas falhas;
- adicione um cache em `Map` só se o dado não muda durante o uso.

## 5. Atualize os fakes

O analisador aponta os dois:

- `test/fakes/fake_tmdb_rest_client.dart`: implemente o método, registre
  `language` em `requestedLanguages` e chame `_maybeThrow()`.
- `test/fakes/fake_movies_repository.dart`: um campo com o resultado por id e
  um campo de erro, como `trailersById` e `trailerError`.

Adicione dados de exemplo em `test/fakes/movie_fixtures.dart`.

## 6. Teste o repositório

Em `test/data/repositories/movies_repository_remote_test.dart`, cubra no
mínimo: sucesso, status HTTP de erro, falha de rede e o idioma enviado.

## 7. Use na view model

Chame o repositório na view model da tela e trate os dois ramos do `Result`
com `switch`. Se a falha não impede a tela de funcionar, faça como o trailer
em `MovieDetailsViewModel.load`: guarde `null` e mande o erro para o
`debugPrint`.

## Veja também

- [Referência: repositório](../referencia/repositorio.md)
- [Explicação: arquitetura](../explicacao/arquitetura.md)
