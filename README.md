# Aether Fitness

Aether Fitness is an offline-first Flutter Android fitness tracker built for CodeAlpha Task 3.

It helps users track daily steps, workouts, calories, water intake, and weekly progress with a modern UI.

## Task Coverage

This implementation satisfies all required points from [task.txt](task.txt):

1. Track daily fitness activities: steps, workouts, calories.
2. Manual data logging: exercise type, workout duration, calories, notes.
3. Dashboard summary: daily and weekly progress.
4. Visual UI: circular progress rings, bars, chart, streak heatmap.
5. Local storage: SQLite database (fully offline).

## Features

1. Step tracking using Android activity recognition + pedometer stream.
2. Manual activity logging with quick-log chips.
3. Daily dashboard with:
  - Steps ring
  - Workouts ring
  - Calories ring
  - Weekly bar chart
  - Water tracker
4. History tab with deletion and streak heatmap.
5. Fitness plans with rest-day support.
6. Premium visual style (Midnight Slate theme + glassmorphism).

## Screenshots

### Splash and Branding

![Aether Fitness Splash](Screenshot/Aether%20Fitness%20Splash.png)
![Aether Fitness Logo](Screenshot/Aether%20Fitness%20Logo.png)

### Main App Screens

![Aether Fitness Dashboard](Screenshot/Aether%20Fitness%20Dashboard.png)
![Aether Fitness Dashboard 2](Screenshot/Aether%20Fitness%20Dashboard%202.png)
![Aether Fitness Log](Screenshot/Aether%20Fitness%20Log.png)
![Aether Fitness Log 2](Screenshot/Aether%20Fitness%20Log%202.png)
![Aether Fitness History](Screenshot/Aether%20Fitness%20History.png)
![Aether Fitness Plan](Screenshot/Aether%20Fitness%20Plan.png)

## Tech Stack

1. Flutter (Dart)
2. SQLite (`sqflite`)
3. Step sensor (`pedometer`)
4. Permissions (`permission_handler`)
5. Local preferences (`shared_preferences`)
6. Charts (`fl_chart`)

## Project Structure

1. [lib/main.dart](lib/main.dart): app bootstrap and global theme.
2. [lib/screens/home_shell.dart](lib/screens/home_shell.dart): tab shell/navigation.
3. [lib/screens/dashboard_screen.dart](lib/screens/dashboard_screen.dart): summary and weekly chart.
4. [lib/screens/log_activity_screen.dart](lib/screens/log_activity_screen.dart): manual activity forms.
5. [lib/screens/plans_screen.dart](lib/screens/plans_screen.dart): plan creation and rest days.
6. [lib/screens/history_screen.dart](lib/screens/history_screen.dart): activity history + streak heatmap.
7. [lib/data/fitness_repository.dart](lib/data/fitness_repository.dart): SQLite schema and data access.
8. [lib/services/step_tracking_service.dart](lib/services/step_tracking_service.dart): sensor integration.
9. [lib/widgets](lib/widgets): reusable UI components.

## Database Schema (SQLite)

1. `activity_logs`: manual workout entries.
2. `daily_steps`: step count by day.
3. `fitness_plans`: plan target values and active state.
4. `water_logs`: daily water intake.

Database is versioned in [lib/data/fitness_repository.dart](lib/data/fitness_repository.dart) and includes migration logic.

## Setup and Run

Prerequisites:

1. Flutter SDK installed (`flutter --version`)
2. Android SDK/Emulator configured
3. Android emulator running (or physical Android device)

Install and run:

```bash
flutter pub get
flutter run -d emulator-5554
```

If emulator id differs:

```bash
flutter devices
flutter run -d <device-id>
```

## Build APK

Debug:

```bash
flutter build apk --debug
```

Release:

```bash
flutter build apk --release
```

## Quality Checks

Run static analysis:

```bash
flutter analyze
```

Run tests:

```bash
flutter test
```

## App Branding

1. App name: Aether Fitness.
2. Android launcher icon generated from [assets/logo.png](assets/logo.png).
3. Icon tooling configured in [pubspec.yaml](pubspec.yaml) using `flutter_launcher_icons`.

## Documentation Files

1. [README.md](README.md): setup, usage, architecture overview.
2. [PROJECT_REPORT.md](PROJECT_REPORT.md): formal project report for submission.
3. [TECHNICAL_DOCUMENTATION.md](TECHNICAL_DOCUMENTATION.md): low-level technical reference.
4. [PRIVACY_POLICY.md](PRIVACY_POLICY.md): data collection and permissions policy.

## Future Improvements

1. Edit/update logged activities.
2. Goal customization from settings.
3. CSV export and backup/restore.
4. Optional cloud sync (Firebase).
5. Unit/integration test expansion.
