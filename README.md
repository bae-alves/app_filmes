# app_filmes

Aplicativo Flutter que lista os filmes populares do
[TMDB](https://developer.themoviedb.org/docs/getting-started) e abre uma tela
de detalhes com o trailer, as informações de cada filme e onde assisti-lo.
Os filmes podem ser salvos numa lista de favoritos e avaliados com nota e
humor, tudo guardado no aparelho.
Roda em Android e na web, em português e em inglês.

## Começo rápido

```sh
cp .env.example .env          # preencha TMDB_READ e TMDB_API_KEY
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run -d chrome
```

Detalhes em [Configurar o ambiente](docs/guias/configurar-o-ambiente.md).

## Testes

```sh
flutter analyze
flutter test
```

Os testes rodam offline, com fakes no lugar do TMDB. Veja a
[referência de testes](docs/referencia/testes.md).

## Documentação

Toda a documentação está em [`docs/`](docs/README.md):

- **Tutorial:** [crie um widget traduzido](docs/tutoriais/criar-um-widget-traduzido.md)
- **Guias:** configurar o ambiente, adicionar textos, idiomas e endpoints,
  verificar no app
- **Referência:** configuração, repositório, widgets, testes
- **Explicação:** [arquitetura](docs/explicacao/arquitetura.md),
  plataformas, [internacionalização](docs/explicacao/internacionalizacao.md),
  onde assistir, [favoritos](docs/explicacao/favoritos.md),
  [avaliações](docs/explicacao/avaliacoes.md)

## Estrutura

```
lib/
├── data/
│   ├── api_models/     # modelos do JSON do TMDB (json_serializable)
│   ├── repositories/   # MoviesRepository, FavoritesRepository e RatingsRepository (contratos + implementações)
│   └── services/       # TmdbRestClient (retrofit), Dio e o banco SQLite (AppDatabase)
├── l10n/               # textos traduzidos (.arb) e AppLocalizations gerado
├── ui/
│   ├── view/           # telas e widgets
│   └── view_model/     # estado das telas (ChangeNotifier)
├── utils/              # Result, Env, localidade do usuário, formatadores
└── main.dart           # composição das dependências
docs/                   # documentação (Diátaxis)
test/                   # testes e fakes
```
