import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_constants.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../navigation/main_scaffold.dart';

class OnboardingScreen extends StatefulWidget {
  final AppState appState;

  const OnboardingScreen({super.key, required this.appState});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _nameController = TextEditingController();
  DateTime? _selectedBirthDate;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initialDate = _selectedBirthDate ?? DateTime(2000, 1, 1);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'SELECT YOUR DATE OF BIRTH',
      builder: (context, child) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Theme(
          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedBirthDate = picked;
      });
    }
  }

  Future<void> _completeOnboarding() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your name to personalize your experience.';
      });
      return;
    }

    String? birthDateStr;
    if (_selectedBirthDate != null) {
      birthDateStr =
          "${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}";

      // Clean up legacy milestone item if present
      await widget.appState.deleteBirthday('user_birthday_primary');

      // Schedule notification reminder for user's birthday
      await NotificationService.instance.scheduleBirthdayReminder(
        id: 999999,
        personName: 'You! 🎂 Happy Birthday, $name',
        birthDate: _selectedBirthDate!,
        daysBefore: 0,
      );
    }

    final updated = widget.appState.settings.copyWith(
      userName: name,
      userBirthDate: birthDateStr,
      hasCompletedOnboarding: true,
    );
    await widget.appState.updateSettings(updated);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 500),
          pageBuilder: (context, animation, secondaryAnimation) =>
              MainScaffold(appState: widget.appState),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBg = isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Top Theme Toggle Action
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    onPressed: () {
                      final newMode = isDark ? 'light' : 'dark';
                      widget.appState.updateSettings(
                        widget.appState.settings.copyWith(themeMode: newMode),
                      );
                    },
                    icon: Icon(
                      isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                      color: isDark ? AppColors.warmAmber : AppColors.primaryDarkText,
                      size: 22,
                    ),
                    tooltip: isDark ? 'Switch to Light Mode' : 'Switch to Dark Mode',
                    style: IconButton.styleFrom(
                      backgroundColor: cardBg,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // 3D Emblem Header
                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.12),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),

                // Welcome Heading
                Text(
                  'Welcome to Dayform',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                    color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Let’s personalize your daily journey & milestones.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                ),
                const SizedBox(height: 28),

                // Setup Card
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Name Field
                      Text(
                        'What should we call you?',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _nameController,
                        textCapitalization: TextCapitalization.words,
                        cursorColor: AppColors.warmAmber,
                        onChanged: (_) {
                          if (_errorMessage != null) {
                            setState(() => _errorMessage = null);
                          }
                        },
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Enter your name',
                          hintStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: isDark
                                ? AppColors.secondaryLightText.withOpacity(0.7)
                                : AppColors.secondaryDarkText.withOpacity(0.7),
                          ),
                          prefixIcon: Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: isDark ? AppColors.warmAmber : AppColors.secondaryDarkText,
                          ),
                          filled: true,
                          fillColor: isDark ? AppColors.darkSurfaceMuted : const Color(0xFFF7F6F2),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: AppColors.warmAmber,
                              width: 1.8,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // 2. Birthday Field
                      Text(
                        'Your Date of Birth',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.primaryLightText : AppColors.primaryDarkText,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GestureDetector(
                        onTap: _pickBirthDate,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurfaceMuted : const Color(0xFFF7F6F2),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: _selectedBirthDate != null
                                  ? AppColors.warmAmber
                                  : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                              width: _selectedBirthDate != null ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.cake_outlined,
                                size: 20,
                                color: _selectedBirthDate != null
                                    ? AppColors.warmAmber
                                    : (isDark ? AppColors.warmAmber.withOpacity(0.8) : AppColors.secondaryDarkText),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _selectedBirthDate != null
                                      ? DateFormat('d MMMM yyyy').format(_selectedBirthDate!)
                                      : 'Tap to select birthdate (Optional)',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: _selectedBirthDate != null
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                    color: _selectedBirthDate != null
                                        ? (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText)
                                        : (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText),
                                  ),
                                ),
                              ),
                              Icon(
                                Icons.calendar_month_rounded,
                                size: 18,
                                color: isDark ? AppColors.warmAmber : AppColors.secondaryDarkText,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.celebration_rounded,
                            size: 14,
                            color: isDark ? AppColors.warmAmber : AppColors.warmAmberForeground,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "We'll remember your special day and wish you a wonderful birthday! 🎂",
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                              ),
                            ),
                          ),
                        ],
                      ),

                      if (_errorMessage != null) ...[
                        const SizedBox(height: 14),
                        Text(
                          _errorMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.redAccent,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // Begin Journey Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _completeOnboarding,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDark ? AppColors.warmAmber : AppColors.pillBlack,
                      foregroundColor: isDark ? AppColors.pillBlack : Colors.white,
                      elevation: isDark ? 0 : 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Begin My Journey',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.2,
                            color: isDark ? AppColors.pillBlack : Colors.white,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: isDark ? AppColors.pillBlack : Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
