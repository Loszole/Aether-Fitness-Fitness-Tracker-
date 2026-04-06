import 'package:flutter/material.dart';

import '../data/fitness_repository.dart';
import '../services/step_tracking_service.dart';
import 'dashboard_screen.dart';
import 'history_screen.dart';
import 'log_activity_screen.dart';
import 'plans_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  final FitnessRepository _repository = FitnessRepository.instance;
  late final StepTrackingService _stepTrackingService;

  int _selectedIndex = 0;
  int _refreshTick = 0;

  @override
  void initState() {
    super.initState();
    _stepTrackingService = StepTrackingService(_repository);
    _startStepTracking();
  }

  Future<void> _startStepTracking() async {
    await _stepTrackingService.start(
      onSteps: (_) {
        if (mounted) {
          setState(() => _refreshTick++);
        }
      },
    );

    final stored = await _stepTrackingService.getTodayStoredSteps();
    if (stored >= 0 && mounted) {
      setState(() => _refreshTick++);
    }
  }

  @override
  void dispose() {
    _stepTrackingService.dispose();
    super.dispose();
  }

  void _forceRefresh() {
    setState(() => _refreshTick++);
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      DashboardScreen(
        repository: _repository,
        refreshTick: _refreshTick,
      ),
      LogActivityScreen(
        repository: _repository,
        onSaved: _forceRefresh,
      ),
      PlansScreen(
        repository: _repository,
        refreshTick: _refreshTick,
        onSaved: _forceRefresh,
      ),
      HistoryScreen(
        repository: _repository,
        refreshTick: _refreshTick,
        onDelete: _forceRefresh,
      ),
    ];

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: [0.0, 0.5, 1.0],
          colors: [
            Color(0xFF0F172A),
            Color(0xFF0D1E33),
            Color(0xFF0A1628),
          ],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Aether Fitness'),
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: screens,
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) {
            setState(() => _selectedIndex = index);
          },
          destinations: const [
            NavigationDestination(icon: Icon(Icons.dashboard_rounded), label: 'Dashboard'),
            NavigationDestination(icon: Icon(Icons.add_circle_outline_rounded), label: 'Log'),
            NavigationDestination(icon: Icon(Icons.flag_rounded), label: 'Plans'),
            NavigationDestination(icon: Icon(Icons.history_rounded), label: 'History'),
          ],
        ),
      ),
    );
  }
}
