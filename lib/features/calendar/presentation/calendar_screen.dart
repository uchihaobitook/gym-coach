import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/progress_ring.dart';
import 'package:gym_coach/data/models/workout_log.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/workout_logs_provider.dart';
import 'package:intl/intl.dart';

class CalendarScreen extends ConsumerStatefulWidget {
  const CalendarScreen({super.key});

  @override
  ConsumerState<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends ConsumerState<CalendarScreen> {
  late DateTime _focusedMonth;
  DateTime? _selectedDay;
  WorkoutLog? _selectedLog;

  @override
  void initState() {
    super.initState();
    _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
    _selectedDay = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _focusedMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1);
    });
  }

  DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

  WorkoutLog? _logForDay(DateTime day, List<WorkoutLog> logs) {
    final target = _dateOnly(day);
    for (final log in logs) {
      if (!log.isCompleted) continue;
      final ended = log.endedAt ?? log.startedAt;
      if (_dateOnly(ended) == target) return log;
    }
    return null;
  }

  bool _isScheduledMissed(DateTime day, Set<DateTime> completedDates) {
    // Program is not daily Mon–Sat — do not invent "missed" days.
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final logs = ref.watch(workoutLogsProvider).value ?? const [];
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final localeName = l10n.localeName;
    final monthLabel = DateFormat('MMMM yyyy', localeName).format(_focusedMonth);

    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateUtils.getDaysInMonth(_focusedMonth.year, _focusedMonth.month);
    final startWeekday = firstOfMonth.weekday % 7;
    final totalCells = ((startWeekday + daysInMonth) / 7).ceil() * 7;

    final weekdayLabels = List.generate(7, (i) {
      final date = DateTime(2024, 1, 7 + i);
      return DateFormat('E', localeName).format(date).substring(0, 1);
    });

    return Scaffold(
      appBar: AppBar(title: Text(l10n.trainingCalendar)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        children: [
          GymCard(
            child: Row(
              children: [
                ProgressRing(
                  progress: stats.currentStreak > 0
                      ? (stats.currentStreak / 30).clamp(0.0, 1.0)
                      : 0,
                  size: 72.w,
                  strokeWidth: 6.w,
                  color: AppColors.warning,
                  showPercentage: false,
                  centerLabel: '${stats.currentStreak}',
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.currentStreak,
                        style: textTheme.labelMedium?.copyWith(
                          color: gymTheme.secondaryText,
                        ),
                      ),
                      Text(
                        l10n.streakDays(stats.currentStreak),
                        style: textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.longestStreakLabel(stats.longestStreak),
                        style: textTheme.bodySmall?.copyWith(
                          color: gymTheme.secondaryText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms),
          SizedBox(height: 20.h),
          Row(
            children: [
              IconButton(onPressed: _previousMonth, icon: const Icon(Icons.chevron_left_rounded)),
              Expanded(
                child: Text(
                  monthLabel,
                  style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
              ),
              IconButton(onPressed: _nextMonth, icon: const Icon(Icons.chevron_right_rounded)),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: weekdayLabels
                .map(
                  (d) => Expanded(
                    child: Center(
                      child: Text(
                        d,
                        style: textTheme.labelSmall?.copyWith(
                          color: gymTheme.secondaryText,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: 8.h),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              childAspectRatio: 1,
              mainAxisExtent: 48.h.clamp(48.0, 64.0),
            ),
            itemCount: totalCells,
            itemBuilder: (context, index) {
              final dayOffset = index - startWeekday + 1;
              if (dayOffset < 1 || dayOffset > daysInMonth) {
                return const SizedBox.shrink();
              }

              final date = DateTime(_focusedMonth.year, _focusedMonth.month, dayOffset);
              final dateOnly = _dateOnly(date);
              final completed = stats.completedDates.contains(dateOnly);
              final missed = _isScheduledMissed(date, stats.completedDates);
              final isSelected = _selectedDay != null &&
                  _dateOnly(_selectedDay!) == dateOnly;
              final isToday = dateOnly == _dateOnly(DateTime.now());

              Color? bg;
              Color? fg;
              if (completed) {
                bg = gymTheme.success.withValues(alpha: 0.2);
                fg = gymTheme.success;
              } else if (missed) {
                bg = gymTheme.danger.withValues(alpha: 0.12);
                fg = gymTheme.danger;
              }

              return Padding(
                padding: EdgeInsets.all(3.w),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedDay = date;
                        _selectedLog = _logForDay(date, logs);
                      });
                    },
                    borderRadius: BorderRadius.circular(12.r),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primary.withValues(alpha: 0.25)
                            : bg,
                        borderRadius: BorderRadius.circular(12.r),
                        border: isToday
                            ? Border.all(color: AppColors.primary, width: 1.5)
                            : isSelected
                                ? Border.all(color: AppColors.primary)
                                : null,
                      ),
                      child: Center(
                        child: Text(
                          '$dayOffset',
                          style: textTheme.labelLarge?.copyWith(
                            fontWeight: isToday ? FontWeight.w800 : FontWeight.w600,
                            color: fg ?? (isSelected ? AppColors.primary : null),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _LegendDot(color: gymTheme.success, label: l10n.legendCompleted),
              SizedBox(width: 16.w),
              _LegendDot(color: AppColors.primary, label: l10n.legendToday),
            ],
          ),
          SizedBox(height: 20.h),
          if (_selectedDay != null) ...[
            Text(
              Formatters.formatMediumDate(_selectedDay!, l10n: l10n),
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 10.h),
            if (_selectedLog != null)
              GymCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedLog!.dayName,
                      style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      _selectedLog!.muscleGroup,
                      style: textTheme.bodyMedium?.copyWith(color: gymTheme.secondaryText),
                    ),
                    SizedBox(height: 12.h),
                    Row(
                      children: [
                        _InfoPill(
                          icon: Icons.timer_outlined,
                          label: Formatters.formatDuration(_selectedLog!.duration),
                        ),
                        SizedBox(width: 8.w),
                        _InfoPill(
                          icon: Icons.check_circle_outline,
                          label: l10n.setsCount(_selectedLog!.completedSets),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            else
              GymCard(
                child: Text(
                  stats.completedDates.contains(_dateOnly(_selectedDay!))
                      ? l10n.restDayElsewhere
                      : l10n.noWorkoutThisDay,
                  style: textTheme.bodyMedium?.copyWith(color: gymTheme.secondaryText),
                ),
              ),
          ],
        ],
      ),
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
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(label, style: Theme.of(context).textTheme.labelSmall),
      ],
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: gymTheme.elevatedSurface,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14.sp, color: gymTheme.secondaryText),
          SizedBox(width: 4.w),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
