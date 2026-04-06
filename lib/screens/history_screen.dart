import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/fitness_repository.dart';
import '../widgets/glass_card.dart';
import '../widgets/streak_heatmap.dart';

class _HistoryData {
  const _HistoryData({
    required this.activities,
    required this.streakDays,
    required this.currentStreak,
  });

  final List<ActivityLog> activities;
  final List<StreakDay> streakDays;
  final int currentStreak;
}

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({
    super.key,
    required this.repository,
    required this.refreshTick,
    required this.onDelete,
  });

  final FitnessRepository repository;
  final int refreshTick;
  final VoidCallback onDelete;

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late Future<_HistoryData> _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetch();
  }

  @override
  void didUpdateWidget(HistoryScreen old) {
    super.didUpdateWidget(old);
    if (old.refreshTick != widget.refreshTick) {
      setState(() {
        _dataFuture = _fetch();
      });
    }
  }

  Future<_HistoryData> _fetch() async {
    final activities = await widget.repository.getActivities();
    final streakDays = await widget.repository.getStreakData();
    final streak = await widget.repository.getCurrentStreak();
    return _HistoryData(activities: activities, streakDays: streakDays, currentStreak: streak);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_HistoryData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return const Center(child: Text('Could not load history.'));
        }

        final data = snapshot.data!;

        return ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            GlassCard(
              padding: const EdgeInsets.all(16),
              child: StreakHeatmap(
                days: data.streakDays,
                currentStreak: data.currentStreak,
              ),
            ),
            const SizedBox(height: 20),
            Text('Activity Log', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 10),
            if (data.activities.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text('No activities logged yet.\nStart from the Log tab.'),
                ),
              )
            else
              ...data.activities.asMap().entries.map((entry) {
                final activity = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.fitness_center_rounded,
                              color: Color(0xFF38BDF8), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${activity.exerciseType} • ${activity.durationMinutes} min',
                                style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                DateFormat('EEE, d MMM').format(activity.loggedAt),
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  const Icon(Icons.local_fire_department,
                                      size: 13, color: Color(0xFFEF4444)),
                                  const SizedBox(width: 3),
                                  Text(
                                    '${activity.calories} kcal',
                                    style: const TextStyle(
                                        color: Color(0xFFEF4444), fontSize: 12),
                                  ),
                                  if (activity.notes.isNotEmpty) ...[
                                    const Text('  •  ',
                                        style: TextStyle(color: Color(0xFF64748B))),
                                    Flexible(
                                      child: Text(
                                        activity.notes,
                                        style: Theme.of(context).textTheme.bodySmall,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline_rounded,
                              color: Color(0xFF64748B)),
                          onPressed: () async {
                            await widget.repository.deleteActivity(activity.id);
                            widget.onDelete();
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
          ],
        );
      },
    );
  }
}

