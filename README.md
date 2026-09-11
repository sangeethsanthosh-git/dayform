<p align="center">
  <img src="assets/icons/app_icon.png" width="128" height="128" alt="Dayform App Logo" />
</p>

<h1 align="center">Dayform</h1>

<p align="center">
  <strong>Serene, Privacy-First Personal Calendar, Planner, Habit Tracker & Reminders</strong>
</p>

<p align="center">
  <a href="https://github.com/sangeethsanthosh-git/dayform/releases/latest"><img src="https://img.shields.io/github/v/release/sangeethsanthosh-git/dayform?color=E5BD78&label=Latest%20Release" alt="Release" /></a>
  <a href="https://github.com/sangeethsanthosh-git/dayform/releases/latest"><img src="https://img.shields.io/github/downloads/sangeethsanthosh-git/dayform/total?color=8E6827&label=Downloads" alt="Downloads" /></a>
  <img src="https://img.shields.io/badge/Platform-Android-3DDC84?logo=android&logoColor=white" alt="Platform" />
  <img src="https://img.shields.io/badge/Flutter-3.11+-02569B?logo=flutter&logoColor=white" alt="Flutter" />
  <a href="https://www.buymeacoffee.com/sangeethsanthoshsa"><img src="https://img.shields.io/badge/Buy%20Me%20a%20Coffee-Donate-FFDD00?logo=buy-me-a-coffee&logoColor=black" alt="Buy Me A Coffee" /></a>
</p>

<p align="center">
  <a href="https://github.com/sangeethsanthosh-git/dayform/releases/latest"><strong>📥 Download Latest Release APKs</strong></a> &bull; <em>ARM64 (~22MB), ARMv7 (~19MB), Universal (~60MB)</em>
</p>

---

**Dayform** is a serene, offline-first personal organizer designed to make your day easy to understand at a glance. It unifies events, tasks, reminders, study sessions, habits, birthdays, and recurring payments into a calm, cohesive interface without cognitive clutter or overwhelming density.

---

## ✨ Key Highlights

- **Zero Cloud & Zero Account**: Runs 100% offline with a local SQLite database (`sqflite`). No subscriptions, remote backends, telemetry, or third-party logins required.
- **Synthesized Aesthetic**: Editorial typography, warm amber accents, soft pastels, 24–28dp card radii, and clean pill selectors inspired by modern editorial mobile design.
- **In-App GitHub Update Checker**: Automatically checks GitHub Releases for new updates in the background. Users receive an elegant in-app notification banner on the Today screen and can view release notes and download/install the latest APK directly.
- **Customizable Notification Tones**: Choose from 6 distinct notification tones (Classic Chime, Crystal Bell, Gentle Marimba, Digital Pulse, Zen Singing Bowl, and System Default) with interactive in-app preview.
- **Exact Native Reminders**: Built on `flutter_local_notifications` (v22.3.0) and `timezone`, supporting exact alarms with inexact fallback, custom alert audio, and `RECEIVE_BOOT_COMPLETED` reconciliation.
- **Robust Recurrence Engine**: Custom engine handling Daily, Weekly, Monthly, and Yearly intervals, leap-year Feb 29 non-leap clamping to Feb 28, and single/series exception overrides and cancellations.
- **Conflict Detection**: Interactive calendar time-blocking warns about scheduling conflicts before altering existing appointments.
- **Backup & Restore**: Export and import full database state as versioned JSON with schema validation.
- **Android Home Screen Widget**: Dynamic 1x1 live date widget and projection via `home_widget` displaying the next upcoming event and priority tasks.
- **Clean Production Setup**: Completely free of mock or demo data on fresh installs.

---

## 📱 Screen Architecture & Features

### 1. Today Screen (`lib/features/today/`)
- **In-App Update Banner**: Prominently notifies users when a newer version is released on GitHub, with one-tap APK installation and full release notes.
- **Editorial Date & Greeting Header**: Large prominent weekday and date header with contextual greeting ("Good morning / afternoon / evening") and personalized user profile.
- **Interactive Capsule Week Strip**: 7-day capsule selector showing weekdays, month dates, and active event indicators with smooth scrolling.
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
- **Weekly Review**: Factual metrics summarizing completed tasks, focus hours logged, and habit adherence rate.

### 5. Quick-Add Sheet (`lib/features/quick_add/`)
- **6-Tab Modal**: Fast creation for Events, Tasks, Reminders, Bills, Birthdays, and Habits.
- **Offline Natural Language Parser**: Intelligently parses date, time, category, and title directly from freeform text (e.g., *"Team meeting tomorrow at 3pm #work"* or *"Pay rent on 1st at 10am"*).
- **Reusable Templates**: Quick-start presets for Lectures, Assignments, Workouts, and Subscriptions.

### 6. Settings Screen (`lib/features/settings/`)
- **App Updates & Version**: View installed version, check GitHub releases manually with a live indicator, and open the direct APK installer.
- **Developer & Support Section**:
  - Developer profile: **Sangeeth Santhosh S A** (*Full-Stack Developer & Designer*).
  - **☕ Buy Me a Coffee**: Direct support integration.
  - Connecting links to **GitHub**, **Portfolio**, **X (Twitter)**, **LinkedIn**, and **Email**.
- **Personalization**: Dynamic universal accent color picker (Presets + custom HEX code) and Theme options (System / Light / Dark).
- **Notification Tones**: Tone picker bottom sheet with audio preview for 6 curated notification soundscapes.
- **Regional & Format**: First day of week (Sunday vs Monday), 24-hour vs 12-hour time format, default currency selector.
- **Data Management**: Full JSON backup export, import/restore, and reset database.

---

## 🛠 Project Structure

```
lib/
├── app.dart                                # Root MaterialApp & theme integration
├── main.dart                               # Desktop FFI init & run entrypoint
├── core/
│   ├── backup/backup_service.dart          # Versioned JSON backup & restore
│   ├── constants/
│   │   ├── app_constants.dart              # App metadata, developer info, notification tones
│   │   └── category_definitions.dart       # Work, Personal, Study, Health, Finance, Social
│   ├── database/
│   │   └── app_database.dart               # Cross-platform SQLite initialization & schema
│   ├── notifications/
│   │   └── notification_service.dart       # Exact alarms, channels, audio tones, callbacks
│   ├── recurrence/
│   │   └── recurrence_engine.dart          # Recurrence rules, exceptions, leap year handling
│   ├── services/
│   │   ├── update_service.dart             # GitHub releases query, version compare, APK download
│   │   └── widget_service.dart             # Android home screen live widget service
│   ├── state/
│   │   └── app_state.dart                  # ChangeNotifier central application state
│   ├── theme/
│   │   ├── app_colors.dart                 # Universal accent palettes & color tokens
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
    ├── settings/                           # Updates, developer card, tones, theme, backup
    ├── tasks/                              # Smart lists, filters, time-blocking
    └── today/                              # In-app update banner, editorial header, week strip
```

---

## 🧪 Verification & Quality Assurance

| Verification Step | Result | Notes |
| :--- | :--- | :--- |
| **`flutter analyze`** | **0 issues** | Clean static analysis, zero warnings or deprecated usages |
| **`flutter test`** | **20/20 passed** | Unit, widget, semantic version comparison, and APK asset logic tests |
| **Release Build** | **Success (0)** | Tree-shaken font assets, ABI-split and universal APK outputs |

### Running Tests
```bash
flutter test
```

### Running Static Analysis
```bash
flutter analyze
```

---

## 👨‍💻 Developer & Support

Created and maintained by **Sangeeth Santhosh S A**  
*Full-Stack Developer & Designer*

- ☕ **Support**: [Buy Me a Coffee](https://www.buymeacoffee.com/sangeethsanthoshsa)
- 🌐 **Portfolio**: [sangeethsanthosh-git.github.io](https://sangeethsanthosh-git.github.io/)
- 💻 **GitHub**: [@sangeethsanthosh-git](https://github.com/sangeethsanthosh-git)
- 🐦 **X (Twitter)**: [@veek10z](https://x.com/veek10z)
- 💼 **LinkedIn**: [sangeethsanthoshsa](https://www.linkedin.com/in/sangeethsanthoshsa)
- ✉️ **Email**: [sangeethsanthoshsaa@gmail.com](mailto:sangeethsanthoshsaa@gmail.com)

---

## 📄 License
This project is open-source and available under the MIT License.


