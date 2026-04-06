# Technical Documentation: Aether Fitness

## 1. Environment

1. Flutter: 3.41.4 (stable)
2. Dart: 3.11.1
3. Target Platform: Android
4. Language: Dart

## 2. Dependencies

Defined in [pubspec.yaml](pubspec.yaml):

1. `sqflite`: local SQLite storage.
2. `path`: database path helpers.
3. `intl`: date formatting.
4. `fl_chart`: chart rendering.
5. `permission_handler`: runtime permission flow.
6. `pedometer`: step stream.
7. `shared_preferences`: step baseline persistence.
8. `flutter_launcher_icons`: app icon generation.

## 3. Module Breakdown

1. App Entry
   - [lib/main.dart](lib/main.dart)
   - Configures app-level theme and home shell.

2. Navigation Shell
   - [lib/screens/home_shell.dart](lib/screens/home_shell.dart)
   - Manages bottom navigation and step service lifecycle.

3. Data Repository
   - [lib/data/fitness_repository.dart](lib/data/fitness_repository.dart)
   - Initializes database.
   - Defines CRUD operations.
   - Provides aggregation methods for dashboard and streak data.

4. Step Tracking Service
   - [lib/services/step_tracking_service.dart](lib/services/step_tracking_service.dart)
   - Requests activity recognition permission.
   - Reads pedometer step events.
   - Computes per-day steps using baseline stored in `SharedPreferences`.

5. Screens
   - [lib/screens/dashboard_screen.dart](lib/screens/dashboard_screen.dart)
   - [lib/screens/log_activity_screen.dart](lib/screens/log_activity_screen.dart)
   - [lib/screens/plans_screen.dart](lib/screens/plans_screen.dart)
   - [lib/screens/history_screen.dart](lib/screens/history_screen.dart)

6. Widgets
   - [lib/widgets/glass_card.dart](lib/widgets/glass_card.dart)
   - [lib/widgets/ring_progress.dart](lib/widgets/ring_progress.dart)
   - [lib/widgets/streak_heatmap.dart](lib/widgets/streak_heatmap.dart)

## 4. Database Reference

Database file: `fitness_tracker.db`
Version: `2`

### Tables

1. `activity_logs`
   - `id INTEGER PRIMARY KEY AUTOINCREMENT`
   - `exercise_type TEXT`
   - `duration_minutes INTEGER`
   - `calories INTEGER`
   - `logged_at TEXT`
   - `notes TEXT`

2. `daily_steps`
   - `day TEXT PRIMARY KEY`
   - `steps INTEGER`

3. `fitness_plans`
   - `id INTEGER PRIMARY KEY AUTOINCREMENT`
   - `title TEXT`
   - `target_steps INTEGER`
   - `target_workouts INTEGER`
   - `target_calories INTEGER`
   - `is_active INTEGER`
   - `rest_days_per_week INTEGER`

4. `water_logs`
   - `day TEXT PRIMARY KEY`
   - `glasses INTEGER`

## 5. Key Data Flows

1. Step Tracking Flow
   - Permission request -> pedometer stream -> baseline/day normalization -> `daily_steps` upsert.

2. Manual Activity Flow
   - User submits form -> `activity_logs` insert -> dashboard refresh.

3. Dashboard Aggregation Flow
   - Query 7-day `daily_steps` + grouped `activity_logs` -> compose `DashboardSummary`.

4. Streak Flow
   - Pull historical steps -> evaluate goal threshold -> render heatmap dataset.

## 6. Permissions

Android permission in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml):

1. `android.permission.ACTIVITY_RECOGNITION`

## 7. Build and Run Commands

1. Install dependencies:

```bash
flutter pub get
```

2. Analyze:

```bash
flutter analyze
```

3. Run tests:

```bash
flutter test
```

4. Run on emulator/device:

```bash
flutter run -d emulator-5554
```

5. Build release APK:

```bash
flutter build apk --release
```

## 8. Branding Assets

1. App name set in [android/app/src/main/AndroidManifest.xml](android/app/src/main/AndroidManifest.xml).
2. Launcher source icon: [assets/logo.png](assets/logo.png).
3. Icon generation configured in [pubspec.yaml](pubspec.yaml) under `flutter_launcher_icons`.

## 9. Known Technical Notes

1. Emulator step events can be limited; real device testing is recommended for pedometer accuracy.
2. Step baseline resets when day changes and if sensor counter appears to roll over.
3. SQLite is single-source of truth for offline persistence.
