import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_coach/core/constants/app_constants.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/core/widgets/empty_state.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/core/widgets/primary_button.dart';
import 'package:gym_coach/core/widgets/stat_card.dart';
import 'package:gym_coach/data/models/workout_log.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/program_provider.dart';
import 'package:gym_coach/providers/repository_providers.dart';
import 'package:gym_coach/providers/settings_provider.dart';

final workoutSummaryLogProvider =
    FutureProvider.family<WorkoutLog?, String>((ref, logId) {
  return ref.read(workoutRepositoryProvider).getLogById(logId);
});

class WorkoutSummaryScreen extends ConsumerStatefulWidget {
  const WorkoutSummaryScreen({super.key, required this.logId});

  final String logId;

  @override
  ConsumerState<WorkoutSummaryScreen> createState() =>
      _WorkoutSummaryScreenState();
}

class _WorkoutSummaryScreenState extends ConsumerState<WorkoutSummaryScreen> {
  final _notesController = TextEditingController();
  bool _saving = false;
  String? _initializedLogId;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _syncNotes(WorkoutLog log) {
    if (_initializedLogId == log.id) return;
    _initializedLogId = log.id;
    _notesController.text = log.notes;
  }

  Future<void> _save(WorkoutLog log) async {
    setState(() => _saving = true);
    final updated = log.copyWith(notes: _notesController.text.trim());
    if (updated.notes != log.notes) {
      await ref.read(workoutRepositoryProvider).saveLog(updated);
      ref.invalidate(workoutSummaryLogProvider(widget.logId));
    }
    await _advanceProgramProgress(ref, updated);
    if (!mounted) return;
    setState(() => _saving = false);
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final logAsync = ref.watch(workoutSummaryLogProvider(widget.logId));
    final settings = ref.watch(settingsProvider).value;
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final unit = settings?.weightUnit;
    final l10n = context.l10n;

    return logAsync.when(
      loading: () => Scaffold(
        appBar: AppBar(title: Text(l10n.summary)),
        body: LoadingView(message: l10n.loadingSummary),
      ),
      error: (e, _) => Scaffold(
        appBar: AppBar(title: Text(l10n.summary)),
        body: EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.couldNotLoadSummary,
          subtitle: e.toString(),
          actionLabel: l10n.goHome,
          onAction: () => context.go('/home'),
        ),
      ),
      data: (log) {
        if (log == null) {
          return Scaffold(
            appBar: AppBar(title: Text(l10n.summary)),
            body: EmptyState(
              icon: Icons.fitness_center_outlined,
              title: l10n.workoutNotFound,
              subtitle: l10n.workoutNotFoundSubtitle,
              actionLabel: l10n.goHome,
              onAction: () => context.go('/home'),
            ),
          );
        }

        final calories = log.caloriesEstimate > 0
            ? log.caloriesEstimate.round()
            : (log.duration.inMinutes * AppConstants.caloriesPerMinute).round();

        _syncNotes(log);

        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.workoutComplete),
            automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 32.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 88.w,
                    height: 88.w,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.primary, AppColors.accent],
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.4),
                          blurRadius: 24.r,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.emoji_events_rounded,
                      size: 44.sp,
                      color: Colors.white,
                    ),
                  )
                      .animate(onPlay: (c) => c.repeat(reverse: true))
                      .scale(
                        begin: const Offset(1, 1),
                        end: const Offset(1.06, 1.06),
                        duration: 1200.ms,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 500.ms)
                    .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 600.ms,
                      curve: Curves.elasticOut,
                    ),
                SizedBox(height: 20.h),
                Text(
                  l10n.greatWork,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 200.ms),
                SizedBox(height: 6.h),
                Text(
                  log.dayName,
                  style: textTheme.bodyLarge?.copyWith(
                    color: gymTheme.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(delay: 300.ms),
                SizedBox(height: 28.h),
                StatCard(
                  icon: Icons.timer_outlined,
                  label: l10n.duration,
                  value: Formatters.formatDuration(log.duration),
                  accentColor: AppColors.primary,
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.08, end: 0),
                SizedBox(height: 12.h),
                StatCard(
                  icon: Icons.monitor_weight_outlined,
                  label: l10n.totalVolume,
                  value: Formatters.formatVolume(log.totalVolume, unit: unit),
                  accentColor: AppColors.accent,
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.08, end: 0),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: GymCard(
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          children: [
                            Text(
                              '${log.exercisesCompleted}',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                            Text(
                              l10n.exercises,
                              style: textTheme.labelSmall?.copyWith(
                                color: gymTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GymCard(
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          children: [
                            Text(
                              '${log.prCount}',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.prGold,
                              ),
                            ),
                            Text(
                              l10n.prs,
                              style: textTheme.labelSmall?.copyWith(
                                color: gymTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GymCard(
                        padding: EdgeInsets.all(14.w),
                        child: Column(
                          children: [
                            Text(
                              '$calories',
                              style: textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: AppColors.warning,
                              ),
                            ),
                            Text(
                              l10n.calories,
                              style: textTheme.labelSmall?.copyWith(
                                color: gymTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ).animate().fadeIn(delay: 450.ms),
                SizedBox(height: 20.h),
                TextField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.sessionNotes,
                    hintText: l10n.sessionNotesHint,
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 24.h),
                PrimaryButton(
                  label: l10n.saveAndGoHome,
                  icon: Icons.check_rounded,
                  isLoading: _saving,
                  onPressed: () => _save(log),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _advanceProgramProgress(WidgetRef ref, WorkoutLog log) async {
    try {
      final program = await ref.read(workoutProgramProvider.future);
      final weekIndex =
          program.weeks.indexWhere((w) => w.days.any((d) => d.id == log.dayId));
      if (weekIndex < 0) return;

      final week = program.weeks[weekIndex];
      final finishedIndex = week.days.indexWhere((d) => d.id == log.dayId);
      if (finishedIndex < 0) return;

      var dayIndex = finishedIndex + 1;
      var weekNumber = week.weekNumber;
      if (dayIndex >= week.days.length) {
        dayIndex = 0;
        weekNumber =
            weekIndex + 1 >= program.weeks.length ? 1 : weekNumber + 1;
      }
      await ref.read(settingsProvider.notifier).setCurrentWeek(weekNumber);
      await ref.read(settingsProvider.notifier).setCurrentDay(dayIndex);
    } catch (_) {
      // Non-fatal if program progress cannot be advanced.
    }
  }
}
