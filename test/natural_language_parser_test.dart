import 'package:flutter_test/flutter_test.dart';
import 'package:dayform/features/quick_add/parser/natural_language_parser.dart';

void main() {
  group('NaturalLanguageParser Tests', () {
    test('parses "Submit assignment tomorrow at 6 pm"', () {
      final parsed = NaturalLanguageParser.parse('Submit assignment tomorrow at 6 pm');

      expect(parsed.title.toLowerCase(), contains('submit assignment'));
      expect(parsed.category, equals('study'));
      expect(parsed.detectedType, equals('task'));
      expect(parsed.timeString, equals('18:00'));

      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      expect(parsed.date.day, equals(tomorrow.day));
      expect(parsed.date.month, equals(tomorrow.month));
    });

    test('parses "Gym workout tomorrow at 7:30 am"', () {
      final parsed = NaturalLanguageParser.parse('Gym workout tomorrow at 7:30 am');

      expect(parsed.title.toLowerCase(), contains('gym workout'));
      expect(parsed.category, equals('health'));
      expect(parsed.timeString, equals('07:30'));
    });

    test('parses "Pay internet bill"', () {
      final parsed = NaturalLanguageParser.parse('Pay internet bill');

      expect(parsed.category, equals('finance'));
      expect(parsed.title.toLowerCase(), contains('pay internet bill'));
    });
  });
}
