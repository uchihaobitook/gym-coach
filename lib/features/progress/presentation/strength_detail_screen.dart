import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/core/widgets/empty_state.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/core/widgets/stat_card.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/exercise_strength_provider.dart';
import 'package:gym_coach/providers/settings_provider.dart';

class StrengthDetailScreen extends ConsumerWidget {
  const StrengthDetailScreen({super.key, required this.exerciseId});

  final String exerciseId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(exerciseStrengthProfileProvider(exerciseId));
    final settings = ref.watch(settingsProvider).value;
    final gymTheme = context.gymTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.strengthDetail)),
      body: profileAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.couldNotLoadHistory,
          subtitle: e.toString(),
        ),
        data: (profile) {
          if (profile == null || profile.history.isEmpty) {
            return EmptyState(
              icon: Icons.history_rounded,
              title: l10n.noHistoryYet,
              subtitle: l10n.noHistorySubtitle,
            );
          }

          final history = [...profile.history]
            ..sort((a, b) => a.date.compareTo(b.date));

          final spots = history
              .asMap()
              .entries
              .map((e) => FlSpot(e.key.toDouble(), e.value.bestWeight))
              .toList();

          final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
          final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
          final pad = (maxY - minY) * 0.12 + 2;

          return ListView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            children: [
              Text(
                profile.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ).animate().fadeIn(duration: 350.ms),
              SizedBox(height: 4.h),
              Text(
                profile.muscleGroup,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: gymTheme.secondaryText,
                    ),
              ),
              SizedBox(height: 20.h),
              StatCard(
                icon: Icons.emoji_events_rounded,
                label: l10n.bestWeight,
                value: Formatters.formatWeight(profile.bestWeight, unit: settings?.weightUnit),
                accentColor: AppColors.prGold,
              ).animate().fadeIn(delay: 100.ms),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      icon: Icons.repeat_rounded,
                      label: l10n.bestReps,
                      value: '${profile.bestReps}',
                      accentColor: AppColors.primary,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: StatCard(
                      icon: Icons.stacked_bar_chart_rounded,
                      label: l10n.bestVolume,
                      value: Formatters.formatVolume(profile.bestVolume, unit: settings?.weightUnit),
                      accentColor: AppColors.accent,
                    ),
                  ),
                ],
              ).animate().fadeIn(delay: 150.ms),
              SizedBox(height: 20.h),
              GymCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.weightOverTime,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    SizedBox(height: 16.h),
                    SizedBox(
                      height: 220.h,
                      child: LineChart(
                        LineChartData(
                          minY: minY - pad,
                          maxY: maxY + pad,
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: false,
                            getDrawingHorizontalLine: (_) => FlLine(
                              color: gymTheme.border.withValues(alpha: 0.5),
                              strokeWidth: 1,
                            ),
                          ),
                          titlesData: FlTitlesData(
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 42.w,
                                getTitlesWidget: (v, _) => Text(
                                  v.toStringAsFixed(0),
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
                                interval: (history.length / 4).ceilToDouble().clamp(1, 999),
                                getTitlesWidget: (value, _) {
                                  final i = value.toInt();
                                  if (i < 0 || i >= history.length) {
                                    return const SizedBox.shrink();
                                  }
                                  return Text(
                                    Formatters.formatChartDate(history[i].date, l10n: l10n),
                                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                          color: gymTheme.secondaryText,
                                          fontSize: 9.sp,
                                        ),
                                  );
                                },
                              ),
                            ),
                          ),
                          borderData: FlBorderData(show: false),
                          lineBarsData: [
                            LineChartBarData(
                              spots: spots,
                              isCurved: true,
                              color: AppColors.accent,
                              barWidth: 3,
                              dotData: const FlDotData(show: true),
                              belowBarData: BarAreaData(
                                show: true,
                                color: AppColors.accent.withValues(alpha: 0.1),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().fadeIn(delay: 200.ms),
              SizedBox(height: 24.h),
              Text(
                l10n.history,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              SizedBox(height: 12.h),
              ...history.reversed.map((entry) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8.h),
                  child: GymCard(
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            Formatters.formatShortDate(entry.date, l10n: l10n),
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        Text(
                          Formatters.formatWeight(entry.bestWeight, unit: settings?.weightUnit),
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                        ),
                        SizedBox(width: 12.w),
                        Text(
                          l10n.repsCount(entry.bestReps),
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                color: gymTheme.secondaryText,
                              ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
