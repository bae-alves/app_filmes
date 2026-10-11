import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../data/api_models/watch_providers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../utils/tmdb_images.dart';

/// Mostra onde um filme pode ser assistido: logos dos serviços agrupados por
/// forma de acesso, link para a página do TMDB e o crédito da JustWatch.
///
/// É um widget "burro", como o `MovieCard`: recebe a [region] já escolhida e
/// não conhece repositório nem view model. Por isso serve tanto à tela de
/// detalhes quanto, no modo [compact], aos cards de recomendação da IA
/// (MOVIEAI-36).
///
/// Todos os textos vêm de [AppLocalizations]; o widget exige que o
/// `MaterialApp` tenha os delegates de tradução configurados.
class WatchProvidersSection extends StatelessWidget {
  const WatchProvidersSection({
    super.key,
    required this.region,
    this.compact = false,
  });

  /// Chave do aviso exibido quando o filme não está em nenhum serviço.
  static const unavailableKey = Key('watch-providers-unavailable');

  /// Chave do botão que abre a página "onde assistir" do TMDB.
  static const linkKey = Key('watch-providers-link');

  /// Disponibilidade no país do usuário. `null` significa que o filme não está
  /// em nenhum serviço ali — e é exibido como tal, não como erro.
  final WatchProviderRegion? region;

  /// Versão reduzida para cards: uma única fileira de logos menores, sem
  /// títulos de grupo, sem botão e sem crédito (o crédito fica a cargo da
  /// tela que hospeda os cards).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final region = this.region;
    if (region == null) return _Unavailable(compact: compact);

    // Ordem dos grupos: do mais acessível ao menos acessível para o usuário.
    final groups = [
      (l10n.watchProvidersSubscription, _sortedUnique([...?region.flatrate])),
      (l10n.watchProvidersFree, _sortedUnique([...?region.free, ...?region.ads])),
      (l10n.watchProvidersRent, _sortedUnique([...?region.rent])),
      (l10n.watchProvidersBuy, _sortedUnique([...?region.buy])),
    ].where((group) => group.$2.isNotEmpty);

    if (compact) {
      // Mantém a ordem dos grupos, mas cada serviço aparece uma vez só
      // (ex.: Apple TV costuma estar em "Alugar" e em "Comprar").
      final providers = _uniqueById([for (final g in groups) ...g.$2]);
      return _LogoWrap(providers: providers, size: 28);
    }

    final theme = Theme.of(context);
    final link = region.link == null ? null : Uri.tryParse(region.link!);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (label, providers) in groups) ...[
          Text(label, style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          _LogoWrap(providers: providers, size: 40),
          const SizedBox(height: 12),
        ],
        if (link != null)
          TextButton.icon(
            key: linkKey,
            // A API não fornece deep link por serviço: a página do TMDB lista
            // os links para cada um deles no país do usuário.
            onPressed: () =>
                launchUrl(link, mode: LaunchMode.externalApplication),
            icon: const Icon(LucideIcons.externalLink, size: 18),
            label: Text(l10n.watchProvidersSeeWhere),
          ),
        // Exigência dos termos de uso do TMDB para os dados de streaming.
        Text(
          l10n.watchProvidersAttribution,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
      ],
    );
  }

  /// Ordena pela prioridade sugerida pelo TMDB, sem repetir serviços — "Grátis"
  /// junta `free` e `ads`, e o mesmo serviço pode estar nas duas listas.
  static List<WatchProvider> _sortedUnique(List<WatchProvider> providers) =>
      _uniqueById(providers)
        ..sort((a, b) => (a.displayPriority ?? _lastPriority)
            .compareTo(b.displayPriority ?? _lastPriority));

  /// Remove serviços repetidos (mesmo `providerId`) preservando a ordem.
  static List<WatchProvider> _uniqueById(List<WatchProvider> providers) {
    final seen = <int?>{};
    return [
      for (final provider in providers)
        if (seen.add(provider.providerId)) provider,
    ];
  }

  /// Serviços sem prioridade informada vão para o fim da lista.
  static const _lastPriority = 1 << 30;
}

/// Fileira (com quebra de linha) de logos de serviços.
class _LogoWrap extends StatelessWidget {
  const _LogoWrap({required this.providers, required this.size});

  final List<WatchProvider> providers;

  /// Lado do logo, em pixels lógicos.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final provider in providers)
          _ProviderLogo(provider: provider, size: size),
      ],
    );
  }
}

/// Logo de um serviço, com o nome no tooltip e para leitores de tela.
///
/// Logos de marcas não existem no Lucide, por isso vêm do servidor de imagens
/// do TMDB; o ícone [LucideIcons.tv] só aparece se a imagem faltar ou falhar.
class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({required this.provider, required this.size});

  final WatchProvider provider;
  final double size;

  @override
  Widget build(BuildContext context) {
    final name = provider.providerName ?? '';
    final url = TmdbImages.logo(provider.logoPath);
    final fallback = Container(
      width: size,
      height: size,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(LucideIcons.tv, size: size / 2),
    );

    return Tooltip(
      message: name,
      child: Semantics(
        label: name,
        image: true,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 5),
          child: url == null
              ? fallback
              : Image.network(
                  url,
                  width: size,
                  height: size,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => fallback,
                ),
        ),
      ),
    );
  }
}

/// Aviso de que o filme não está em nenhum serviço na região do usuário.
class _Unavailable extends StatelessWidget {
  const _Unavailable({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.outline;
    return Row(
      key: WatchProvidersSection.unavailableKey,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(LucideIcons.monitorOff, size: compact ? 16 : 20, color: color),
        const SizedBox(width: 8),
        Flexible(
          child: Text(
            AppLocalizations.of(context).watchProvidersUnavailable,
            style: (compact
                    ? theme.textTheme.labelSmall
                    : theme.textTheme.bodyMedium)
                ?.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
