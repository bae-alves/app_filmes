/// Localidade do usuário: de qual país ele acessa e em que idioma o conteúdo
/// do TMDB deve vir.
///
/// São duas perguntas diferentes, e por isso duas funções:
///
/// - **região** ([currentWatchRegion]) decide quais serviços de streaming
///   aparecem. Vem do país do dispositivo, qualquer que seja o idioma.
/// - **idioma do conteúdo** ([currentTmdbLanguage]) decide em que idioma o
///   TMDB devolve título, sinopse, gêneros e trailer. Segue o idioma que a
///   interface usa, para que textos do app e do TMDB nunca se misturem.
///
/// Ambas são lidas uma vez, no `main.dart`. Trocar o idioma ou o país do
/// dispositivo só vale depois que o app reinicia (na web, ao recarregar a
/// página). Quando existir a tela de preferências (MOVIEAI-8), a escolha
/// manual do usuário deve entrar aqui.
library;

import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/widgets.dart';

import '../data/services/tmdb_rest_client.dart';
import '../l10n/app_localizations.dart';

/// País do usuário, usado para consultar onde o filme pode ser assistido.
///
/// Vem da localidade do **dispositivo** (ou do navegador, na web), e não do
/// idioma em que o app está sendo exibido: quem mora em Portugal e usa o app
/// em inglês continua vendo os serviços disponíveis em `PT`. Quando a
/// localidade não informa país (ex.: navegador configurado só com `en`), cai
/// para [tmdbFallbackWatchRegion].
String currentWatchRegion() {
  final country = PlatformDispatcher.instance.locale.countryCode;
  return (country == null || country.isEmpty) ? tmdbFallbackWatchRegion : country;
}

/// Idioma em que o conteúdo do TMDB deve ser pedido, para o dispositivo atual.
///
/// Atalho para [tmdbLanguageFor] com os idiomas preferidos do dispositivo.
String currentTmdbLanguage() =>
    tmdbLanguageFor(PlatformDispatcher.instance.locales);

/// Idioma do TMDB (ex.: `pt-BR`) correspondente aos idiomas preferidos
/// [deviceLocales], em ordem de preferência.
///
/// Usa a mesma regra do `MaterialApp` (`basicLocaleListResolution` contra
/// `AppLocalizations.supportedLocales`) para escolher o idioma da interface, e
/// então o traduz pelo mapa [tmdbLanguages]. Assim a interface e o conteúdo
/// sempre concordam: um dispositivo em espanhol vê a interface em inglês (o
/// primeiro idioma suportado) e recebe o conteúdo em `en-US`.
String tmdbLanguageFor(List<Locale> deviceLocales) {
  final appLocale = basicLocaleListResolution(
    deviceLocales,
    AppLocalizations.supportedLocales,
  );
  return tmdbLanguages[appLocale.languageCode] ?? tmdbFallbackLanguage;
}
