import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/section_header.dart';
import 'package:gym_coach/core/widgets/stat_card.dart';
import 'package:gym_coach/data/models/workout_log.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/settings_provider.dart';
import 'package:gym_coach/providers/workout_logs_provider.dart';
import 'package:intl/intl.dart';

class StatisticsScreen extends ConsumerStatefulWidget {
  const StatisticsScreen({super.key});

  @override
  ConsumerState<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends ConsumerState<StatisticsScreen> {
  bool _showVolumeChart = true;

  @override
  Widget build(BuildContext context) {
    final stats = ref.watch(statsProvider);
    final logs = ref.watch(workoutLogsProvider).value ?? const [];
    final settings = ref.watch(settingsProvider).value;
    final gymTheme = context.gymTheme;
    final l10n = context.l10n;
    final localeName = l10n.localeName;

    final completed = logs.where((l) => l.isCompleted).toList();
    final weeklyData = _buildWeeklyData(completed, localeName);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.statistics)),
      body: ListView(
        padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
        children: [
          _AnimatedCounterCard(
            icon: Icons.fitness_center_rounded,
            label: l10n.totalWorkouts,
            target: stats.totalWorkouts.toDouble(),
            format: (v) => v.round().toString(),
            accentColor: AppColors.primary,
          ).animate().fadeIn(duration: 400.ms),
          SizedBox(height: 12.h),
          _AnimatedCounterCard(
            icon: Icons.timer_outlined,
            label: l10n.trainingHours,
            target: stats.totalHours,
            format: (v) => v.toStringAsFixed(1),
            accentColor: AppColors.accent,
          ).animate().fadeIn(delay: 80.ms, duration: 400.ms),
          SizedBox(height: 12.h),
          StatCard(
            icon: Icons.star_rounded,
            label: l10n.favoriteExercise,
            value: stats.favoriteExercise ?? '—',
            subtitle: l10n.mostLogged,
            accentColor: AppColors.warning,
          ).animate().fadeIn(delay: 120.ms),
          SizedBox(height: 12.h),
          StatCard(
            icon: Icons.accessibility_new_rounded,
            label: l10n.mostTrainedMuscle,
            value: stats.mostTrainedMuscle ?? '—',
            accentColor: AppColors.accent,
          ).animate().fadeIn(delay: 160.ms),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: GymCard(
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _AnimatedCounterCard._inline(
                        target: stats.currentStreak.toDouble(),
                        format: (v) => v.round().toString(),
                        accentColor: AppColors.warning,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.currentStreak,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
                  padding: EdgeInsets.all(16.w),
                  child: Column(
                    children: [
                      _AnimatedCounterCard._inline(
                        target: stats.longestStreak.toDouble(),
                        format: (v) => v.round().toString(),
                        accentColor: AppColors.primary,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        l10n.longestStreak,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: gymTheme.secondaryText,
                            ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ).animate().fadeIn(delay: 200.ms),
          SizedBox(height: 24.h),
          SectionHeader(
            title: l10n.weeklyTrend,
            trailing: SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: true, label: Text(l10n.volume)),
                ButtonSegment(value: false, label: Text(l10n.workouts)),
              ],
              selected: {_showVolumeChart},
              onSelectionChanged: (s) => setState(() => _showVolumeChart = s.first),
            ),
          ),
          SizedBox(height: 12.h),
          GymCard(
            child: weeklyData.isEmpty
                ? SizedBox(
                    height: 200.h,
                    child: Center(
                      child: Text(
                        l10n.completeWorkoutsForTrends,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: gymTheme.secondaryText,
                            ),
                      ),
                    ),
                  )
                : SizedBox(
                    height: 220.h,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: weeklyData
                                .map((e) => _showVolumeChart ? e.volume : e.count.toDouble())
                                .reduce((a, b) => a > b ? a : b) *
                            1.2 +
                            1,
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (_) => FlLine(
                            color: gymTheme.border.withValues(alpha: 0.5),
                            strokeWidth: 1,
                          ),
                        ),
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36.w,
                              getTitlesWidget: (v, _) => Text(
                                '${v.round()}',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: gymTheme.secondaryText,
                                      fontSize: 10.sp,
                                    ),
                              ),
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (v, _) {
                                final i = v.toInt();
                                if (i < 0 || i >= weeklyData.length) {
                                  return const SizedBox.shrink();
                                }
                                return Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: Text(
                                    weeklyData[i].label,
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: gymTheme.secondaryText,
                                          fontSize: 9.sp,
                                        ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        barGroups: weeklyData.asMap().entries.map((entry) {
                          final value = _showVolumeChart
                              ? entry.value.volume
                              : entry.value.count.toDouble();
                          return BarChartGroupData(
                            x: entry.key,
                            barRods: [
                              BarChartRodData(
                                toY: value,
                                color: AppColors.primary,
                                width: 18.w,
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(6.r),
                                ),
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    AppColors.primary.withValues(alpha: 0.7),
                                    AppColors.accent,
                                  ],
                                ),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
          ).animate().fadeIn(delay: 250.ms),
          if (stats.totalVolume > 0) ...[
            SizedBox(height: 16.h),
            Text(
              l10n.lifetimeVolume(
                Formatters.formatVolume(stats.totalVolume, unit: settings?.weightUnit),
              ),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: gymTheme.secondaryText,
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  List<_WeekBucket> _buildWeeklyData(List<WorkoutLog> logs, String localeName) {
    if (logs.isEmpty) return [];

    final now = DateTime.now();
    final buckets = <_WeekBucket>[];

    for (var i = 7; i >= 0; i--) {
      final weekStart = now.subtract(Duration(days: now.weekday - 1 + i * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final label = DateFormat('M/d', localeName).format(weekStart);

      var count = 0;
      var volume = 0.0;
      for (final log in logs) {
        final date = log.endedAt ?? log.startedAt;
        if (!date.isBefore(weekStart) && !date.isAfter(weekEnd.add(const Duration(hours: 23, minutes: 59)))) {
          count++;
          volume += log.totalVolume;
        }
      }
      buckets.add(_WeekBucket(label: label, count: count, volume: volume));
    }

    return buckets.where((b) => b.count > 0 || buckets.indexOf(b) >= buckets.length - 4).toList();
  }
}

class _WeekBucket {
  const _WeekBucket({
    required this.label,
    required this.count,
    required this.volume,
  });

  final String label;
  final int count;
  final double volume;
}

class _AnimatedCounterCard extends StatefulWidget {
  const _AnimatedCounterCard({
    required this.icon,
    required this.label,
    required this.target,
    required this.format,
    required this.accentColor,
  });

  const _AnimatedCounterCard._inline({
    required this.target,
    required this.format,
    required this.accentColor,
  })  : icon = Icons.local_fire_department,
        label = '';

  final IconData icon;
  final String label;
  final double target;
  final String Function(double) format;
  final Color accentColor;

  @override
  State<_AnimatedCounterCard> createState() => _AnimatedCounterCardState();
}

class _AnimatedCounterCardState extends State<_AnimatedCounterCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _animation = Tween<double>(begin: 0, end: widget.target).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(covariant _AnimatedCounterCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.target != widget.target) {
      _animation = Tween<double>(
        begin: _animation.value,
        end: widget.target,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.label.isEmpty) {
      return AnimatedBuilder(
        animation: _animation,
        builder: (context, child) => Text(
          widget.format(_animation.value),
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: widget.accentColor,
              ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => StatCard(
        icon: widget.icon,
        label: widget.label,
        value: widget.format(_animation.value),
        accentColor: widget.accentColor,
      ),
    );
  }
}
