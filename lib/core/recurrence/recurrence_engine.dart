import '../../domain/models/event_item.dart';
import '../../domain/models/recurrence_rule.dart';

class GeneratedOccurrence {
  final EventItem event;
  final String originalDate; // YYYY-MM-DD
  final bool isException;

  const GeneratedOccurrence({
    required this.event,
    required this.originalDate,
    this.isException = false,
  });
}

class RecurrenceEngine {
  /// Expands a recurring event across a query window [rangeStart, rangeEnd]
  static List<GeneratedOccurrence> expandEvent({
    required EventItem baseEvent,
    required RecurrenceRule rule,
    required List<RecurrenceException> exceptions,
    required DateTime rangeStart,
    required DateTime rangeEnd,
  }) {
    final List<GeneratedOccurrence> results = [];
    final exceptionMap = {for (final e in exceptions) e.originalDate: e};

    final baseStart = baseEvent.startDateTime;
    final duration = baseEvent.endDateTime.difference(baseStart);

    DateTime current = DateTime(baseStart.year, baseStart.month, baseStart.day);
    int occurrenceCounter = 0;

    // Safety limit to avoid infinite loops
    const maxIterations = 730; // 2 years of daily bounds
    int loopCount = 0;

    while (current.isBefore(rangeEnd) && loopCount < maxIterations) {
      loopCount++;

      if (rule.endDate != null && current.isAfter(rule.endDate!)) {
        break;
      }
      if (rule.occurrenceCount != null && occurrenceCounter >= rule.occurrenceCount!) {
        break;
      }

      final dateStr = _formatDate(current);

      // Check if current date matches recurrence pattern
      final matches = _matchesPattern(current, baseStart, rule);

      if (matches) {
        occurrenceCounter++;

        // Check if date falls in query window
        if (!current.isBefore(rangeStart)) {
          final exception = exceptionMap[dateStr];

          if (exception != null && exception.isCancelled) {
            // Cancelled occurrence - skip!
          } else {
            // Compute event times
            final eventStart = DateTime(
              current.year,
              current.month,
              current.day,
              baseStart.hour,
              baseStart.minute,
            );
            final eventEnd = eventStart.add(duration);

            if (exception != null) {
              // Apply exception overrides
              final overriddenEvent = baseEvent.copyWith(
                id: '${baseEvent.id}_$dateStr',
                title: exception.modifiedTitle ?? baseEvent.title,
                startDateTime: exception.modifiedStartDateTime ?? eventStart,
                endDateTime: exception.modifiedEndDateTime ?? eventEnd,
                dateOnly: dateStr,
              );
              results.add(GeneratedOccurrence(
                event: overriddenEvent,
                originalDate: dateStr,
                isException: true,
              ));
            } else {
              final instanceEvent = baseEvent.copyWith(
                id: '${baseEvent.id}_$dateStr',
                startDateTime: eventStart,
                endDateTime: eventEnd,
                dateOnly: dateStr,
              );
              results.add(GeneratedOccurrence(
                event: instanceEvent,
                originalDate: dateStr,
                isException: false,
              ));
            }
          }
        }
      }

      // Step current date forward
      current = _stepForward(current, rule, baseStart);
    }

    return results;
  }

  static bool _matchesPattern(DateTime current, DateTime baseStart, RecurrenceRule rule) {
    if (current.isBefore(DateTime(baseStart.year, baseStart.month, baseStart.day))) {
      return false;
    }

    switch (rule.frequency.toLowerCase()) {
      case 'daily':
        return true;
      case 'weekdays':
        return current.weekday >= DateTime.monday && current.weekday <= DateTime.friday;
      case 'weekly':
        if (rule.daysOfWeek.isNotEmpty) {
          return rule.daysOfWeek.contains(current.weekday);
        }
        return current.weekday == baseStart.weekday;
      case 'monthly':
        final targetDay = rule.monthDay ?? baseStart.day;
        final daysInCurrentMonth = DateTime(current.year, current.month + 1, 0).day;
        final clampedDay = targetDay > daysInCurrentMonth ? daysInCurrentMonth : targetDay;
        return current.day == clampedDay;
      case 'yearly':
        if (baseStart.month == 2 && baseStart.day == 29) {
          // Leap day handling: on non-leap years, falls on Feb 28
          final isLeapYear = (current.year % 4 == 0 && (current.year % 100 != 0 || current.year % 400 == 0));
          if (!isLeapYear) {
            return current.month == 2 && current.day == 28;
          }
        }
        return current.month == baseStart.month && current.day == baseStart.day;
      default:
        return true;
    }
  }

  static DateTime _stepForward(DateTime current, RecurrenceRule rule, DateTime baseStart) {
    switch (rule.frequency.toLowerCase()) {
      case 'daily':
      case 'weekdays':
      case 'weekly':
        // For daily / weekdays / weekly with daysOfWeek, we step day by day
        return current.add(Duration(days: rule.frequency == 'daily' ? rule.interval : 1));
      case 'monthly':
        final nextMonth = current.month + rule.interval;
        final nextYear = current.year + (nextMonth - 1) ~/ 12;
        final normalizedMonth = ((nextMonth - 1) % 12) + 1;
        return DateTime(nextYear, normalizedMonth, 1);
      case 'yearly':
        final nextYear = current.year + rule.interval;
        final daysInNextMonth = DateTime(nextYear, baseStart.month + 1, 0).day;
        final clampedDay = baseStart.day > daysInNextMonth ? daysInNextMonth : baseStart.day;
        return DateTime(nextYear, baseStart.month, clampedDay);
      default:
        return current.add(const Duration(days: 1));
    }
  }

  static String _formatDate(DateTime dt) {
    return "${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}";
  }
}
