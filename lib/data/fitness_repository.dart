import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class ActivityLog {
  ActivityLog({
    required this.id,
    required this.exerciseType,
    required this.durationMinutes,
    required this.calories,
    required this.loggedAt,
    required this.notes,
  });

  final int id;
  final String exerciseType;
  final int durationMinutes;
  final int calories;
  final DateTime loggedAt;
  final String notes;

  factory ActivityLog.fromMap(Map<String, Object?> map) {
    return ActivityLog(
      id: map['id'] as int,
      exerciseType: map['exercise_type'] as String,
      durationMinutes: map['duration_minutes'] as int,
      calories: map['calories'] as int,
      loggedAt: DateTime.parse(map['logged_at'] as String),
      notes: (map['notes'] as String?) ?? '',
    );
  }
}

class FitnessPlan {
  FitnessPlan({
    required this.id,
    required this.title,
    required this.targetSteps,
    required this.targetWorkouts,
    required this.targetCalories,
    required this.isActive,
    required this.restDaysPerWeek,
  });

  final int id;
  final String title;
  final int targetSteps;
  final int targetWorkouts;
  final int targetCalories;
  final bool isActive;
  final int restDaysPerWeek;

  factory FitnessPlan.fromMap(Map<String, Object?> map) {
    return FitnessPlan(
      id: map['id'] as int,
      title: map['title'] as String,
      targetSteps: map['target_steps'] as int,
      targetWorkouts: map['target_workouts'] as int,
      targetCalories: map['target_calories'] as int,
      isActive: (map['is_active'] as int) == 1,
      restDaysPerWeek: (map['rest_days_per_week'] as int?) ?? 1,
    );
  }
}

class DailyProgress {
  DailyProgress({
    required this.day,
    required this.steps,
    required this.calories,
    required this.workouts,
  });

  final DateTime day;
  final int steps;
  final int calories;
  final int workouts;
}

class StreakDay {
  const StreakDay({required this.day, required this.steps, required this.goalMet});

  final DateTime day;
  final int steps;
  final bool goalMet;
}

class DashboardSummary {
  DashboardSummary({
    required this.todaySteps,
    required this.todayCalories,
    required this.todayWorkouts,
    required this.weekly,
    required this.todayWaterGlasses,
  });

  final int todaySteps;
  final int todayCalories;
  final int todayWorkouts;
  final List<DailyProgress> weekly;
  final int todayWaterGlasses;
}

class FitnessRepository {
  FitnessRepository._();

  static final FitnessRepository instance = FitnessRepository._();

  Database? _db;

  Future<Database> get database async {
    if (_db != null) {
      return _db!;
    }
    final databasesPath = await getDatabasesPath();
    final dbPath = join(databasesPath, 'fitness_tracker.db');
    _db = await openDatabase(
      dbPath,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE activity_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            exercise_type TEXT NOT NULL,
            duration_minutes INTEGER NOT NULL,
            calories INTEGER NOT NULL,
            logged_at TEXT NOT NULL,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE daily_steps (
            day TEXT PRIMARY KEY,
            steps INTEGER NOT NULL
          )
        ''');

        await db.execute('''
          CREATE TABLE fitness_plans (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            target_steps INTEGER NOT NULL,
            target_workouts INTEGER NOT NULL,
            target_calories INTEGER NOT NULL,
            is_active INTEGER NOT NULL DEFAULT 1,
            rest_days_per_week INTEGER NOT NULL DEFAULT 1
          )
        ''');

        await db.execute('''
          CREATE TABLE water_logs (
            day TEXT PRIMARY KEY,
            glasses INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS water_logs (
              day TEXT PRIMARY KEY,
              glasses INTEGER NOT NULL DEFAULT 0
            )
          ''');
          try {
            await db.execute(
              'ALTER TABLE fitness_plans ADD COLUMN rest_days_per_week INTEGER NOT NULL DEFAULT 1',
            );
          } catch (_) {}
        }
      },
    );

    return _db!;
  }

  Future<void> addActivity({
    required String exerciseType,
    required int durationMinutes,
    required int calories,
    required DateTime loggedAt,
    String notes = '',
  }) async {
    final db = await database;
    await db.insert('activity_logs', {
      'exercise_type': exerciseType,
      'duration_minutes': durationMinutes,
      'calories': calories,
      'logged_at': loggedAt.toIso8601String(),
      'notes': notes,
    });
  }

  Future<List<ActivityLog>> getActivities() async {
    final db = await database;
    final rows = await db.query(
      'activity_logs',
      orderBy: 'logged_at DESC',
    );
    return rows.map(ActivityLog.fromMap).toList();
  }

  Future<void> deleteActivity(int id) async {
    final db = await database;
    await db.delete('activity_logs', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> upsertStepsForDay(String day, int steps) async {
    final db = await database;
    await db.insert(
      'daily_steps',
      {'day': day, 'steps': steps},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getStepsForDay(String day) async {
    final db = await database;
    final rows = await db.query(
      'daily_steps',
      columns: ['steps'],
      where: 'day = ?',
      whereArgs: [day],
      limit: 1,
    );
    if (rows.isEmpty) {
      return 0;
    }
    return rows.first['steps'] as int;
  }

  Future<int> addPlan({
    required String title,
    required int targetSteps,
    required int targetWorkouts,
    required int targetCalories,
    int restDaysPerWeek = 1,
  }) async {
    final db = await database;
    return db.insert('fitness_plans', {
      'title': title,
      'target_steps': targetSteps,
      'target_workouts': targetWorkouts,
      'target_calories': targetCalories,
      'is_active': 1,
      'rest_days_per_week': restDaysPerWeek,
    });
  }

  Future<List<FitnessPlan>> getPlans() async {
    final db = await database;
    final rows = await db.query('fitness_plans', orderBy: 'id DESC');
    return rows.map(FitnessPlan.fromMap).toList();
  }

  Future<void> setPlanActive(int id, bool isActive) async {
    final db = await database;
    await db.update(
      'fitness_plans',
      {'is_active': isActive ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<DashboardSummary> getDashboardSummary() async {
    final now = DateTime.now();
    final today = DateFormat('yyyy-MM-dd').format(now);
    final start = now.subtract(const Duration(days: 6));

    final db = await database;

    final weekly = <DailyProgress>[];
    for (var i = 0; i < 7; i++) {
      final day = start.add(Duration(days: i));
      final dayString = DateFormat('yyyy-MM-dd').format(day);

      final stepsRows = await db.query(
        'daily_steps',
        columns: ['steps'],
        where: 'day = ?',
        whereArgs: [dayString],
        limit: 1,
      );

      final activityRows = await db.rawQuery(
        '''
        SELECT COALESCE(SUM(calories), 0) as total_calories,
               COUNT(*) as total_workouts
        FROM activity_logs
        WHERE date(logged_at) = ?
        ''',
        [dayString],
      );

      final activityRow = activityRows.first;
      weekly.add(
        DailyProgress(
          day: day,
          steps: stepsRows.isEmpty ? 0 : (stepsRows.first['steps'] as int),
          calories: activityRow['total_calories'] as int,
          workouts: activityRow['total_workouts'] as int,
        ),
      );
    }

    final todayData = weekly.lastWhere(
      (item) => DateFormat('yyyy-MM-dd').format(item.day) == today,
      orElse: () => DailyProgress(day: now, steps: 0, calories: 0, workouts: 0),
    );

    final waterGlasses = await getWaterForDay(today);

    return DashboardSummary(
      todaySteps: todayData.steps,
      todayCalories: todayData.calories,
      todayWorkouts: todayData.workouts,
      weekly: weekly,
      todayWaterGlasses: waterGlasses,
    );
  }

  Future<void> upsertWaterForDay(String day, int glasses) async {
    final db = await database;
    await db.insert(
      'water_logs',
      {'day': day, 'glasses': glasses},
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> getWaterForDay(String day) async {
    final db = await database;
    final rows = await db.query(
      'water_logs',
      columns: ['glasses'],
      where: 'day = ?',
      whereArgs: [day],
      limit: 1,
    );
    if (rows.isEmpty) return 0;
    return rows.first['glasses'] as int;
  }

  Future<List<StreakDay>> getStreakData({int goalSteps = 10000}) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    // Start grid on the Monday of the week that is 6 weeks ago
    final daysBack = 6 * 7 + (today.weekday - 1);
    final mondayStart = today.subtract(Duration(days: daysBack));

    final db = await database;
    final rows = await db.query('daily_steps', columns: ['day', 'steps']);
    final stepMap = {for (final row in rows) row['day'] as String: row['steps'] as int};

    final result = <StreakDay>[];
    DateTime current = mondayStart;
    while (!current.isAfter(today)) {
      final dayStr = DateFormat('yyyy-MM-dd').format(current);
      final steps = stepMap[dayStr] ?? 0;
      result.add(StreakDay(day: current, steps: steps, goalMet: steps >= goalSteps));
      current = current.add(const Duration(days: 1));
    }
    return result;
  }

  Future<int> getCurrentStreak({int goalSteps = 10000}) async {
    final db = await database;
    final rows = await db.query(
      'daily_steps',
      columns: ['day', 'steps'],
      orderBy: 'day DESC',
      limit: 365,
    );
    if (rows.isEmpty) return 0;

    final stepMap = {for (final row in rows) row['day'] as String: row['steps'] as int};
    final now = DateTime.now();
    int streak = 0;
    DateTime checking = DateTime(now.year, now.month, now.day);

    for (var i = 0; i < 365; i++) {
      final dayStr = DateFormat('yyyy-MM-dd').format(checking);
      final steps = stepMap[dayStr] ?? 0;
      if (steps >= goalSteps) {
        streak++;
        checking = checking.subtract(const Duration(days: 1));
      } else {
        break;
      }
    }
    return streak;
  }
}
