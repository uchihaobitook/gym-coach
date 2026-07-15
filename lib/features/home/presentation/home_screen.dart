import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/core/utils/stats_calculator.dart';
import 'package:gym_coach/core/widgets/empty_state.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/core/widgets/progress_ring.dart';
import 'package:gym_coach/core/widgets/section_header.dart';
import 'package:gym_coach/core/widgets/stat_card.dart';
import 'package:gym_coach/data/models/app_settings.dart';
import 'package:gym_coach/data/models/program_models.dart';
import 'package:gym_coach/data/models/workout_log.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/program_provider.dart';
import 'package:gym_coach/providers/settings_provider.dart';
import 'package:gym_coach/providers/workout_logs_provider.dart';

import 'widgets/greeting_header.dart';
import 'widgets/today_workout_card.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final programAsync = ref.watch(workoutProgramProvider);
    final settingsAsync = ref.watch(settingsProvider);
    final stats = ref.watch(statsProvider);
    final logs = ref.watch(workoutLogsProvider).value ?? const [];
    final activeSession = ref.watch(activeSessionProvider);
    final l10n = context.l10n;

    return Scaffold(
      body: SafeArea(
        child: programAsync.when(
          loading: () => const LoadingView(),
          error: (e, _) => EmptyState(
            icon: Icons.error_outline_rounded,
            title: l10n.couldNotLoadProgram,
            subtitle: e.toString(),
            actionLabel: l10n.retry,
            onAction: () => ref.invalidate(workoutProgramProvider),
          ),
          data: (program) => settingsAsync.when(
            loading: () => const LoadingView(),
            error: (e, _) => EmptyState(
              icon: Icons.error_outline_rounded,
              title: l10n.settingsUnavailable,
              subtitle: e.toString(),
            ),
            data: (settings) => _HomeContent(
              settings: settings,
              stats: stats,
              weekNumber: settings.currentWeek,
              dayIndex: settings.currentDayIndex,
              programWeeks: program.weeks,
              activeSession: activeSession,
              onQuickStart: (dayId) => context.push('/workout/$dayId'),
              isDayCompleted: (dayId) =>
                  logs.any((l) => l.dayId == dayId && l.isCompleted),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeContent extends StatelessWidget {
  const _HomeContent({
    required this.settings,
    required this.stats,
    required this.weekNumber,
    required this.dayIndex,
    required this.programWeeks,
    required this.activeSession,
    required this.onQuickStart,
    required this.isDayCompleted,
  });

  final AppSettings settings;
  final WorkoutStats stats;
  final int weekNumber;
  final int dayIndex;
  final List<WeekProgramTemplate> programWeeks;
  final WorkoutLog? activeSession;
  final void Function(String dayId) onQuickStart;
  final bool Function(String dayId) isDayCompleted;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final unit = settings.weightUnit;
    final l10n = context.l10n;

    final week = programWeeks.firstWhere(
      (w) => w.weekNumber == weekNumber,
      orElse: () => programWeeks.first,
    );
    final days = week.days;
    final safeIndex = dayIndex.clamp(0, days.length - 1);
    final todayDay = days[safeIndex];

    final weekProgress = _weekCompletionPercent(days);
    final completedThisWeek = days.where((d) => isDayCompleted(d.id)).length;

    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
          sliver: SliverToBoxAdapter(
            child: GreetingHeader(
              userName: settings.userName,
              subtitle: Formatters.formatMediumDate(DateTime.now(), l10n: l10n),
            ),
          ),
        ),
        if (activeSession != null)
          SliverPadding(
            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 12.h),
            sliver: SliverToBoxAdapter(
              child: _ActiveSessionBanner(
                session: activeSession!,
                onResume: () => onQuickStart(activeSession!.dayId),
              ),
            ),
          ),
        SliverPadding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          sliver: SliverToBoxAdapter(
            child: TodayWorkoutCard(
              day: todayDay,
              weekNumber: weekNumber,
              isCompleted: isDayCompleted(todayDay.id),
              onQuickStart: () => onQuickStart(todayDay.id),
            ),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 8.h),
          sliver: SliverToBoxAdapter(
            child: GymCard(
              child: Row(
                children: [
                  ProgressRing(
                    progress: weekProgress,
                    size: 88.w,
                    centerLabel: l10n.weekNumber(weekNumber),
                  ),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _QuickStatRow(
                          icon: Icons.local_fire_department_rounded,
                          label: l10n.currentStreak,
                          value: l10n.streakDays(stats.currentStreak),
                          color: AppColors.warning,
                        ),
                        SizedBox(height: 12.h),
                        _QuickStatRow(
                          icon: Icons.check_circle_outline_rounded,
                          label: l10n.thisWeek,
                          value: l10n.weekDone(completedThisWeek, days.length),
                          color: gymTheme.success,
                        ),
                        SizedBox(height: 12.h),
                        _QuickStatRow(
                          icon: Icons.calendar_today_rounded,
                          label: l10n.totalWorkouts,
                          value: '${stats.totalWorkouts}',
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(delay: 250.ms, duration: 400.ms)
                .slideY(begin: 0.06, end: 0),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 4.h),
          sliver: SliverToBoxAdapter(
            child: SectionHeader(title: l10n.yourStatistics),
          ),
        ),
        SliverPadding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              StatCard(
                icon: Icons.fitness_center_rounded,
                label: l10n.workouts,
                value: '${stats.totalWorkouts}',
                subtitle: stats.totalWorkouts > 0 ? l10n.keepItUp : l10n.startToday,
                accentColor: AppColors.primary,
              ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.04, end: 0),
              SizedBox(height: 12.h),
              StatCard(
                icon: Icons.timer_outlined,
                label: l10n.trainingHours,
                value: stats.totalHours.toStringAsFixed(1),
                subtitle: l10n.hoursLogged,
                accentColor: AppColors.accent,
              ).animate().fadeIn(delay: 350.ms).slideX(begin: 0.04, end: 0),
              SizedBox(height: 12.h),
              StatCard(
                icon: Icons.monitor_weight_outlined,
                label: l10n.totalVolume,
                value: Formatters.formatVolume(stats.totalVolume, unit: unit),
                subtitle: l10n.allTimeLifted,
                accentColor: AppColors.warning,
              ).animate().fadeIn(delay: 400.ms).slideX(begin: 0.04, end: 0),
              if (stats.favoriteExercise != null) ...[
                SizedBox(height: 20.h),
                Text(
                  l10n.favoriteExerciseLabel(stats.favoriteExercise!),
                  style: textTheme.bodySmall?.copyWith(
                    color: gymTheme.secondaryText,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ]),
          ),
        ),
      ],
    );
  }

  double _weekCompletionPercent(List<WorkoutDayTemplate> days) {
    if (days.isEmpty) return 0;
    final completed = days.where((d) => isDayCompleted(d.id)).length;
    return completed / days.length;
  }
}

class _ActiveSessionBanner extends StatelessWidget {
  const _ActiveSessionBanner({
    required this.session,
    required this.onResume,
  });

  final WorkoutLog session;
  final VoidCallback onResume;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return GymCard(
      color: AppColors.primary.withValues(alpha: 0.12),
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.fitness_center_rounded,
              color: AppColors.primary,
              size: 22.sp,
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.dayName,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  session.muscleGroup,
                  style: textTheme.labelSmall?.copyWith(
                    color: gymTheme.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          FilledButton(
            onPressed: onResume,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: Text(l10n.resumeWorkout),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.08, end: 0, duration: 350.ms, curve: Curves.easeOut);
  }
}

class _QuickStatRow extends StatelessWidget {
  const _QuickStatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;

    return Row(
      children: [
        Icon(icon, size: 18.sp, color: color),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: gymTheme.secondaryText,
                ),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
        ),
      ],
    );
  }
}
