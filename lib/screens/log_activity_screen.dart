import 'package:flutter/material.dart';

import '../data/fitness_repository.dart';
import '../widgets/glass_card.dart';

class LogActivityScreen extends StatefulWidget {
  const LogActivityScreen({
    super.key,
    required this.repository,
    required this.onSaved,
  });

  final FitnessRepository repository;
  final VoidCallback onSaved;

  @override
  State<LogActivityScreen> createState() => _LogActivityScreenState();
}

class _LogActivityScreenState extends State<LogActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _durationController = TextEditingController();
  final _calorieController = TextEditingController();
  final _notesController = TextEditingController();

  String _exerciseType = 'Walking';
  DateTime _selectedDate = DateTime.now();
  bool _isSaving = false;

  void _quickLog(String type, int duration, int calories) {
    setState(() {
      _exerciseType = type;
      _durationController.text = duration.toString();
      _calorieController.text = calories.toString();
    });
  }

  @override
  void dispose() {
    _durationController.dispose();
    _calorieController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() => _isSaving = true);

    final duration = int.parse(_durationController.text.trim());
    final calories = int.parse(_calorieController.text.trim());

    await widget.repository.addActivity(
      exerciseType: _exerciseType,
      durationMinutes: duration,
      calories: calories,
      loggedAt: _selectedDate,
      notes: _notesController.text.trim(),
    );

    if (!mounted) {
      return;
    }

    widget.onSaved();
    setState(() => _isSaving = false);
    _durationController.clear();
    _calorieController.clear();
    _notesController.clear();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity saved locally.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('Log Activity', style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 14),
        GlassCard(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.bolt_rounded, color: Color(0xFFFACC15), size: 16),
                  const SizedBox(width: 6),
                  Text('Quick Log', style: Theme.of(context).textTheme.titleMedium),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _QuickChip(label: '🏃 Running', onTap: () => _quickLog('Running', 30, 300)),
                  _QuickChip(label: '💪 Gym', onTap: () => _quickLog('Gym', 45, 350)),
                  _QuickChip(label: '🧘 Yoga', onTap: () => _quickLog('Yoga', 30, 180)),
                  _QuickChip(label: '🚴 Cycling', onTap: () => _quickLog('Cycling', 30, 250)),
                  _QuickChip(label: '🚶 Walking', onTap: () => _quickLog('Walking', 20, 100)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Form(
          key: _formKey,
          child: Column(
            children: [
              DropdownButtonFormField<String>(
                initialValue: _exerciseType,
                decoration: const InputDecoration(
                  labelText: 'Exercise type',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'Walking', child: Text('Walking')),
                  DropdownMenuItem(value: 'Running', child: Text('Running')),
                  DropdownMenuItem(value: 'Cycling', child: Text('Cycling')),
                  DropdownMenuItem(value: 'Gym', child: Text('Gym')),
                  DropdownMenuItem(value: 'Yoga', child: Text('Yoga')),
                  DropdownMenuItem(value: 'Other', child: Text('Other')),
                ],
                onChanged: (value) => setState(() => _exerciseType = value ?? 'Walking'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _durationController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Workout time (minutes)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter duration';
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Use a valid positive number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _calorieController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calories burned',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Enter calories';
                  }
                  final parsed = int.tryParse(value.trim());
                  if (parsed == null || parsed < 0) {
                    return 'Use a valid number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2024),
                    lastDate: DateTime.now().add(const Duration(days: 1)),
                  );
                  if (picked != null) {
                    setState(() => _selectedDate = picked);
                  }
                },
                icon: const Icon(Icons.calendar_today),
                label: Text('Date: ${_selectedDate.toLocal().toString().split(' ').first}'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isSaving ? null : _save,
                  child: Text(_isSaving ? 'Saving...' : 'Save Activity'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickChip extends StatelessWidget {
  const _QuickChip({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.35)),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 13, color: Color(0xFF38BDF8)),
        ),
      ),
    );
  }
}

