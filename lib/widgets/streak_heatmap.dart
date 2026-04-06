import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/fitness_repository.dart';

class StreakHeatmap extends StatelessWidget {
  const StreakHeatmap({
    super.key,
    required this.days,
    required this.currentStreak,
  });

  final List<StreakDay> days;
  final int currentStreak;

  @override
  Widget build(BuildContext context) {
    const dayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Step Streak', style: Theme.of(context).textTheme.titleMedium),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.4)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department, color: Color(0xFFFB923C), size: 14),
                  const SizedBox(width: 4),
                  Text(
                    '$currentStreak day streak',
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Column(
                children: dayLabels
                    .map(
                      (label) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: SizedBox(
                          height: 14,
                          width: 10,
                          child: Text(
                            label,
                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 9),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(7, (weekIndex) {
                  return Column(
                    children: List.generate(7, (dayOfWeek) {
                      final index = weekIndex * 7 + dayOfWeek;
                      if (index >= days.length) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        );
                      }
                      final entry = days[index];
                      final Color color;
                      if (entry.goalMet) {
                        color = const Color(0xFF22C55E);
                      } else if (entry.steps > 0) {
                        color = const Color(0xFF38BDF8).withValues(alpha: 0.35);
                      } else {
                        color = Colors.white.withValues(alpha: 0.07);
                      }
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Tooltip(
                          message:
                              '${DateFormat('EEE, MMM d').format(entry.day)}\n${entry.steps} steps',
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: color,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                }),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            _LegendDot(color: Colors.white.withValues(alpha: 0.07), label: 'No data'),
            const SizedBox(width: 12),
            _LegendDot(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
              label: 'Partial',
            ),
            const SizedBox(width: 12),
            const _LegendDot(color: Color(0xFF22C55E), label: 'Goal met'),
          ],
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 10)),
      ],
    );
  }
}

