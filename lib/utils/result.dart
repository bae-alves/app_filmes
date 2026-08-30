/// Resultado de uma operação que pode falhar.
///
/// É o tipo de retorno dos repositórios (camada de dados). Ao invés de deixar
/// exceções vazarem para a UI, o erro vira um valor: quem consome precisa
/// tratar explicitamente os dois casos.
///
/// Como a classe é `sealed`, o compilador verifica a exaustividade do `switch`
/// — esquecer de tratar [Ok] ou [Error] vira erro de compilação.
///
/// ```dart
/// switch (await repository.getPopularMovies()) {
///   case Ok<List<Movie>>(:final value):
///     // ...
///   case Error<List<Movie>>(:final error):
///     // ...
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Cria um resultado de sucesso carregando [value].
  const factory Result.ok(T value) = Ok<T>._;

  /// Cria um resultado de falha carregando [error].
  const factory Result.error(Exception error) = Error<T>._;
}

/// Ramo de sucesso de [Result].
final class Ok<T> extends Result<T> {
  const Ok._(this.value);

  /// Valor produzido pela operação.
  final T value;

  @override
  String toString() => 'Result<$T>.ok($value)';
}

/// Ramo de falha de [Result].
final class Error<T> extends Result<T> {
  const Error._(this.error);

  /// Exceção que descreve a falha.
  final Exception error;

  @override
  String toString() => 'Result<$T>.error($error)';
}
