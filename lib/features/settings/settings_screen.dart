import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/backup/backup_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/services/widget_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Obtain appState from Inherited or nearest Provider/state
    final appState = AppStateProvider.of(context);
    final settings = appState.settings;
    if (_nameController.text.isEmpty && settings.userName.isNotEmpty) {
      _nameController.text = settings.userName;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings & Preferences'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // 1. Profile & Name
          _buildSectionHeader('PROFILE'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor: AppColors.warmAmber.withOpacity(0.3),
                      child: Text(
                        settings.userName.isNotEmpty ? settings.userName[0].toUpperCase() : 'U',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.warmAmberForeground),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Display Name'),
                        onChanged: (val) {
                          appState.updateSettings(settings.copyWith(userName: val.trim()));
                        },
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cake_outlined, color: AppColors.warmAmber),
                  title: const Text('Date of Birth'),
                  subtitle: Text(
                    settings.userBirthDate != null
                        ? DateFormat('d MMMM yyyy').format(DateTime.parse(settings.userBirthDate!))
                        : 'Not set (Tap to choose)',
                    style: TextStyle(
                      color: settings.userBirthDate != null
                          ? (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText)
                          : Colors.grey,
                    ),
                  ),
                  trailing: const Icon(Icons.calendar_today_rounded, size: 18),
                  onTap: () async {
                    DateTime initial = settings.userBirthDate != null
                        ? DateTime.parse(settings.userBirthDate!)
                        : DateTime(2000, 1, 1);
                    final isDark = Theme.of(context).brightness == Brightness.dark;
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: initial,
                      firstDate: DateTime(1900),
                      lastDate: DateTime.now(),
                      builder: (context, child) {
                        return Theme(
                          data: isDark ? AppTheme.darkTheme : AppTheme.lightTheme,
                          child: child!,
                        );
                      },
                    );
                    if (picked != null) {
                      final str =
                          "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                      appState.updateSettings(settings.copyWith(userBirthDate: str));
                      NotificationService.instance.scheduleBirthdayReminder(
                        id: 999999,
                        personName: 'You! 🎂 Happy Birthday, ${settings.userName}',
                        birthDate: picked,
                        daysBefore: 0,
                      );
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 2. Appearance & Theme
          _buildSectionHeader('APPEARANCE'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                // Theme Mode Segmented (Full Width - No Overflow)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Theme Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: SegmentedButton<String>(
                        showSelectedIcon: false,
                        segments: const [
                          ButtonSegment(
                            value: 'light',
                            label: Text('Light'),
                            icon: Icon(Icons.light_mode_outlined, size: 16),
                          ),
                          ButtonSegment(
                            value: 'dark',
                            label: Text('Dark'),
                            icon: Icon(Icons.dark_mode_outlined, size: 16),
                          ),
                          ButtonSegment(
                            value: 'system',
                            label: Text('System'),
                            icon: Icon(Icons.brightness_auto_outlined, size: 16),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (set) {
                          appState.updateSettings(settings.copyWith(themeMode: set.first));
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Compact Density'),
                  subtitle: const Text('Tighter card margins and list heights'),
                  value: settings.isCompactDensity,
                  onChanged: (val) {
                    appState.updateSettings(settings.copyWith(isCompactDensity: val));
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Reduced Motion'),
                  subtitle: const Text('Minimize interface animations'),
                  value: settings.reducedMotion,
                  onChanged: (val) {
                    appState.updateSettings(settings.copyWith(reducedMotion: val));
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Live Date Home Icon & Widget
          _buildSectionHeader('APP ICON & LIVE DATE WIDGET'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // 3D Icon preview
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        image: const DecorationImage(
                          image: AssetImage('assets/icons/app_icon.png'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dynamic Real-Date Icon',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Add the 1x1 live widget to your home screen to always see today\'s real day & date!',
                            style: TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () async {
                    final pinned = await WidgetService.requestPinWidget();
                    if (context.mounted) {
                      if (pinned) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Added 1x1 Live Date Icon to your home screen!')),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'To add: Long-press your home screen -> Widgets -> Dayform -> Live Date Icon',
                            ),
                          ),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add_to_home_screen_rounded, size: 18),
                  label: const Text('Add Live Date Icon to Home Screen'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 3. Date, Time & Regional
          _buildSectionHeader('DATE & REGIONAL'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                // First Day of Week
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('First Day of Week'),
                  trailing: DropdownButton<int>(
                    value: settings.firstDayOfWeek,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 1, child: Text('Monday')),
                      DropdownMenuItem(value: 7, child: Text('Sunday')),
                      DropdownMenuItem(value: 6, child: Text('Saturday')),
                    ],
                    onChanged: (val) {
                      if (val != null) appState.updateSettings(settings.copyWith(firstDayOfWeek: val));
                    },
                  ),
                ),
                const Divider(),

                // Time Format
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('24-Hour Time Format'),
                  value: settings.is24Hour,
                  onChanged: (val) {
                    appState.updateSettings(settings.copyWith(is24Hour: val));
                  },
                ),
                const Divider(),

                // Default Currency (INR, GBP, USD, EUR)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Default Currency'),
                  trailing: DropdownButton<String>(
                    value: settings.currency,
                    underline: const SizedBox.shrink(),
                    items: const [
                      DropdownMenuItem(value: 'INR', child: Text('INR (₹)')),
                      DropdownMenuItem(value: 'GBP', child: Text('GBP (£)')),
                      DropdownMenuItem(value: 'USD', child: Text('USD (\$)')),
                      DropdownMenuItem(value: 'EUR', child: Text('EUR (€)')),
                    ],
                    onChanged: (val) {
                      if (val != null) appState.updateSettings(settings.copyWith(currency: val));
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. Notifications & Quiet Hours
          _buildSectionHeader('NOTIFICATIONS & RELIABILITY'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                // Notification Sound / Tune Setting
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.warmAmber.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.music_note_rounded, color: AppColors.warmAmberForeground, size: 20),
                  ),
                  title: const Text('Reminder Alert Tune', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Classic Harmonic Chime (Melodic bell tone)'),
                  trailing: const Icon(Icons.volume_up_rounded, size: 20, color: AppColors.warmAmberForeground),
                ),
                const Divider(height: 16),

                // Quiet Hours Switch
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Quiet Hours Policy'),
                  subtitle: const Text('Defers eligible reminders between 22:00 and 07:00'),
                  value: settings.quietHoursEnabled,
                  onChanged: (val) {
                    appState.updateSettings(settings.copyWith(quietHoursEnabled: val));
                  },
                ),
                const SizedBox(height: 12),

                // Send test notification
                ElevatedButton.icon(
                  onPressed: () async {
                    await NotificationService.instance.sendImmediateTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chime notification dispatched! Check your notification bar to hear the sound.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  label: const Text('Play Chime & Test Notification'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 5. Backup, Export & Restore
          _buildSectionHeader('DATA & BACKUP (OFFLINE)'),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.auto_awesome_rounded, color: AppColors.warmAmber),
                  title: const Text('Load Demo Data'),
                  subtitle: const Text('Populate realistic sample events, tasks and bills'),
                  onTap: () async {
                    await appState.loadSampleData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Demo sample data loaded successfully!')),
                      );
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_rounded, color: AppColors.teal),
                  title: const Text('Export JSON Backup'),
                  subtitle: const Text('Save a complete, validated backup of all data'),
                  onTap: () async {
                    final backupService = BackupService();
                    final jsonString = await backupService.exportBackupJson();
                    if (context.mounted) {
                      _showBackupDialog(context, jsonString);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.delete_forever_rounded, color: Colors.red),
                  title: const Text('Reset All Data'),
                  subtitle: const Text('Irreversibly delete all events, tasks and modules'),
                  onTap: () => _confirmResetAllData(context, appState),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: Colors.grey),
      ),
    );
  }

  void _showBackupDialog(BuildContext context, String json) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('JSON Backup Exported'),
        content: SizedBox(
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Text(
              json.length > 500 ? '${json.substring(0, 500)}...\n\n[Full backup generated]' : json,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done')),
        ],
      ),
    );
  }

  void _confirmResetAllData(BuildContext context, AppState appState) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset All Data?'),
        content: const Text(
          'This will permanently delete all events, tasks, bills, birthdays, habits, and focus logs from your device.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await appState.clearAllData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All data has been cleared.')),
                );
              }
            },
            child: const Text('Delete Everything', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// InheritedWidget helper for AppState access
class AppStateProvider extends InheritedWidget {
  final AppState appState;

  const AppStateProvider({
    super.key,
    required this.appState,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    assert(provider != null, 'No AppStateProvider found in context');
    return provider!.appState;
  }

  @override
  bool updateShouldNotify(AppStateProvider oldWidget) => appState != oldWidget.appState;
}
