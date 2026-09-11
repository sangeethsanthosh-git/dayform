class NotificationToneOption {
  final String id;
  final String title;
  final String description;
  final String channelId;
  final String? rawSoundName;

  const NotificationToneOption({
    required this.id,
    required this.title,
    required this.description,
    required this.channelId,
    this.rawSoundName,
  });
}

class AppConstants {
  // Centralized branding token - easy to change
  static const String appName = 'Dayform';
  static const String appTagline = 'Your day, beautifully organized';
  static const String appVersion = '1.0.0';

  // Developer & Support Details
  static const String developerName = 'Sangeeth Santhosh S A';
  static const String developerRole = 'Full-Stack Developer & Designer';
  static const String developerEmail = 'sangeethsanthoshsaa@gmail.com';
  static const String developerGithubUrl = 'https://github.com/sangeethsanthosh-git';
  static const String developerWebsiteUrl = 'https://sangeethsanthosh-git.github.io';
  static const String developerTwitterUrl = 'https://x.com/veek10z';
  static const String developerTwitterHandle = '@veek10z';
  static const String developerLinkedinUrl = 'https://www.linkedin.com/in/sangeethsanthoshsa';
  static const String buyMeACoffeeUrl = 'https://www.buymeacoffee.com/sangeethsanthoshsa';

  static const String githubRepoOwner = 'sangeethsanthosh-git';
  static const String githubRepoName = 'dayform';
  static const String githubReleasesUrl =
      'https://github.com/sangeethsanthosh-git/dayform/releases';
  static const String githubReleasesApiUrl =
      'https://api.github.com/repos/sangeethsanthosh-git/dayform/releases/latest';

  // Storage & database
  static const String databaseName = 'dayform.db';
  static const int databaseVersion = 1;

  // Notification Channels
  // Android notification-channel settings cannot be changed after the channel
  // has been created. Keep this versioned so sound/vibration fixes reach users
  // who already have an older, silent channel on their device.
  static const String reminderChannelId = 'dayform_alarms_v5';
  static const String reminderChannelName = 'Dayform Reminders & Alarms';
  static const String reminderChannelDesc =
      'Loud chime alert for time-sensitive reminders, tasks and calendar events';

  // Available Notification Tones
  static const List<NotificationToneOption> notificationTones = [
    NotificationToneOption(
      id: 'chime',
      title: 'Classic Chime',
      description: 'Warm 3-tone harmonic chime (Default)',
      channelId: 'dayform_tone_chime_v1',
      rawSoundName: 'reminder_chime',
    ),
    NotificationToneOption(
      id: 'bell',
      title: 'Crystal Bell',
      description: 'Crisp, high-clarity ringing bell',
      channelId: 'dayform_tone_bell_v1',
      rawSoundName: 'reminder_bell',
    ),
    NotificationToneOption(
      id: 'marimba',
      title: 'Gentle Marimba',
      description: 'Soft wooden acoustic triad arpeggio',
      channelId: 'dayform_tone_marimba_v1',
      rawSoundName: 'reminder_marimba',
    ),
    NotificationToneOption(
      id: 'electronic',
      title: 'Digital Pulse',
      description: 'Modern energetic dual-pulse synth',
      channelId: 'dayform_tone_electronic_v1',
      rawSoundName: 'reminder_electronic',
    ),
    NotificationToneOption(
      id: 'zen',
      title: 'Zen Singing Bowl',
      description: 'Tranquil ambient gong & meditative resonance',
      channelId: 'dayform_tone_zen_v1',
      rawSoundName: 'reminder_zen',
    ),
    NotificationToneOption(
      id: 'system',
      title: 'Device Default',
      description: 'Standard Android notification sound',
      channelId: 'dayform_tone_system_v1',
      rawSoundName: null,
    ),
  ];

  static NotificationToneOption getToneOption(String? id) {
    return notificationTones.firstWhere(
      (t) => t.id == id,
      orElse: () => notificationTones.first,
    );
  }

  // Layout & Styling constants
  static const double cardRadiusLarge = 28.0;
  static const double cardRadiusMedium = 20.0;
  static const double cardRadiusSmall = 14.0;
  static const double pillRadius = 999.0;

  // Defaults
  static const int defaultEventDurationMinutes = 60;
  static const int defaultReminderMinutesBefore = 15;
  static const String defaultCurrency = 'INR';
  static const String defaultCurrencySymbol = '₹';
}

