import 'package:app_filmes/data/services/app_database.dart';
import 'package:app_filmes/main.dart';
import 'package:app_filmes/ui/view/home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  setUpAll(sqfliteFfiInit);

  // A chave da Gemini só serve ao chat. Sem ela o app ainda precisa abrir na
  // home, como no CI e em quem só tem as credenciais do TMDB.
  testWidgets('o app abre na home sem a chave da Gemini no .env', (
    tester,
  ) async {
    dotenv.loadFromString(envString: 'TMDB_READ=fake\nTMDB_API_KEY=fake\n');
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final database = await tester.runAsync(
      () => AppDatabase.open(
        factory: databaseFactoryFfi,
        path: inMemoryDatabasePath,
      ),
    );
    addTearDown(() => tester.runAsync(database!.close));

    await tester.pumpWidget(
      AppFilmes(preferences: preferences, database: database!),
    );

    expect(tester.takeException(), isNull);
    expect(find.byType(HomePage), findsOneWidget);

    // A home já pediu filmes ao TMDB e favoritos ao SQLite. Deixa as duas
    // terminarem antes de desmontar a árvore, para nada chegar depois.
    await tester.runAsync(() => Future<void>.delayed(Duration(seconds: 1)));
    await tester.pumpAndSettle();
  });
}
