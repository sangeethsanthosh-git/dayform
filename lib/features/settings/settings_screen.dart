import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/backup/backup_service.dart';
import '../../core/constants/app_constants.dart';
import '../../core/notifications/notification_service.dart';
import '../../core/services/widget_service.dart';
import '../../core/state/app_state.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/models/user_settings.dart';

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
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.warmAmberForeground),
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
                  leading: Icon(Icons.cake_outlined, color: AppColors.warmAmber),
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
                const Divider(height: 28),
                _buildAccentColorPicker(context, settings, appState, isDark),
                const Divider(height: 28),
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
                    child: Icon(Icons.music_note_rounded, color: AppColors.warmAmberForeground, size: 20),
                  ),
                  title: const Text('Reminder Alert Tune', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Classic Harmonic Chime (Tap to preview tone & vibration)'),
                  trailing: Icon(Icons.volume_up_rounded, size: 20, color: AppColors.warmAmberForeground),
                  onTap: () async {
                    await NotificationService.instance.playChimePreview();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Playing chime tone & pulse vibration preview...')),
                      );
                    }
                  },
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

                // Instant test notification
                ElevatedButton.icon(
                  onPressed: () async {
                    await NotificationService.instance.sendImmediateTestNotification();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chime notification dispatched! Look at your heads-up alert banner.')),
                      );
                    }
                  },
                  icon: const Icon(Icons.notifications_active_rounded, size: 18),
                  label: const Text('Instant Test (Chime & Heads-Up Alert)'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 44),
                  ),
                ),
                const SizedBox(height: 8),

                // Scheduled 5-second test alarm (verifies background/lockscreen wake)
                OutlinedButton.icon(
                  onPressed: () async {
                    await NotificationService.instance.scheduleTestNotification(delaySeconds: 5);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Alarm scheduled in 5 seconds! You can lock screen or leave app now to test wake.'),
                          duration: Duration(seconds: 4),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.alarm_rounded, size: 18),
                  label: const Text('Schedule 5s Test Alarm (Lock/Sleep Test)'),
                  style: OutlinedButton.styleFrom(
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
                  leading: Icon(Icons.auto_awesome_rounded, color: AppColors.warmAmber),
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

  Widget _buildAccentColorPicker(BuildContext context, UserSettings settings, AppState appState, bool isDark) {
    final presets = AppColors.presetAccents;
    final isCustomActive = settings.customAccentColorValue != null;
    final activeCustomColor = isCustomActive ? Color(settings.customAccentColorValue!) : null;

    String activeColorName;
    if (isCustomActive) {
      activeColorName = 'Custom (#${activeCustomColor!.value.toRadixString(16).substring(2).toUpperCase()})';
    } else {
      activeColorName = presets[settings.accentColorIndex.clamp(0, presets.length - 1)].name;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Accent & Theme Color', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(
                  'Replaces gold across the entire app ($activeColorName)',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                  ),
                ),
              ],
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: AppColors.warmAmber,
                shape: BoxShape.circle,
                border: Border.all(
                  color: isDark ? Colors.white54 : Colors.black26,
                  width: 2,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        SizedBox(
          height: 74,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length + 1,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              if (index < presets.length) {
                final preset = presets[index];
                final isSelected = !isCustomActive && settings.accentColorIndex == index;
                return GestureDetector(
                  onTap: () {
                    appState.updateSettings(
                      settings.copyWith(
                        accentColorIndex: index,
                        clearCustomAccent: true,
                      ),
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: preset.color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? (isDark ? Colors.white : AppColors.primaryDarkText)
                                : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: preset.color.withOpacity(0.45),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: isSelected
                            ? Icon(
                                Icons.check_rounded,
                                size: 22,
                                color: preset.color.computeLuminance() > 0.45
                                    ? AppColors.primaryDarkText
                                    : Colors.white,
                              )
                            : null,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        preset.name.split(' ').first,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText)
                              : (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                return GestureDetector(
                  onTap: () => _showCustomColorPickerSheet(context, settings, appState, isDark),
                  child: Column(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCustomActive
                              ? activeCustomColor
                              : (isDark ? AppColors.darkSurfaceMuted : AppColors.lightSurfaceMuted),
                          border: Border.all(
                            color: isCustomActive
                                ? (isDark ? Colors.white : AppColors.primaryDarkText)
                                : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                            width: isCustomActive ? 2.5 : 1.5,
                          ),
                        ),
                        child: Icon(
                          isCustomActive ? Icons.check_rounded : Icons.colorize_rounded,
                          size: 20,
                          color: isCustomActive
                              ? (activeCustomColor!.computeLuminance() > 0.45
                                  ? AppColors.primaryDarkText
                                  : Colors.white)
                              : (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Custom',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: isCustomActive ? FontWeight.w700 : FontWeight.w500,
                          color: isCustomActive
                              ? (isDark ? AppColors.primaryLightText : AppColors.primaryDarkText)
                              : (isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  void _showCustomColorPickerSheet(BuildContext context, UserSettings settings, AppState appState, bool isDark) {
    const popularUniversalColors = [
      Color(0xFFE5BD78), // Classic Gold
      Color(0xFFF59E0B), // Amber
      Color(0xFFF97316), // Orange
      Color(0xFFFF5722), // Deep Orange
      Color(0xFFEF4444), // Red
      Color(0xFFEC4899), // Pink
      Color(0xFFE91E63), // Magenta / Deep Pink
      Color(0xFF8B5CF6), // Purple
      Color(0xFF6366F1), // Indigo
      Color(0xFF3B82F6), // Blue
      Color(0xFF0284C7), // Light Blue
      Color(0xFF06B6D4), // Cyan
      Color(0xFF14B8A6), // Teal
      Color(0xFF10B981), // Emerald
      Color(0xFF22C55E), // Green
      Color(0xFF84CC16), // Lime
      Color(0xFFEAB308), // Yellow
      Color(0xFF64748B), // Slate
      Color(0xFF78716C), // Warm Stone
      Color(0xFF202320), // Charcoal Dark
    ];

    Color selectedColor = settings.customAccentColorValue != null
        ? Color(settings.customAccentColorValue!)
        : AppColors.warmAmber;

    final hexController = TextEditingController(
      text: selectedColor.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase(),
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Universal Color Picker',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: selectedColor,
                          shape: BoxShape.circle,
                          border: Border.all(color: isDark ? Colors.white30 : Colors.black12, width: 2),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Select any universal shade or enter a custom hex code',
                    style: TextStyle(
                      fontSize: 13,
                      color: isDark ? AppColors.secondaryLightText : AppColors.secondaryDarkText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Palette Grid
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: popularUniversalColors.map((color) {
                      final isSelected = selectedColor.value == color.value;
                      return GestureDetector(
                        onTap: () {
                          setModalState(() {
                            selectedColor = color;
                            hexController.text =
                                color.value.toRadixString(16).padLeft(8, '0').substring(2).toUpperCase();
                          });
                        },
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected
                                  ? (isDark ? Colors.white : AppColors.primaryDarkText)
                                  : Colors.transparent,
                              width: 2.5,
                            ),
                          ),
                          child: isSelected
                              ? Icon(
                                  Icons.check_rounded,
                                  size: 20,
                                  color: color.computeLuminance() > 0.45
                                      ? AppColors.primaryDarkText
                                      : Colors.white,
                                )
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  // Hex code input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: hexController,
                          maxLength: 6,
                          decoration: const InputDecoration(
                            labelText: 'Hex Color Code',
                            prefixText: '# ',
                            counterText: '',
                            hintText: 'E5BD78',
                          ),
                          onChanged: (val) {
                            if (val.length == 6) {
                              final intVal = int.tryParse('FF$val', radix: 16);
                              if (intVal != null) {
                                setModalState(() {
                                  selectedColor = Color(intVal);
                                });
                              }
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.pop(sheetContext);
                          appState.updateSettings(
                            settings.copyWith(
                              customAccentColorValue: selectedColor.value,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: selectedColor,
                          foregroundColor: selectedColor.computeLuminance() > 0.45
                              ? AppColors.primaryDarkText
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Apply Color', style: TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
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
