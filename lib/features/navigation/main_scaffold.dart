import 'package:flutter/material.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../calendar/calendar_screen.dart';
import '../myspace/myspace_screen.dart';
import '../quick_add/quick_add_sheet.dart';
import '../tasks/tasks_screen.dart';
import '../today/today_screen.dart';

class MainScaffold extends StatefulWidget {
  final AppState appState;

  const MainScaffold({super.key, required this.appState});

  @override
  State<MainScaffold> createState() => _MainScaffoldState();
}

class _MainScaffoldState extends State<MainScaffold> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Default opening screen preference
    switch (widget.appState.settings.defaultOpeningScreen.toLowerCase()) {
      case 'calendar':
        _currentIndex = 1;
        break;
      case 'tasks':
        _currentIndex = 2;
        break;
      case 'myspace':
        _currentIndex = 3;
        break;
      case 'today':
      default:
        _currentIndex = 0;
        break;
    }
  }

  void _onNavigateToTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final pages = [
      TodayScreen(appState: widget.appState, onNavigateToTab: _onNavigateToTab),
      CalendarScreen(appState: widget.appState, onNavigateToTab: _onNavigateToTab),
      TasksScreen(appState: widget.appState),
      MySpaceScreen(appState: widget.appState),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
              width: 0.8,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          elevation: 0,
          backgroundColor: Colors.transparent,
          indicatorColor: AppColors.warmAmber.withOpacity(0.25),
          onDestinationSelected: (index) {
            setState(() => _currentIndex = index);
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.wb_sunny_outlined),
              selectedIcon: Icon(Icons.wb_sunny_rounded, color: AppColors.warmAmberForeground),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.calendar_month_outlined),
              selectedIcon: Icon(Icons.calendar_month_rounded, color: AppColors.warmAmberForeground),
              label: 'Calendar',
            ),
            NavigationDestination(
              icon: Icon(Icons.check_box_outlined),
              selectedIcon: Icon(Icons.check_box_rounded, color: AppColors.warmAmberForeground),
              label: 'Tasks',
            ),
            NavigationDestination(
              icon: Icon(Icons.grid_view_outlined),
              selectedIcon: Icon(Icons.grid_view_rounded, color: AppColors.warmAmberForeground),
              label: 'My Space',
            ),
          ],
        ),
      ),
      // Golden Amber Floating (+) Action Button (Image 2 style)
      floatingActionButton: _currentIndex != 1
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (_) => QuickAddSheet(appState: widget.appState),
                );
              },
              backgroundColor: AppColors.warmAmber,
              foregroundColor: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: const Icon(Icons.add_rounded, size: 28),
            )
          : null,
    );
  }
}
