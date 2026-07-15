import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/widgets/empty_state.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/core/widgets/muscle_chip.dart';
import 'package:gym_coach/core/widgets/section_header.dart';
import 'package:gym_coach/core/widgets/workout_day_card.dart';
import 'package:gym_coach/data/models/program_models.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/program_provider.dart';
import 'package:gym_coach/providers/workout_logs_provider.dart';

class WeekScreen extends ConsumerStatefulWidget {
  const WeekScreen({super.key});

  @override
  ConsumerState<WeekScreen> createState() => _WeekScreenState();
}

class _WeekScreenState extends ConsumerState<WeekScreen> {
  late PageController _pageController;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    final initialWeek = ref.read(selectedWeekProvider) - 1;
    _currentPage = initialWeek < 0 ? 0 : initialWeek;
    _pageController = PageController(initialPage: _currentPage);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectWeek(int week) {
    final index = week - 1;
    setState(() => _currentPage = index);
    ref.read(selectedWeekProvider.notifier).select(week);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final programAsync = ref.watch(workoutProgramProvider);
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navWorkouts),
        centerTitle: false,
      ),
      body: programAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.programUnavailable,
          subtitle: e.toString(),
          actionLabel: l10n.retry,
          onAction: () => ref.invalidate(workoutProgramProvider),
        ),
        data: (program) {
          final weeks = program.weeks;
          if (weeks.isEmpty) {
            return EmptyState(
              icon: Icons.fitness_center_outlined,
              title: l10n.programUnavailable,
            );
          }
          final maxPage = weeks.length - 1;
          if (_currentPage > maxPage) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              setState(() => _currentPage = maxPage);
              if (_pageController.hasClients) {
                _pageController.jumpToPage(maxPage);
              }
            });
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 12.h),
                child: Row(
                  children: List.generate(weeks.length, (index) {
                    final weekNum = index + 1;
                    final selected = _currentPage == index;
                    return Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: _WeekChip(
                          label: l10n.weekNumber(weekNum),
                          subtitle: weeks[index].title,
                          selected: selected,
                          onTap: () => _selectWeek(weekNum),
                        ),
                      ),
                    );
                  }),
                ),
              ).animate().fadeIn(duration: 350.ms),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: weeks.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    ref.read(selectedWeekProvider.notifier).select(index + 1);
                  },
                  itemBuilder: (context, index) {
                    final week = weeks[index];
                    return _WeekPage(
                      week: week,
                      onDayTap: (dayId) => context.push('/workout/$dayId'),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _WeekChip extends StatelessWidget {
  const _WeekChip({
    required this.label,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 8.w),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.primary.withValues(alpha: 0.18)
                : gymTheme.elevatedSurface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(
              color: selected ? AppColors.primary : gymTheme.border,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: selected ? AppColors.primary : null,
                    ),
              ),
              SizedBox(height: 2.h),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                      color: gymTheme.secondaryText,
                    ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekPage extends ConsumerWidget {
  const _WeekPage({
    required this.week,
    required this.onDayTap,
  });

  final WeekProgramTemplate week;
  final void Function(String dayId) onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gymTheme = context.gymTheme;
    final l10n = context.l10n;

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20.w, 4.h, 20.w, 24.h),
      itemCount: week.days.length + 2 + (week.focus != null ? 1 : 0),
      itemBuilder: (context, index) {
        var i = index;
        if (week.focus != null) {
          if (i == 0) {
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Text(
                week.focus!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: gymTheme.secondaryText,
                      height: 1.4,
                    ),
              ),
            );
          }
          i -= 1;
        }
        if (i == 0) {
          return SectionHeader(title: l10n.trainingDaysCount(week.days.length));
        }
        i -= 1;
        if (i < week.days.length) {
          final day = week.days[i];
          final completion = ref.watch(dayCompletionPercentProvider(day.id));
          final completed = ref.watch(isDayCompletedProvider(day.id));
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h),
            child: WorkoutDayCard(
              dayName: day.name,
              muscleGroup: day.muscleGroup,
              durationMinutes: day.estimatedMinutes,
              exerciseCount: day.exerciseCount,
              completionPercent: completion,
              isCompleted: completed,
              onTap: () => onDayTap(day.id),
            )
                .animate()
                .fadeIn(delay: (i * 60).ms, duration: 350.ms)
                .slideX(begin: 0.03, end: 0),
          );
        }
        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: week.days
                .map(
                  (d) =>
                      MuscleChip(label: d.muscleGroup.split('·').first.trim()),
                )
                .toSet()
                .toList(),
          ),
        );
      },
    );
  }
}
