import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayform/core/theme/app_theme.dart';
import 'package:dayform/domain/models/user_settings.dart';
import 'package:dayform/features/today/widgets/birthday_celebration_card.dart';
import 'package:dayform/features/today/widgets/editorial_date_header.dart';
import 'package:dayform/features/today/widgets/up_next_card.dart';

void main() {
  group('Dayform Widget Tests', () {
    testWidgets('EditorialDateHeader renders prominent weekday and date', (WidgetTester tester) async {
      final testDate = DateTime(2026, 9, 9); // Wednesday, 9 September

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: EditorialDateHeader(
              selectedDate: testDate,
              onReturnToToday: () {},
            ),
          ),
        ),
      );

      expect(find.text('Wednesday'), findsOneWidget);
      expect(find.text('9 September'), findsOneWidget);
    });

    testWidgets('UpNextCard renders serene empty state when no event', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: Scaffold(
            body: UpNextCard(
              event: null,
              onQuickAddEvent: () {},
              onEventTapped: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('UP NEXT'), findsOneWidget);
      expect(find.text('Clear horizon'), findsOneWidget);
      expect(find.text('Schedule event'), findsOneWidget);
    });

    testWidgets('BirthdayCelebrationCard renders personalized greeting and wishes', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: const Scaffold(
            body: BirthdayCelebrationCard(
              userName: 'Jordan',
            ),
          ),
        ),
      );

      expect(find.text('Happy Birthday, Jordan! ✨'), findsOneWidget);
      expect(find.text('🎉 SPECIAL DAY'), findsOneWidget);
      expect(find.text('🎂'), findsOneWidget);
    });

    test('UserSettings defaults to no pre-existing name and incomplete onboarding for new users', () {
      const settings = UserSettings();
      expect(settings.userName, isEmpty);
      expect(settings.userBirthDate, isNull);
      expect(settings.hasCompletedOnboarding, isFalse);
    });
  });
}

