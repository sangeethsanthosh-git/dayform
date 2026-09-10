import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/notifications/notification_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/models/focus_session.dart';
import '../../../domain/models/task_item.dart';
import '../../../domain/repositories/focus_repository.dart';

class FocusTimerModule extends StatefulWidget {
  final List<TaskItem> tasks;
  final FocusRepository focusRepo;

  const FocusTimerModule({
    super.key,
    required this.tasks,
    required this.focusRepo,
  });

  @override
  State<FocusTimerModule> createState() => _FocusTimerModuleState();
}

class _FocusTimerModuleState extends State<FocusTimerModule> {
  int _selectedDurationMinutes = 25;
  int _secondsRemaining = 25 * 60;
  bool _isRunning = false;
  Timer? _timer;
  TaskItem? _linkedTask;
  DateTime? _sessionStart;
  List<FocusSession> _recentSessions = [];

  @override
  void initState() {
    super.initState();
    _loadRecentSessions();
  }

  Future<void> _loadRecentSessions() async {
    final sessions = await widget.focusRepo.getRecentSessions();
    if (mounted) {
      setState(() {
        _recentSessions = sessions;
      });
    }
  }

  void _startTimer() {
    setState(() {
      _isRunning = true;
      _sessionStart = DateTime.now();
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_secondsRemaining > 0) {
        setState(() {
          _secondsRemaining--;
        });
      } else {
        _completeTimer();
      }
    });
  }

  void _pauseTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _selectedDurationMinutes * 60;
    });
  }

  void _completeTimer() async {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
      _secondsRemaining = _selectedDurationMinutes * 60;
    });

    final session = FocusSession(
      id: const Uuid().v4(),
      linkedTaskId: _linkedTask?.id,
      taskTitle: _linkedTask?.title,
      durationMinutes: _selectedDurationMinutes,
      startedAt: _sessionStart ?? DateTime.now(),
      completedAt: DateTime.now(),
      wasInterrupted: false,
    );

    await widget.focusRepo.logSession(session);
    await NotificationService.instance.sendImmediateTestNotification();
    _loadRecentSessions();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Focus session completed! Great work!')),
      );
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final minutes = (_secondsRemaining ~/ 60).toString().padLeft(2, '0');
    final seconds = (_secondsRemaining % 60).toString().padLeft(2, '0');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Timer Dial Container
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
              borderRadius: BorderRadius.circular(AppConstants.cardRadiusLarge),
              border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
            ),
            child: Column(
              children: [
                // Preset Duration Chips
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [15, 25, 45, 60].map((mins) {
                    final isSel = _selectedDurationMinutes == mins;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text('${mins}m'),
                        selected: isSel,
                        selectedColor: AppColors.warmAmber,
                        labelStyle: TextStyle(
                          fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                          color: isSel ? Colors.white : null,
                        ),
                        onSelected: (selected) {
                          if (selected && !_isRunning) {
                            setState(() {
                              _selectedDurationMinutes = mins;
                              _secondsRemaining = mins * 60;
                            });
                          }
                        },
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 24),

                // Large Time Display
                Text(
                  '$minutes:$seconds',
                  style: const TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -2,
                  ),
                ),
                const SizedBox(height: 8),

                // Linked Task Indicator
                if (_linkedTask != null)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.warmAmber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Focusing on: ${_linkedTask!.title}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(height: 24),

                // Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton.filledTonal(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh_rounded),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : _startTimer,
                      icon: Icon(_isRunning ? Icons.pause_rounded : Icons.play_arrow_rounded),
                      label: Text(_isRunning ? 'Pause' : 'Start Focus'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.warmAmber,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Link Task Dropdown
          if (!_isRunning && widget.tasks.isNotEmpty) ...[
            DropdownButtonFormField<TaskItem>(
              value: _linkedTask,
              decoration: const InputDecoration(
                labelText: 'Link Focus to Task (Optional)',
                prefixIcon: Icon(Icons.link_rounded),
              ),
              items: widget.tasks.map((t) {
                return DropdownMenuItem(value: t, child: Text(t.title, overflow: TextOverflow.ellipsis));
              }).toList(),
              onChanged: (t) => setState(() => _linkedTask = t),
            ),
            const SizedBox(height: 20),
          ],

          // Completion History
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Focus Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text('${_recentSessions.length} completed', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
          const SizedBox(height: 10),

          if (_recentSessions.isEmpty)
            const Text('No focus sessions logged yet.')
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recentSessions.length.clamp(0, 5),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final s = _recentSessions[index];
                return ListTile(
                  tileColor: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  leading: Icon(Icons.timer_rounded, color: AppColors.warmAmber),
                  title: Text(s.taskTitle ?? 'General Focus Session'),
                  subtitle: Text(DateFormat('d MMM, h:mm a').format(s.startedAt)),
                  trailing: Text('${s.durationMinutes}m', style: const TextStyle(fontWeight: FontWeight.bold)),
                );
              },
            ),
        ],
      ),
    );
  }
}
