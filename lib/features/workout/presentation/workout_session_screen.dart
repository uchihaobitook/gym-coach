import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_coach/core/services/rest_timer_service.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/core/utils/reps_parser.dart';
import 'package:gym_coach/core/widgets/animated_progress_bar.dart';
import 'package:gym_coach/core/widgets/empty_state.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/core/widgets/rest_timer_sheet.dart';
import 'package:gym_coach/data/models/app_settings.dart';
import 'package:gym_coach/data/models/program_models.dart';
import 'package:gym_coach/data/models/workout_log.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/active_workout_provider.dart';
import 'package:gym_coach/providers/program_provider.dart';
import 'package:gym_coach/providers/rest_timer_provider.dart';
import 'package:gym_coach/providers/settings_provider.dart';

import 'widgets/exercise_session_card.dart';

class WorkoutSessionScreen extends ConsumerStatefulWidget {
  const WorkoutSessionScreen({super.key, required this.dayId});

  final String dayId;

  @override
  ConsumerState<WorkoutSessionScreen> createState() =>
      _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends ConsumerState<WorkoutSessionScreen> {
  WorkoutDayTemplate? _day;
  int _weekNumber = 1;
  bool _initializing = true;
  String? _error;
  bool _restSheetOpen = false;

  RestTimerService? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _initSession());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initSession() async {
    try {
      final program = await ref.read(workoutProgramProvider.future);
      final day = program.findDay(widget.dayId);
      if (day == null) {
        if (mounted) {
          setState(() {
            _error = context.l10n.workoutDayNotFound;
            _initializing = false;
          });
        }
        return;
      }

      var weekNumber = 1;
      for (final week in program.weeks) {
        if (week.days.any((d) => d.id == widget.dayId)) {
          weekNumber = week.weekNumber;
          break;
        }
      }

      await ref
          .read(activeWorkoutProvider.notifier)
          .startFromDay(day, weekNumber);

      if (mounted) {
        setState(() {
          _day = day;
          _weekNumber = weekNumber;
          _initializing = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _initializing = false;
        });
      }
    }
  }

  /// Starts the rest timer for [restSeconds] and opens the rest sheet. This
  /// is the single place that owns starting the rest timer — the notifier
  /// only ever reports how long to rest for.
  Future<void> _showRestTimer(int restSeconds) async {
    if (_restSheetOpen) return;
    final settings = ref.read(settingsProvider).value;
    final timer = ref.read(restTimerServiceProvider);
    _timer = timer;

    timer.start(
      restSeconds,
      soundEnabled: settings?.soundEnabled ?? true,
      vibrateEnabled: settings?.vibrateEnabled ?? true,
    );

    await _openRestSheet();
  }

  /// Opens the rest sheet for the currently running timer (used by both
  /// [_showRestTimer] and the floating mini-bar tap) without starting a new
  /// countdown.
  Future<void> _openRestSheet() async {
    if (_restSheetOpen) return;
    final settings = ref.read(settingsProvider).value;
    final timer = ref.read(restTimerServiceProvider);
    _timer = timer;

    setState(() => _restSheetOpen = true);
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return ListenableBuilder(
          listenable: timer,
          builder: (context, _) {
            if (timer.remaining <= 0 && !timer.isRunning) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (Navigator.of(sheetContext).canPop()) {
                  Navigator.of(sheetContext).pop();
                }
              });
            }
            return RestTimerSheet(
              remainingSeconds:
                  timer.remaining > 0 ? timer.remaining : timer.totalSeconds,
              totalSeconds: timer.totalSeconds,
              isPaused: timer.isPaused,
              onPause: timer.pause,
              onResume: timer.resume,
              onSkip: () {
                timer.cancel();
                Navigator.of(sheetContext).pop();
              },
              onPreset: (seconds) => timer.start(
                seconds,
                soundEnabled: settings?.soundEnabled ?? true,
                vibrateEnabled: settings?.vibrateEnabled ?? true,
              ),
            );
          },
        );
      },
    );

    if (mounted) setState(() => _restSheetOpen = false);
  }

  Future<void> _confirmFinish(WorkoutLog log) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.finishConfirmTitle),
        content: Text(l10n.finishConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    await _finishWorkout(log);
  }

  Future<void> _finishWorkout(WorkoutLog log) async {
    final completed =
        await ref.read(activeWorkoutProvider.notifier).finishWorkout(log.notes);
    if (completed != null && mounted) {
      context.go('/summary/${completed.id}');
    }
  }

  Future<void> _confirmDiscard() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.discardConfirmTitle),
        content: Text(l10n.discardConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.discardWorkout),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(activeWorkoutProvider.notifier).discardSession();
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final settings = ref.watch(settingsProvider).value;
    final log = ref.watch(activeWorkoutProvider);
    final timer = ref.read(restTimerServiceProvider);
    final l10n = context.l10n;

    if (_initializing) {
      return Scaffold(body: LoadingView(message: l10n.startingWorkout));
    }

    if (_error != null || _day == null) {
      return Scaffold(
        appBar: AppBar(),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.workoutUnavailable,
          subtitle: _error ?? l10n.unknownError,
          actionLabel: l10n.goBack,
          onAction: () => context.pop(),
        ),
      );
    }

    if (log == null) {
      return const Scaffold(body: LoadingView());
    }

    final templates = _day!.exercises;
    final exerciseById = {
      for (final exercise in log.exercises) exercise.exerciseId: exercise,
    };
    final elapsed = Formatters.formatDuration(log.duration);

    return ListenableBuilder(
      listenable: timer,
      builder: (context, _) {
        final timerRunning = timer.isRunning && !_restSheetOpen;

        return Scaffold(
          appBar: AppBar(
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_day!.name),
                Text(
                  l10n.weekElapsed(_weekNumber, elapsed),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: gymTheme.secondaryText,
                      ),
                ),
              ],
            ),
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'discard') _confirmDiscard();
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'discard',
                    child: Text(l10n.discardWorkout),
                  ),
                ],
              ),
              TextButton(
                onPressed: () => _confirmFinish(log),
                child: Text(l10n.finish),
              ),
            ],
          ),
          body: Stack(
            children: [
              ListView.builder(
                padding: EdgeInsets.fromLTRB(
                  20.w,
                  12.h,
                  20.w,
                  timerRunning ? 140.h : 100.h,
                ),
                itemCount: templates.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: 20.h),
                      child: AnimatedProgressBar(
                        completed: log.completedSets,
                        total: log.totalSets,
                      ),
                    );
                  }

                  final template = templates[index - 1];
                  final exercise = exerciseById[template.id];
                  if (exercise == null) return const SizedBox.shrink();

                  return ExerciseSessionCard(
                    template: template,
                    loggedExercise: exercise,
                    weightUnit: settings?.weightUnit ?? WeightUnit.kg,
                    initiallyExpanded: index == 1,
                    onSetToggled: (setIndex, completed) async {
                      final notifier = ref.read(activeWorkoutProvider.notifier);
                      if (completed) {
                        final currentReps = exercise.sets[setIndex].reps;
                        if (currentReps == 0) {
                          final reps = parseTargetReps(template.reps);
                          await notifier.updateReps(template.id, setIndex, reps);
                        }
                      }
                      final restSeconds = await notifier.toggleSetComplete(
                        template.id,
                        setIndex,
                      );
                      if (restSeconds != null) {
                        await _showRestTimer(restSeconds);
                      }
                    },
                    onWeightChanged: (setIndex, weight) => ref
                        .read(activeWorkoutProvider.notifier)
                        .updateWeight(template.id, setIndex, weight),
                    onRepsChanged: (setIndex, reps) => ref
                        .read(activeWorkoutProvider.notifier)
                        .updateReps(template.id, setIndex, reps),
                    onNotesChanged: (notes) => ref
                        .read(activeWorkoutProvider.notifier)
                        .updateNotes(template.id, notes),
                  );
                },
              ),
              if (timerRunning)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: _RestMiniBar(timer: timer, onTap: _openRestSheet),
                ),
            ],
          ),
          floatingActionButton: Padding(
            padding: EdgeInsets.only(bottom: timerRunning ? 64.h : 0),
            child: FloatingActionButton.extended(
              onPressed: () => _confirmFinish(log),
              icon: const Icon(Icons.flag_rounded),
              label: Text(l10n.finishWorkout),
            ),
          ),
        );
      },
    );
  }
}

class _RestMiniBar extends StatelessWidget {
  const _RestMiniBar({required this.timer, required this.onTap});

  final RestTimerService timer;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final time = Formatters.formatDuration(Duration(seconds: timer.remaining));

    return SafeArea(
      top: false,
      child: Semantics(
        button: true,
        label: l10n.restMiniBarA11y(time),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            child: Container(
              margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 12.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 12.r,
                    offset: Offset(0, 4.h),
                  ),
                ],
              ),
              child: Row(
                children: [
                  const Icon(Icons.timer_rounded, color: Colors.white),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      l10n.restTimer,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  SizedBox(width: 4.w),
                  const Icon(
                    Icons.keyboard_arrow_up_rounded,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
