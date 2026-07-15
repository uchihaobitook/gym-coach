import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/l10n/l10n.dart';

import 'gym_card.dart';
import 'muscle_chip.dart';
import 'progress_ring.dart';

/// Card displaying a workout day summary with completion progress.
class WorkoutDayCard extends StatelessWidget {
  const WorkoutDayCard({
    super.key,
    required this.dayName,
    required this.muscleGroup,
    required this.durationMinutes,
    required this.exerciseCount,
    required this.completionPercent,
    this.onTap,
    this.isCompleted = false,
  });

  final String dayName;
  final String muscleGroup;
  final int durationMinutes;
  final int exerciseCount;
  final double completionPercent;
  final VoidCallback? onTap;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final progress = (completionPercent / 100).clamp(0.0, 1.0);

    return GymCard(
      onTap: onTap,
      semanticLabel: l10n.dayCardA11y(
        dayName,
        muscleGroup,
        completionPercent.round(),
      ),
      child: Row(
        children: [
          ProgressRing(
            progress: progress,
            size: 56.w,
            strokeWidth: 5.w,
            color: isCompleted ? gymTheme.success : AppColors.primary,
            showPercentage: false,
            centerLabel: '${completionPercent.round()}%',
            animate: false,
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        dayName,
                        style: textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCompleted)
                      Icon(
                        Icons.check_circle_rounded,
                        color: gymTheme.success,
                        size: 20.sp,
                        semanticLabel: l10n.legendCompleted,
                      ),
                  ],
                ),
                SizedBox(height: 6.h),
                MuscleChip(label: muscleGroup),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    _MetaItem(
                      icon: Icons.schedule_rounded,
                      label: l10n.minutesShort(durationMinutes),
                    ),
                    SizedBox(width: 14.w),
                    _MetaItem(
                      icon: Icons.fitness_center_rounded,
                      label: l10n.exercisesCount(exerciseCount),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (onTap != null) ...[
            SizedBox(width: 4.w),
            Icon(
              Icons.chevron_right_rounded,
              color: gymTheme.secondaryText,
              size: 24.sp,
            ),
          ],
        ],
      ),
    );
  }
}

class _MetaItem extends StatelessWidget {
  const _MetaItem({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14.sp, color: gymTheme.secondaryText),
        SizedBox(width: 4.w),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: gymTheme.secondaryText,
              ),
        ),
      ],
    );
  }
}
