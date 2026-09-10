<p align="center">
  <img src="assets/icons/app_icon.png" width="128" height="128" alt="Dayform App Logo" />
</p>

<h1 align="center">Dayform</h1>

<p align="center">
  <strong>Serene, Privacy-First Personal Calendar, Reminder & Daily Planner</strong>
</p>

<p align="center">
  <a href="https://github.com/sangeethsanthosh-git/dayform/releases/latest"><img src="https://img.shields.io/github/v/release/sangeethsanthosh-git/dayform?color=E5BD78&label=Latest%20Release" alt="Release" /></a>
  <a href="https://github.com/sangeethsanthosh-git/dayform/releases/latest"><img src="https://img.shields.io/github/downloads/sangeethsanthosh-git/dayform/total?color=8E6827&label=Downloads" alt="Downloads" /></a>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
</p>

<p align="center">
  <a href="https://github.com/sangeethsanthosh-git/dayform/releases/tag/v1.0.0"><strong>📥 Download Latest APKs (v1.0.0)</strong></a> &bull; <em>ARM64 (~21MB), ARMv7 (~19MB), Universal (~61MB)</em>
</p>

---

**Dayform** is a serene, offline-first personal organizer designed to make your day easy to understand at a glance. It unifies events, tasks, reminders, study sessions, habits, birthdays, and recurring payments into a calm, cohesive interface without cognitive clutter or overwhelming density.

---

## Key Highlights

- **Zero Cloud & Zero Account**: Runs 100% offline with a local SQLite database (`sqflite`). No subscriptions, remote backends, telemetry, or third-party logins required.
- **Synthesized Aesthetic**: Editorial typography, warm amber accents, soft pastels, 24–28dp card radii, and clean pill selectors inspired by modern editorial mobile design.
- **Configurable Branding**: The app working name is easily customized in a single configuration file (`lib/core/constants/app_constants.dart`).
- **Exact Native Reminders**: Built on `flutter_local_notifications` (v22.3.0) and `timezone`, supporting exact alarms with inexact fallback, actionable notifications (Snooze 10m, Complete), and `RECEIVE_BOOT_COMPLETED` reconciliation.
- **Robust Recurrence Engine**: Custom engine handling Daily, Weekly, Monthly, and Yearly intervals, leap-year Feb 29 non-leap clamping to Feb 28, and single/series exception overrides and cancellations.
- **Conflict Detection**: Interactive calendar time-blocking warns about scheduling conflicts before altering existing appointments.
- **Backup & Restore**: Export and import full database state as versioned JSON with schema validation and both merge and overwrite modes.
- **Android Home Screen Widget**: Projection via `home_widget` displaying the next upcoming event and priority tasks.

---

## Screen Architecture & UI Mapping

### 1. Today Screen (`lib/features/today/`)
- **Editorial Date & Greeting Header**: Large prominent weekday and date header with contextual greeting ("Good morning / afternoon / evening") and quick action buttons.
- **Interactive Horizontal Week Strip**: 7-day capsule selector showing weekdays, month dates, and active event indicators with smooth scrolling.
- **Up Next Hero Card**: Shows the immediate next event, start time, relative countdown ("In 45 minutes"), category badge, and location. When free, displays a calm, reassuring empty state.
- **Chronological Agenda View**: Rounded event cards with avatar stickers and trailing chevron arrows. Includes a real-time current time indicator line.
- **Priority Tasks Section**: Smart task list with overdue alert banner, checkbox completions, and priority flags.
- **Modular Today Cards**: Quick glance cards for Daily Habits (with tap-to-complete), Upcoming Bills (with brand logo pills and renewal countdowns), and Upcoming Birthdays.

### 2. Calendar Screen (`lib/features/calendar/`)
- **Multi-View Engine**: Seamlessly switch between **Month**, **Week**, **Day**, and **Agenda** modes.
- **Month Grid**: Compact day cells showing event count badges, avatar stickers for birthdays, and brand logos for recurring payments.
- **Week & Day Timeline**: 24-hour vertical timeline grids with interactive slot long-press to quickly schedule new appointments.
- **Connected Ribbon Date Picker**: Modern bottom-sheet date range picker with continuous ribbon highlights between start and end dates.
- **Day Detail Sheet**: Interactive breakdown of all events, tasks, bills, and birthdays for any tapped calendar date.

### 3. Tasks Screen (`lib/features/tasks/`)
- **Smart Filter Tabs**: Inbox, Today, Upcoming, Overdue, and Completed.
- **Rich Task Metadata**: Subtasks with progress bars, priority indicators (Low, Medium, High, Urgent), due dates, and category tags.
- **Calendar Time-Blocking**: Convert any task into a scheduled calendar event with automated overlap and conflict detection.

### 4. My Space Screen (`lib/features/myspace/`)
- **Bills & Subscriptions**: Currency spend breakdowns (multi-currency support: INR, USD, EUR, GBP), renewal date countdowns, brand logo badges, and "Mark Paid" actions that automatically advance renewal dates.
- **Birthdays & Milestones**: Displays upcoming celebrations, turning milestone age calculations (e.g., "Turning 28"), and gift ideas.
- **Habit Tracker**: Daily streak counters, scheduled active day filters, and single-tap check-ins.
- **Focus Timer**: Dedicated Pomodoro/study session timer with presets (25m, 50m, 90m), linked task tracking, and session completion logging.
- **Weekly Review**: Factual metrics summarizing completed tasks, focus hours logged, and habit adherence rate with quick actions to reschedule rollover tasks.

### 5. Quick-Add Sheet (`lib/features/quick_add/`)
- **6-Tab Modal**: Fast creation for Events, Tasks, Reminders, Bills, Birthdays, and Habits.
- **Offline Natural Language Parser**: Intelligently parses date, time, category, and title directly from freeform text (e.g., *"Team meeting tomorrow at 3pm #work"* or *"Pay rent on 1st at 10am"*).
- **Reusable Templates**: Quick-start presets for Lectures, Assignments, Workouts, and Subscriptions.

### 6. Settings & Personalization (`lib/features/settings/`)
- **Theme**: System default, Light, and Dark modes.
- **Visuals**: Density controls (Comfortable / Compact) and Reduced Motion support.
- **Regional**: First day of week (Sunday vs Monday), 24-hour vs 12-hour time format, default currency selector.
- **Notifications**: Quiet hours policy and instant test notification trigger.
- **Data Management**: Full JSON backup export, import/restore, and sample data reset.

---

## Project Structure

```
lib/
├── app.dart                                # Root MaterialApp & theme integration
├── main.dart                               # Desktop FFI init & run entrypoint
├── core/
│   ├── backup/backup_service.dart          # Versioned JSON backup & restore
│   ├── constants/
│   │   ├── app_constants.dart              # App name, radii, notification channels
│   │   └── category_definitions.dart       # Work, Personal, Study, Health, Finance, Social
│   ├── database/
│   │   ├── app_database.dart               # Cross-platform SQLite initialization & schema
│   │   └── sample_data.dart                # High-fidelity seed data
│   ├── notifications/
│   │   └── notification_service.dart       # Exact alarms, channels, action callbacks
│   ├── recurrence/
│   │   └── recurrence_engine.dart          # Recurrence rules, exceptions, leap year handling
│   ├── state/
│   │   └── app_state.dart                  # ChangeNotifier central application state
│   ├── theme/
│   │   ├── app_colors.dart                 # Light/Dark tokens, pastels, high-contrast pairs
│   │   ├── app_theme.dart                  # Material 3 ThemeData with rounded geometries
│   │   └── app_typography.dart             # Editorial headline & body text styles
│   └── widget/
│       └── home_widget_service.dart        # Android home screen widget projection
├── domain/
│   ├── models/                             # Immutable data models with copyWith & maps
│   └── repositories/                       # SQL abstraction repositories
└── features/
    ├── calendar/                           # Month, Week, Day, Agenda views & sheets
    ├── myspace/                            # Bills, Birthdays, Habits, Focus, Weekly Review
    ├── navigation/                         # Main bottom navigation bar & scaffold
    ├── quick_add/                          # 6-type modal & natural language parser
    ├── settings/                           # Theme, regional, backup, quiet hours
    ├── tasks/                              # Smart lists, filters, time-blocking
    └── today/                              # Editorial header, week strip, up-next, agenda
```

---

## Verification & Quality Assurance

| Verification Step | Result | Notes |
| :--- | :--- | :--- |
| **`flutter analyze`** | **0 issues** | Fully static-typed, zero unused imports or warnings |
| **`flutter test`** | **13/13 passed** | 100% passing across unit, integration, and widget tests |
| **`flutter build bundle`** | **Success (0)** | Validated Dart compilation, asset bundling, and shaders |

### Running the Tests
```bash
flutter test
```

### Running Static Analysis
```bash
flutter analyze
```

---

## How to Run

### Android
Ensure an Android device or emulator is connected:
```bash
flutter run -d android
```

### Windows Desktop (Development & Testing)
Dayform includes `sqflite_common_ffi` support for instantaneous desktop testing:
```bash
flutter run -d windows
```

### iOS
```bash
flutter run -d ios
```

---

## Changing the App Name
To rename the application:
1. Open `lib/core/constants/app_constants.dart`
2. Change `static const String appName = 'Dayform';`
3. Update `android:label` in `android/app/src/main/AndroidManifest.xml` and `CFBundleDisplayName` in `ios/Runner/Info.plist`.

