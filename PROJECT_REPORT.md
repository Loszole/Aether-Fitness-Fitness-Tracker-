# Project Report: Aether Fitness

## 1. Project Overview

Aether Fitness is a Flutter-based Android fitness tracking application developed for Task 3.
The system is designed as an offline-first mobile app where all user records are persisted locally using SQLite.

## 2. Objective

The objective of this project is to provide a clean and user-friendly fitness tool that allows users to:

1. Track daily physical activity metrics.
2. Log workout entries manually.
3. View daily and weekly progress using visual summaries.
4. Use the application without requiring internet connectivity.

## 3. Requirements and Implementation Mapping

1. Requirement: Track steps, workouts, calories.
   - Implemented via daily step persistence and manual activity records.
2. Requirement: Manual data entry for workouts.
   - Implemented in log activity form (exercise type, duration, calories, notes, date).
3. Requirement: Dashboard/summary with daily and weekly progress.
   - Implemented in dashboard with progress rings and weekly chart.
4. Requirement: Visual UI (graphs/progress bars).
   - Implemented using circular progress rings, bar charts, and streak heatmap.
5. Requirement: Local storage (SQLite/Firebase option).
   - Implemented with SQLite (`sqflite`) as local persistent storage.

## 4. System Architecture

The project follows a simple layered structure:

1. Presentation Layer
   - Screens and widgets under [lib/screens](lib/screens) and [lib/widgets](lib/widgets).
2. Data Layer
   - Repository and schema in [lib/data/fitness_repository.dart](lib/data/fitness_repository.dart).
3. Service Layer
   - Sensor access and permission handling in [lib/services/step_tracking_service.dart](lib/services/step_tracking_service.dart).

## 5. Core Features Delivered

1. Offline local storage with SQLite.
2. Step tracking through activity recognition and pedometer stream.
3. Manual activity logging and history list.
4. Dashboard summary with:
   - Steps ring
   - Workouts ring
   - Calories ring
   - Weekly bar chart
   - Water tracker
5. Streak heatmap in history tab.
6. Fitness plans with rest-day support.
7. Premium visual style and custom app branding.

## 6. Database Design

SQLite tables:

1. `activity_logs`
   - Stores workout details entered by users.
2. `daily_steps`
   - Stores per-day step totals.
3. `fitness_plans`
   - Stores user plans and goals (including rest days).
4. `water_logs`
   - Stores per-day water glasses.

Migration support is included through schema versioning in repository initialization.

## 7. User Interface Design Summary

The UI follows a modern “Midnight Slate” design approach:

1. Dark gradient background.
2. Glassmorphism cards (blur + light border).
3. High-contrast accent colors for active values.
4. Visual hierarchy emphasizing daily step progress.

This supports better readability and motivation compared to plain card lists.

## 8. Testing and Validation

Validation activities completed:

1. Static analysis using `flutter analyze`.
2. Widget tests using `flutter test`.
3. Emulator deployment using `flutter run -d emulator-5554`.

Results:

1. Analyzer reports no issues.
2. Test suite passes.
3. App installs and runs on Android emulator.

## 9. Constraints and Limitations

1. Background step reliability can vary by emulator/device and permission state.
2. Cloud backup/sync is not included in current offline-first scope.
3. Activity edit flow can be extended in future versions.

## 10. Conclusion

The project successfully meets all mandatory Task 3 requirements and extends them with additional engagement and visual features.
Aether Fitness is production-ready for academic/demo submission as an offline Android fitness tracker.

## 11. Future Work

1. Add settings for custom goals.
2. Add export/import backup.
3. Add cloud sync (Firebase) as optional layer.
4. Add deeper analytics and monthly trends.
5. Expand automated tests (integration tests).
