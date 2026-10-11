import 'dart:ui' show PlatformDispatcher;

import '../data/services/tmdb_rest_client.dart';

/// País do usuário, usado para consultar onde o filme pode ser assistido.
///
/// Vem da localidade do **dispositivo** (ou do navegador, na web), e não do
/// idioma em que o app está sendo exibido: quem mora em Portugal e usa o app
/// em inglês continua vendo os serviços disponíveis em `PT`. Quando a
/// localidade não informa país (ex.: navegador configurado só com `en`), cai
/// para [tmdbFallbackWatchRegion].
///
/// É o único ponto do app que decide a região. Quando existir uma tela de
/// preferências (MOVIEAI-8), a escolha manual do usuário deve entrar aqui.
String currentWatchRegion() {
  final country = PlatformDispatcher.instance.locale.countryCode;
  return (country == null || country.isEmpty) ? tmdbFallbackWatchRegion : country;
}
