import 'package:app_filmes/data/api_models/watch_providers.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  WatchProvider provider(int id, {int? priority}) => WatchProvider(
        providerId: id,
        providerName: 'Serviço $id',
        displayPriority: priority,
      );

  List<int?> ids(List<WatchProvider> providers) =>
      [for (final p in providers) p.providerId];

  group('groups', () {
    test('segue a ordem assinatura, grátis, aluguel e compra', () {
      final region = WatchProviderRegion(
        buy: [provider(4)],
        rent: [provider(3)],
        free: [provider(2)],
        flatrate: [provider(1)],
      );

      expect([for (final g in region.groups) g.access], [
        WatchProviderAccess.subscription,
        WatchProviderAccess.free,
        WatchProviderAccess.rent,
        WatchProviderAccess.buy,
      ]);
    });

    test('junta free e ads em grátis, sem repetir serviço', () {
      final region = WatchProviderRegion(
        free: [provider(1, priority: 1)],
        ads: [provider(1, priority: 1), provider(2, priority: 2)],
      );

      final free = region.groups.single;
      expect(free.access, WatchProviderAccess.free);
      expect(ids(free.providers), [1, 2]);
    });

    test('ordena pela prioridade do TMDB, sem prioridade no fim', () {
      final region = WatchProviderRegion(flatrate: [
        provider(1),
        provider(2, priority: 9),
        provider(3, priority: 2),
      ]);

      expect(ids(region.groups.single.providers), [3, 2, 1]);
    });

    test('omite as formas de acesso sem serviço', () {
      final region = WatchProviderRegion(flatrate: const [], rent: [provider(1)]);

      expect([for (final g in region.groups) g.access],
          [WatchProviderAccess.rent]);
    });
  });

  test('uniqueProviders mantém a ordem dos grupos e mostra cada serviço uma vez',
      () {
    final region = WatchProviderRegion(
      flatrate: [provider(1)],
      rent: [provider(2), provider(3)],
      buy: [provider(2)],
    );

    expect(ids(region.uniqueProviders), [1, 2, 3]);
  });
}
