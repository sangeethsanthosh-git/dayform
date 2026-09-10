import 'package:flutter/material.dart';
import 'core/constants/app_constants.dart';
import 'core/state/app_state.dart';
import 'core/theme/app_theme.dart';
import 'features/settings/settings_screen.dart';
import 'features/splash/splash_screen.dart';

class DayformApp extends StatelessWidget {
  final AppState appState;

  const DayformApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        ThemeMode themeMode;
        switch (appState.settings.themeMode.toLowerCase()) {
          case 'light':
            themeMode = ThemeMode.light;
            break;
          case 'dark':
            themeMode = ThemeMode.dark;
            break;
          case 'system':
          default:
            themeMode = ThemeMode.system;
            break;
        }

        return AppStateProvider(
          appState: appState,
          child: MaterialApp(
            title: AppConstants.appName,
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeMode,
            home: SplashScreen(appState: appState),
          ),
        );
      },
    );
  }
}
