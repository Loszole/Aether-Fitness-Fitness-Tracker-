import 'dart:async';

import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/fitness_repository.dart';

class StepTrackingService {
  StepTrackingService(this._repository);

  static const _baselineStepsKey = 'baseline_steps';
  static const _baselineDayKey = 'baseline_day';

  final FitnessRepository _repository;
  StreamSubscription<StepCount>? _stepSubscription;

  Future<bool> requestPermission() async {
    final status = await Permission.activityRecognition.request();
    return status.isGranted;
  }

  Future<int> getTodayStoredSteps() async {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return _repository.getStepsForDay(today);
  }

  Future<void> start({required void Function(int steps) onSteps}) async {
    final isGranted = await requestPermission();
    if (!isGranted) {
      return;
    }

    _stepSubscription?.cancel();
    final prefs = await SharedPreferences.getInstance();

    _stepSubscription = Pedometer.stepCountStream.listen(
      (event) async {
        final now = DateTime.now();
        final today = DateFormat('yyyy-MM-dd').format(now);

        var baselineDay = prefs.getString(_baselineDayKey);
        var baseline = prefs.getInt(_baselineStepsKey);

        if (baselineDay != today || baseline == null) {
          baselineDay = today;
          baseline = event.steps;
          await prefs.setString(_baselineDayKey, today);
          await prefs.setInt(_baselineStepsKey, baseline);
        }

        var todaySteps = event.steps - baseline;
        if (todaySteps < 0) {
          baseline = event.steps;
          todaySteps = 0;
          await prefs.setInt(_baselineStepsKey, baseline);
        }

        await _repository.upsertStepsForDay(today, todaySteps);
        onSteps(todaySteps);
      },
      onError: (_) {
        // Sensor stream can fail on emulators or unsupported devices.
      },
      cancelOnError: false,
    );
  }

  Future<void> dispose() async {
    await _stepSubscription?.cancel();
    _stepSubscription = null;
  }
}
