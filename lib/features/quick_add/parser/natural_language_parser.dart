class ParsedQuickEntry {
  final String title;
  final DateTime date;
  final String? timeString; // HH:mm
  final String category;
  final String detectedType; // 'event', 'task', 'reminder'

  const ParsedQuickEntry({
    required this.title,
    required this.date,
    this.timeString,
    required this.category,
    this.detectedType = 'task',
  });
}

class NaturalLanguageParser {
  static ParsedQuickEntry parse(String input) {
    String cleanText = input.trim();
    final now = DateTime.now();
    DateTime targetDate = DateTime(now.year, now.month, now.day);
    String? timeStr;
    String category = 'personal';
    String detectedType = 'task';

    final lower = cleanText.toLowerCase();

    // 1. Detect Category & Type hints
    if (lower.contains('assignment') || lower.contains('exam') || lower.contains('study') || lower.contains('read') || lower.contains('revision')) {
      category = 'study';
      detectedType = 'task';
    } else if (lower.contains('workout') || lower.contains('gym') || lower.contains('run') || lower.contains('walk') || lower.contains('meditate')) {
      category = 'health';
      detectedType = 'task';
    } else if (lower.contains('meeting') || lower.contains('sync') || lower.contains('handoff') || lower.contains('standup') || lower.contains('client')) {
      category = 'work';
      detectedType = 'event';
    } else if (lower.contains('bill') || lower.contains('pay') || lower.contains('subscription') || lower.contains('rent')) {
      category = 'finance';
      detectedType = 'task';
    } else if (lower.contains('birthday') || lower.contains('party') || lower.contains('dinner')) {
      category = 'social';
      detectedType = 'event';
    }

    // 2. Detect Date keywords
    if (lower.contains('tomorrow')) {
      targetDate = targetDate.add(const Duration(days: 1));
      cleanText = cleanText.replaceAll(RegExp(r'\btomorrow\b', caseSensitive: false), '');
    } else if (lower.contains('today')) {
      cleanText = cleanText.replaceAll(RegExp(r'\btoday\b', caseSensitive: false), '');
    } else {
      final weekdays = {
        'monday': DateTime.monday,
        'tuesday': DateTime.tuesday,
        'wednesday': DateTime.wednesday,
        'thursday': DateTime.thursday,
        'friday': DateTime.friday,
        'saturday': DateTime.saturday,
        'sunday': DateTime.sunday,
      };

      for (final entry in weekdays.entries) {
        final regex = RegExp('\\b(next\\s+)?${entry.key}\\b', caseSensitive: false);
        if (regex.hasMatch(cleanText)) {
          int daysToAdd = (entry.value - now.weekday + 7) % 7;
          if (daysToAdd == 0) daysToAdd = 7; // Next occurrence
          targetDate = targetDate.add(Duration(days: daysToAdd));
          cleanText = cleanText.replaceAll(regex, '');
          break;
        }
      }
    }

    // 3. Detect Time (e.g. "at 6 pm", "6:30 pm", "10am", "at 18:00")
    final timeRegex = RegExp(r'\b(?:at\s+)?(\d{1,2})(?::(\d{2}))?\s*(am|pm)?\b', caseSensitive: false);
    final match = timeRegex.firstMatch(cleanText);
    if (match != null) {
      int hour = int.parse(match.group(1)!);
      final int minute = match.group(2) != null ? int.parse(match.group(2)!) : 0;
      final String? ampm = match.group(3)?.toLowerCase();

      if (ampm != null) {
        if (ampm == 'pm' && hour < 12) hour += 12;
        if (ampm == 'am' && hour == 12) hour = 0;
        timeStr = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
        cleanText = cleanText.replaceFirst(match.group(0)!, '');
      } else if (match.group(0)!.toLowerCase().startsWith('at ') || match.group(2) != null) {
        // Explicit "at 14" or "14:30"
        timeStr = "${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}";
        cleanText = cleanText.replaceFirst(match.group(0)!, '');
      }
    }

    // Clean remaining title
    final title = cleanText
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'^\s*at\s+', caseSensitive: false), '')
        .trim();

    return ParsedQuickEntry(
      title: title.isEmpty ? input.trim() : title,
      date: targetDate,
      timeString: timeStr,
      category: category,
      detectedType: detectedType,
    );
  }
}
