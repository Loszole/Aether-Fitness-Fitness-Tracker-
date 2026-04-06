import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/fitness_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/ring_progress.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.repository,
    required this.refreshTick,
  });

  final FitnessRepository repository;
  final int refreshTick;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  static const int _stepGoal = 10000;
  static const int _waterGoal = 8;

  late Future<DashboardSummary> _summaryFuture;

  @override
  void initState() {
    super.initState();
    _summaryFuture = widget.repository.getDashboardSummary();
  }

  @override
  void didUpdateWidget(DashboardScreen old) {
    super.didUpdateWidget(old);
    if (old.refreshTick != widget.refreshTick) {
      setState(() {
        _summaryFuture = widget.repository.getDashboardSummary();
      });
    }
  }

  Future<void> _addWater(int current) async {
    if (current >= _waterGoal) return;
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    await widget.repository.upsertWaterForDay(today, current + 1);
    if (!mounted) return;
    setState(() => _summaryFuture = widget.repository.getDashboardSummary());
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Morning';
    if (hour < 17) return 'Afternoon';
    return 'Evening';
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DashboardSummary>(
      future: _summaryFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            data == null
                ? _loadingCard()
                : _buildStepsHero(context, data),
            const SizedBox(height: 12),
            if (data != null) _buildStatsRow(context, data),
            const SizedBox(height: 12),
            if (data != null) _buildWaterTracker(context, data),
            const SizedBox(height: 20),
            Text('Weekly Steps', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            data == null
                ? _loadingCard(height: 200)
                : _buildWeeklyChart(context, data),
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Good ${_greeting()}!',
          style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                color: const Color(0xFF38BDF8),
              ),
        ),
        const SizedBox(height: 2),
        Text(
          DateFormat('EEEE, MMM d').format(DateTime.now()),
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildStepsHero(BuildContext context, DashboardSummary data) {
    final progress = (data.todaySteps / _stepGoal).clamp(0.0, 1.0);
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      child: Column(
        children: [
          Text('Daily Steps', style: Theme.of(context).textTheme.labelLarge),
          const SizedBox(height: 20),
          RingProgress(
            progress: progress,
            color: const Color(0xFF38BDF8),
            size: 170,
            strokeWidth: 14,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  NumberFormat('#,###').format(data.todaySteps),
                  style: Theme.of(context).textTheme.headlineLarge!.copyWith(
                        color: const Color(0xFF38BDF8),
                        fontWeight: FontWeight.bold,
                        fontSize: 34,
                      ),
                ),
                Text('of $_stepGoal', style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle_outline, size: 14, color: Color(0xFF38BDF8)),
              const SizedBox(width: 4),
              Text(
                '${(progress * 100).round()}% of daily goal',
                style: const TextStyle(color: Color(0xFF38BDF8), fontSize: 13),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context, DashboardSummary data) {
    final calProgress = (data.todayCalories / 500.0).clamp(0.0, 1.0);
    final workoutProgress = (data.todayWorkouts / 3.0).clamp(0.0, 1.0);

    return Row(
      children: [
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Workouts', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                RingProgress(
                  progress: workoutProgress,
                  color: const Color(0xFFFACC15),
                  size: 84,
                  strokeWidth: 8,
                  child: Text(
                    '${data.todayWorkouts}',
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                          color: const Color(0xFFFACC15),
                        ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('Calories', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 12),
                RingProgress(
                  progress: calProgress,
                  color: const Color(0xFFEF4444),
                  size: 84,
                  strokeWidth: 8,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${data.todayCalories}',
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                              color: const Color(0xFFEF4444),
                              fontSize: data.todayCalories > 999 ? 15 : null,
                            ),
                      ),
                      const Text(
                        'kcal',
                        style: TextStyle(color: Color(0xFF64748B), fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterTracker(BuildContext context, DashboardSummary data) {
    final glasses = data.todayWaterGlasses;
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.water_drop_rounded, color: Color(0xFF38BDF8), size: 18),
              const SizedBox(width: 8),
              Text('Water', style: Theme.of(context).textTheme.titleMedium),
              const Spacer(),
              Text(
                '$glasses / $_waterGoal glasses',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: () => _addWater(glasses),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
                  ),
                  child: const Text(
                    '+ Add',
                    style: TextStyle(
                      color: Color(0xFF38BDF8),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List.generate(
              _waterGoal,
              (i) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  i < glasses ? Icons.water_drop_rounded : Icons.water_drop_outlined,
                  color: i < glasses
                      ? const Color(0xFF38BDF8)
                      : const Color(0xFF38BDF8).withValues(alpha: 0.22),
                  size: 26,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChart(BuildContext context, DashboardSummary data) {
    final todayStr = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return GlassCard(
      padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
      child: SizedBox(
        height: 200,
        child: BarChart(
          BarChartData(
            alignment: BarChartAlignment.spaceAround,
            gridData: const FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              handleBuiltInTouches: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => const Color(0xFF1E293B),
                tooltipBorderRadius: BorderRadius.circular(8),
                tooltipBorder: const BorderSide(color: Color(0xFF38BDF8), width: 1),
                getTooltipItem: (group, groupIndex, rod, rodIndex) {
                  if (groupIndex >= data.weekly.length) return null;
                  final day = data.weekly[groupIndex];
                  return BarTooltipItem(
                    '${DateFormat('EEE').format(day.day)}\n${NumberFormat('#,###').format(day.steps)} steps',
                    const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (value, meta) {
                    final idx = value.toInt();
                    if (idx < 0 || idx >= data.weekly.length) return const SizedBox.shrink();
                    final isToday = DateFormat('yyyy-MM-dd').format(data.weekly[idx].day) == todayStr;
                    return Text(
                      DateFormat('E').format(data.weekly[idx].day),
                      style: TextStyle(
                        color: isToday ? const Color(0xFFFACC15) : const Color(0xFF64748B),
                        fontSize: 11,
                        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                      ),
                    );
                  },
                ),
              ),
            ),
            barGroups: data.weekly.asMap().entries.map((entry) {
              final isToday = DateFormat('yyyy-MM-dd').format(entry.value.day) == todayStr;
              return BarChartGroupData(
                x: entry.key,
                barRods: [
                  BarChartRodData(
                    toY: entry.value.steps.toDouble(),
                    width: 18,
                    borderRadius: BorderRadius.circular(6),
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: isToday
                          ? [const Color(0xFFFACC15).withValues(alpha: 0.7), const Color(0xFFFACC15)]
                          : [const Color(0xFF38BDF8).withValues(alpha: 0.5), const Color(0xFF38BDF8)],
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _loadingCard({double height = 220}) {
    return GlassCard(
      child: SizedBox(
        height: height,
        child: const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

