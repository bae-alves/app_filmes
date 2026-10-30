import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

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
    this.onOpenLink,
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

  /// Chamado com a página "onde assistir" do TMDB quando o usuário toca num
  /// logo ou no botão. Quem decide como abrir é a tela. `null` deixa os logos
  /// sem toque e esconde o botão.
  final ValueChanged<Uri>? onOpenLink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final region = this.region;
    if (region == null) return _Unavailable(compact: compact);

    if (compact) {
      return _LogoWrap(providers: region.uniqueProviders, size: 28);
    }

    final theme = Theme.of(context);
    final link = region.link == null ? null : Uri.tryParse(region.link!);
    // A API não fornece deep link por serviço: a página do TMDB lista os links
    // para cada um deles no país do usuário. Logos e botão abrem essa página.
    final onOpenLink = this.onOpenLink;
    final openLink = link == null || onOpenLink == null
        ? null
        : () => onOpenLink(link);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final (:access, :providers) in region.groups) ...[
          Text(_label(access, l10n), style: theme.textTheme.labelLarge),
          const SizedBox(height: 6),
          _LogoWrap(providers: providers, size: 40, onTap: openLink),
          const SizedBox(height: 12),
        ],
        if (openLink != null)
          TextButton.icon(
            key: linkKey,
            onPressed: openLink,
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

  static String _label(WatchProviderAccess access, AppLocalizations l10n) =>
      switch (access) {
        WatchProviderAccess.subscription => l10n.watchProvidersSubscription,
        WatchProviderAccess.free => l10n.watchProvidersFree,
        WatchProviderAccess.rent => l10n.watchProvidersRent,
        WatchProviderAccess.buy => l10n.watchProvidersBuy,
      };
}

/// Fileira (com quebra de linha) de logos de serviços.
class _LogoWrap extends StatelessWidget {
  const _LogoWrap({required this.providers, required this.size, this.onTap});

  final List<WatchProvider> providers;

  /// Chamado ao tocar em qualquer logo. `null` deixa os logos sem toque.
  final VoidCallback? onTap;

  /// Lado do logo, em pixels lógicos.
  final double size;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final provider in providers)
          _ProviderLogo(provider: provider, size: size, onTap: onTap),
      ],
    );
  }
}

/// Logo de um serviço, com o nome no tooltip e para leitores de tela.
///
/// Logos de marcas não existem no Lucide, por isso vêm do servidor de imagens
/// do TMDB; o ícone [LucideIcons.tv] só aparece se a imagem faltar ou falhar.
class _ProviderLogo extends StatelessWidget {
  const _ProviderLogo({
    required this.provider,
    required this.size,
    this.onTap,
  });

  final WatchProvider provider;
  final double size;
  final VoidCallback? onTap;

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
        button: onTap != null,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(size / 5),
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
