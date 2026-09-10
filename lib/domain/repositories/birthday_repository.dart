import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/birthday_item.dart';

class BirthdayRepository {
  final AppDatabase _appDb;

  BirthdayRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  Future<void> insertBirthday(BirthdayItem birthday) async {
    final db = await _db;
    await db.insert('birthdays', birthday.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBirthday(BirthdayItem birthday) async {
    final db = await _db;
    await db.update('birthdays', birthday.toMap(), where: 'id = ?', whereArgs: [birthday.id]);
  }

  Future<void> deleteBirthday(String id) async {
    final db = await _db;
    await db.delete('birthdays', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<BirthdayItem>> getAllBirthdays() async {
    final db = await _db;
    final rows = await db.query('birthdays', orderBy: 'person_name ASC');
    return rows.map((r) => BirthdayItem.fromMap(r)).toList();
  }

  // Get birthdays occurring in a specific calendar month
  Future<List<BirthdayItem>> getBirthdaysForMonth(int month) async {
    final all = await getAllBirthdays();
    final monthStr = month.toString().padLeft(2, '0');

    return all.where((b) {
      final parts = b.birthDate.split('-');
      if (parts.length == 3) {
        return parts[1] == monthStr; // YYYY-MM-DD
      } else if (parts.length == 2) {
        return parts[0] == monthStr; // MM-DD
      }
      return false;
    }).toList();
  }

  // Get birthdays occurring on a specific date (day and month)
  Future<List<BirthdayItem>> getBirthdaysForDay(int month, int day) async {
    final monthBirthdays = await getBirthdaysForMonth(month);
    final dayStr = day.toString().padLeft(2, '0');

    return monthBirthdays.where((b) {
      final parts = b.birthDate.split('-');
      if (parts.length == 3) {
        return parts[2] == dayStr;
      } else if (parts.length == 2) {
        return parts[1] == dayStr;
      }
      return false;
    }).toList();
  }
}
