import 'package:flutter_test/flutter_test.dart';
import 'package:dayform/core/recurrence/recurrence_engine.dart';
import 'package:dayform/domain/models/event_item.dart';
import 'package:dayform/domain/models/recurrence_rule.dart';

void main() {
  group('RecurrenceEngine Tests', () {
    test('expands daily recurrence correctly', () {
      final baseEvent = EventItem(
        id: 'event_1',
        title: 'Daily Standup',
        startDateTime: DateTime(2026, 9, 1, 9, 0),
        endDateTime: DateTime(2026, 9, 1, 9, 30),
        dateOnly: '2026-09-01',
        category: 'work',
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      const rule = RecurrenceRule(
        id: 'rule_1',
        frequency: 'daily',
        interval: 1,
        parentEntityType: 'event',
        parentEntityId: 'event_1',
      );

      final occurrences = RecurrenceEngine.expandEvent(
        baseEvent: baseEvent,
        rule: rule,
        exceptions: [],
        rangeStart: DateTime(2026, 9, 1),
        rangeEnd: DateTime(2026, 9, 6),
      );

      expect(occurrences.length, equals(5));
      expect(occurrences.first.originalDate, equals('2026-09-01'));
      expect(occurrences.last.originalDate, equals('2026-09-05'));
    });

    test('handles occurrence exception cancellation', () {
      final baseEvent = EventItem(
        id: 'event_1',
        title: 'Daily Standup',
        startDateTime: DateTime(2026, 9, 1, 9, 0),
        endDateTime: DateTime(2026, 9, 1, 9, 30),
        dateOnly: '2026-09-01',
        category: 'work',
        createdAt: DateTime(2026, 9, 1),
        updatedAt: DateTime(2026, 9, 1),
      );

      const rule = RecurrenceRule(
        id: 'rule_1',
        frequency: 'daily',
        interval: 1,
        parentEntityType: 'event',
        parentEntityId: 'event_1',
      );

      // Cancel occurrence on 2026-09-03
      const exception = RecurrenceException(
        id: 'exc_1',
        recurrenceRuleId: 'rule_1',
        originalDate: '2026-09-03',
        isCancelled: true,
      );

      final occurrences = RecurrenceEngine.expandEvent(
        baseEvent: baseEvent,
        rule: rule,
        exceptions: [exception],
        rangeStart: DateTime(2026, 9, 1),
        rangeEnd: DateTime(2026, 9, 5),
      );

      final dates = occurrences.map((o) => o.originalDate).toList();
      expect(dates, contains('2026-09-01'));
      expect(dates, contains('2026-09-02'));
      expect(dates, isNot(contains('2026-09-03'))); // Cancelled!
      expect(dates, contains('2026-09-04'));
    });

    test('handles leap year Feb 29 recurrence on non-leap years', () {
      final baseEvent = EventItem(
        id: 'leap_event',
        title: 'Leap Day Anniversary',
        startDateTime: DateTime(2024, 2, 29, 12, 0),
        endDateTime: DateTime(2024, 2, 29, 13, 0),
        dateOnly: '2024-02-29',
        category: 'personal',
        createdAt: DateTime(2024, 2, 29),
        updatedAt: DateTime(2024, 2, 29),
      );

      const rule = RecurrenceRule(
        id: 'rule_leap',
        frequency: 'yearly',
        interval: 1,
        parentEntityType: 'event',
        parentEntityId: 'leap_event',
      );

      // 2025 is NOT a leap year -> should map to Feb 28
      final occurrences = RecurrenceEngine.expandEvent(
        baseEvent: baseEvent,
        rule: rule,
        exceptions: [],
        rangeStart: DateTime(2025, 2, 1),
        rangeEnd: DateTime(2025, 3, 1),
      );

      expect(occurrences.length, equals(1));
      expect(occurrences.first.originalDate, equals('2025-02-28'));
    });
  });
}
