import 'package:sqflite/sqflite.dart';

import '../../utils/result.dart';
import '../models/user_onboarding_preferences.dart';
import '../services/app_database.dart';

abstract interface class OnboardingRepository {
  Future<Result<UserOnboardingPreferences>> getPreferences(String userId);
  Future<Result<void>> savePreferences(UserOnboardingPreferences preferences);
}

class OnboardingRepositoryLocal implements OnboardingRepository {
  OnboardingRepositoryLocal({required Database database}) : _db = database;

  final Database _db;

  @override
  Future<Result<UserOnboardingPreferences>> getPreferences(
    String userId,
  ) async {
    try {
      final rows = await _db.query(
        AppDatabase.onboardingTable,
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      if (rows.isEmpty) {
        return Result.ok(
          UserOnboardingPreferences(
            userId: userId,
            genres: [],
            actors: [],
            directors: [],
            isCompleted: false,
          ),
        );
      }

      return Result.ok(UserOnboardingPreferences.fromMap(rows.first));
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }

  @override
  Future<Result<void>> savePreferences(
    UserOnboardingPreferences preferences,
  ) async {
    try {
      await _db.insert(
        AppDatabase.onboardingTable,
        preferences.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return const Result.ok(null);
    } catch (e) {
      return Result.error(e is Exception ? e : Exception(e.toString()));
    }
  }
}
