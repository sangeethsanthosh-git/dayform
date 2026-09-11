import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dayform/core/constants/app_constants.dart';
import 'package:dayform/core/theme/app_colors.dart';
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
      expect(settings.accentColorIndex, 0);
      expect(settings.customAccentColorValue, isNull);
    });

    test('Universal accent color updates dynamically for presets and custom hex values', () {
      // 1. Classic Gold (Default index 0)
      AppColors.applyAccentFromSettings(const UserSettings(accentColorIndex: 0));
      expect(AppColors.warmAmber.value, const Color(0xFFE5BD78).value);

      // 2. Sapphire Blue (Preset index 1)
      AppColors.applyAccentFromSettings(const UserSettings(accentColorIndex: 1));
      expect(AppColors.warmAmber.value, const Color(0xFF3B82F6).value);

      // 3. Emerald Green (Preset index 2)
      AppColors.applyAccentFromSettings(const UserSettings(accentColorIndex: 2));
      expect(AppColors.warmAmber.value, const Color(0xFF10B981).value);

      // 4. Custom Universal Color (e.g. Deep Orange 0xFFFF5722)
      const customVal = 0xFFFF5722;
      AppColors.applyAccentFromSettings(
        const UserSettings(customAccentColorValue: customVal),
      );
      expect(AppColors.warmAmber.value, customVal);

      // 5. Revert back to Gold
      AppColors.applyAccentFromSettings(const UserSettings(accentColorIndex: 0));
      expect(AppColors.warmAmber.value, const Color(0xFFE5BD78).value);
    });

    test('Notification tones are properly configured and serializable', () {
      expect(AppConstants.notificationTones.length, 6);
      expect(AppConstants.getToneOption('chime').title, 'Classic Chime');
      expect(AppConstants.getToneOption('bell').rawSoundName, 'reminder_bell');
      expect(AppConstants.getToneOption('marimba').rawSoundName, 'reminder_marimba');
      expect(AppConstants.getToneOption('electronic').rawSoundName, 'reminder_electronic');
      expect(AppConstants.getToneOption('zen').rawSoundName, 'reminder_zen');
      expect(AppConstants.getToneOption('system').rawSoundName, isNull);

      const settings = UserSettings(notificationTone: 'bell');
      final map = settings.toMap();
      expect(map['notification_tone'], 'bell');

      final restored = UserSettings.fromMap(map);
      expect(restored.notificationTone, 'bell');
    });
  });
}

