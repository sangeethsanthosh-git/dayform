import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../navigation/main_scaffold.dart';
import '../onboarding/onboarding_screen.dart';

class SplashScreen extends StatefulWidget {
  final AppState appState;

  const SplashScreen({super.key, required this.appState});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
    _scheduleNavigation();
  }

  void _scheduleNavigation() {
    Timer(const Duration(milliseconds: 1400), () {
      _checkAndNavigate();
    });
  }

  void _checkAndNavigate() {
    if (!mounted || _hasNavigated) return;

    if (widget.appState.isLoading) {
      // If still loading state, check again shortly
      Timer(const Duration(milliseconds: 200), _checkAndNavigate);
      return;
    }

    _hasNavigated = true;
    final Widget destination = widget.appState.settings.hasCompletedOnboarding
        ? MainScaffold(appState: widget.appState)
        : OnboardingScreen(appState: widget.appState);

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (context, animation, secondaryAnimation) => destination,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final titleColor = isDark ? AppColors.primaryLightText : AppColors.primaryDarkText;
    final subtitleColor = isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText;

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // App Icon Emblem
                  Container(
                    width: 104,
                    height: 104,
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: AppColors.warmAmber.withOpacity(0.35),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.warmAmber.withOpacity(isDark ? 0.15 : 0.08),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(
                      'assets/icons/app_icon.png',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Center(
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 48,
                            color: AppColors.warmAmber,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Brand Title
                  Text(
                    AppConstants.appName,
                    style: TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      color: titleColor,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Serene Tagline
                  Text(
                    'Your day, thoughtfully arranged',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 48),

                  // Subtle amber loader
                  SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.warmAmber),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
