import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/user_settings.dart';

class SettingsRepository {
  final AppDatabase _appDb;

  SettingsRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  Future<UserSettings> getSettings() async {
    final db = await _db;
    final rows = await db.query('user_settings');
    if (rows.isEmpty) {
      // Default settings
      return const UserSettings();
    }

    final Map<String, dynamic> map = {};
    for (final r in rows) {
      final key = r['key'] as String;
      final val = r['value'] as String;

      if (key == 'is_24_hour' ||
          key == 'quiet_hours_enabled' ||
          key == 'is_compact_density' ||
          key == 'haptics_enabled' ||
          key == 'has_completed_onboarding' ||
          key == 'reduced_motion') {
        map[key] = val == '1' ? 1 : 0;
      } else if (key == 'custom_accent_color_value') {
        map[key] = int.tryParse(val);
      } else if (key == 'accent_color_index' ||
          key == 'first_day_of_week' ||
          key == 'default_event_duration_minutes' ||
          key == 'default_reminder_minutes_before') {
        map[key] = int.tryParse(val) ?? 0;
      } else {
        map[key] = val;
      }
    }

    return UserSettings.fromMap(map);
  }

  Future<void> saveSettings(UserSettings settings) async {
    final db = await _db;
    final map = settings.toMap();

    await db.transaction((txn) async {
      for (final entry in map.entries) {
        await txn.insert(
          'user_settings',
          {
            'key': entry.key,
            'value': entry.value?.toString() ?? '',
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    });
  }
}
