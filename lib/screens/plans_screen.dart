import 'package:flutter/material.dart';

import '../data/fitness_repository.dart';
import '../widgets/glass_card.dart';

class PlansScreen extends StatefulWidget {
  const PlansScreen({
    super.key,
    required this.repository,
    required this.refreshTick,
    required this.onSaved,
  });

  final FitnessRepository repository;
  final int refreshTick;
  final VoidCallback onSaved;

  @override
  State<PlansScreen> createState() => _PlansScreenState();
}

class _PlansScreenState extends State<PlansScreen> {
  Future<void> _openCreatePlanDialog() async {
    final titleController = TextEditingController();
    final stepsController = TextEditingController(text: '10000');
    final workoutsController = TextEditingController(text: '5');
    final caloriesController = TextEditingController(text: '1800');
    int restDays = 1;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create Fitness Plan'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(labelText: 'Plan name'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: stepsController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Daily step target'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: workoutsController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Weekly workout target'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: caloriesController,
                      keyboardType: TextInputType.number,
                      decoration:
                          const InputDecoration(labelText: 'Weekly calories target'),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.bed_rounded, size: 18, color: Color(0xFF38BDF8)),
                        const SizedBox(width: 8),
                        Text('Rest days/week: $restDays',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                    Slider(
                      value: restDays.toDouble(),
                      min: 0,
                      max: 7,
                      divisions: 7,
                      label: '$restDays day${restDays == 1 ? '' : 's'}',
                      onChanged: (value) =>
                          setDialogState(() => restDays = value.round()),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                FilledButton(
                  onPressed: () async {
                    final navigator = Navigator.of(context);
                    final title = titleController.text.trim();
                    final steps = int.tryParse(stepsController.text.trim()) ?? 0;
                    final workouts =
                        int.tryParse(workoutsController.text.trim()) ?? 0;
                    final calories =
                        int.tryParse(caloriesController.text.trim()) ?? 0;

                    if (title.isEmpty || steps <= 0 || workouts <= 0 || calories <= 0) {
                      return;
                    }

                    await widget.repository.addPlan(
                      title: title,
                      targetSteps: steps,
                      targetWorkouts: workouts,
                      targetCalories: calories,
                      restDaysPerWeek: restDays,
                    );

                    if (!mounted) return;
                    widget.onSaved();
                    navigator.pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<FitnessPlan>>(
      future: widget.repository.getPlans(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        final plans = snapshot.data ?? [];

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Fitness Plans',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                FilledButton.icon(
                  onPressed: _openCreatePlanDialog,
                  icon: const Icon(Icons.add),
                  label: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            if (plans.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Column(
                    children: [
                      Icon(
                        Icons.directions_run_rounded,
                        size: 72,
                        color: const Color(0xFF38BDF8).withValues(alpha: 0.25),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No plans yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF64748B),
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Tap "Add" above to create\nyour first fitness plan.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFF475569), fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ...plans.map(
              (plan) => GlassCard(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(plan.title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text('Daily steps target: ${plan.targetSteps}'),
                    Text('Weekly workouts target: ${plan.targetWorkouts}'),
                    Text('Weekly calories target: ${plan.targetCalories} kcal'),
                    Text(
                      'Rest days/week: ${plan.restDaysPerWeek} 🛌',
                      style: const TextStyle(color: Color(0xFF38BDF8)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Text('Active'),
                        const SizedBox(width: 8),
                        Switch(
                          value: plan.isActive,
                          onChanged: (value) async {
                            await widget.repository.setPlanActive(plan.id, value);
                            widget.onSaved();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

