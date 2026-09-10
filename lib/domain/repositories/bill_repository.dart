import 'package:sqflite/sqflite.dart';
import '../../core/database/app_database.dart';
import '../models/bill_item.dart';

class BillRepository {
  final AppDatabase _appDb;

  BillRepository([AppDatabase? appDb]) : _appDb = appDb ?? AppDatabase.instance;

  Future<Database> get _db => _appDb.database;

  Future<void> insertBill(BillItem bill) async {
    final db = await _db;
    await db.insert('bills', bill.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> updateBill(BillItem bill) async {
    final db = await _db;
    await db.update('bills', bill.toMap(), where: 'id = ?', whereArgs: [bill.id]);
  }

  Future<void> deleteBill(String id) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.delete('bill_payments', where: 'bill_id = ?', whereArgs: [id]);
      await txn.delete('bills', where: 'id = ?', whereArgs: [id]);
    });
  }

  Future<List<BillItem>> getAllActiveBills() async {
    final db = await _db;
    final rows = await db.query(
      'bills',
      where: 'is_archived = 0',
      orderBy: 'renewal_date ASC',
    );
    return rows.map((r) => BillItem.fromMap(r)).toList();
  }

  Future<List<BillItem>> getUpcomingBills(int daysAhead) async {
    final db = await _db;
    final now = DateTime.now();
    final targetDate = now.add(Duration(days: daysAhead));
    final targetDateStr = "${targetDate.year}-${targetDate.month.toString().padLeft(2, '0')}-${targetDate.day.toString().padLeft(2, '0')}";

    final rows = await db.query(
      'bills',
      where: 'is_archived = 0 AND is_paused = 0 AND renewal_date <= ?',
      whereArgs: [targetDateStr],
      orderBy: 'renewal_date ASC',
    );
    return rows.map((r) => BillItem.fromMap(r)).toList();
  }

  Future<void> recordPayment(String billId, String paidDate, double amount, String currency) async {
    final db = await _db;
    await db.transaction((txn) async {
      await txn.insert('bill_payments', {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'bill_id': billId,
        'paid_date': paidDate,
        'amount_paid': amount,
        'currency': currency,
      });

      // Advance the renewal date according to recurrence
      final billRows = await txn.query('bills', where: 'id = ?', whereArgs: [billId]);
      if (billRows.isNotEmpty) {
        final currentBill = BillItem.fromMap(billRows.first);
        final currentRenewal = DateTime.tryParse(currentBill.renewalDate) ?? DateTime.now();
        DateTime nextRenewal;

        switch (currentBill.recurrence.toLowerCase()) {
          case 'weekly':
            nextRenewal = currentRenewal.add(const Duration(days: 7));
            break;
          case 'yearly':
            nextRenewal = DateTime(currentRenewal.year + 1, currentRenewal.month, currentRenewal.day);
            break;
          case 'monthly':
          default:
            final nextMonth = currentRenewal.month == 12 ? 1 : currentRenewal.month + 1;
            final nextYear = currentRenewal.month == 12 ? currentRenewal.year + 1 : currentRenewal.year;
            // Handle day overflow for shorter months
            final daysInNextMonth = DateTime(nextYear, nextMonth + 1, 0).day;
            final day = currentRenewal.day > daysInNextMonth ? daysInNextMonth : currentRenewal.day;
            nextRenewal = DateTime(nextYear, nextMonth, day);
            break;
        }

        final nextRenewalStr = "${nextRenewal.year}-${nextRenewal.month.toString().padLeft(2, '0')}-${nextRenewal.day.toString().padLeft(2, '0')}";
        await txn.update(
          'bills',
          {'renewal_date': nextRenewalStr},
          where: 'id = ?',
          whereArgs: [billId],
        );
      }
    });
  }

  Future<List<BillPaymentRecord>> getPaymentHistory(String billId) async {
    final db = await _db;
    final rows = await db.query(
      'bill_payments',
      where: 'bill_id = ?',
      whereArgs: [billId],
      orderBy: 'paid_date DESC',
    );
    return rows.map((r) => BillPaymentRecord.fromMap(r)).toList();
  }

  Future<Map<String, double>> getUpcomingTotalsByCurrency() async {
    final db = await _db;
    final rows = await db.query(
      'bills',
      where: 'is_archived = 0 AND is_paused = 0',
    );

    final Map<String, double> totals = {};
    for (final r in rows) {
      final currency = r['currency'] as String? ?? 'INR';
      final amount = (r['amount'] as num).toDouble();
      totals[currency] = (totals[currency] ?? 0.0) + amount;
    }
    return totals;
  }
}
