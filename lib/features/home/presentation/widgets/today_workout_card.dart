import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/muscle_chip.dart';
import 'package:gym_coach/core/widgets/primary_button.dart';
import 'package:gym_coach/data/models/program_models.dart';
import 'package:gym_coach/l10n/l10n.dart';

class TodayWorkoutCard extends StatelessWidget {
  const TodayWorkoutCard({
    super.key,
    required this.day,
    required this.weekNumber,
    required this.onQuickStart,
    this.isCompleted = false,
  });

  final WorkoutDayTemplate day;
  final int weekNumber;
  final VoidCallback onQuickStart;
  final bool isCompleted;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return GymCard(
      padding: EdgeInsets.all(20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  l10n.weekDayBadge(weekNumber, day.dayNumber),
                  style: textTheme.labelSmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              if (isCompleted)
                Icon(
                  Icons.check_circle_rounded,
                  color: gymTheme.success,
                  size: 22.sp,
                ),
            ],
          ),
          SizedBox(height: 14.h),
          Text(
            day.name,
            style: textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8.h),
          MuscleChip(label: day.muscleGroup),
          if (day.description != null) ...[
            SizedBox(height: 12.h),
            Text(
              day.description!,
              style: textTheme.bodyMedium?.copyWith(
                color: gymTheme.secondaryText,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          SizedBox(height: 16.h),
          Row(
            children: [
              _MetaChip(
                icon: Icons.schedule_rounded,
                label: l10n.minutesShort(day.estimatedMinutes),
              ),
              SizedBox(width: 10.w),
              _MetaChip(
                icon: Icons.fitness_center_rounded,
                label: l10n.exercisesCount(day.exerciseCount),
              ),
              SizedBox(width: 10.w),
              _MetaChip(
                icon: Icons.repeat_rounded,
                label: l10n.setsCount(day.totalSets),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          PrimaryButton(
            label: isCompleted ? l10n.trainAgain : l10n.quickStart,
            icon: Icons.play_arrow_rounded,
            onPressed: onQuickStart,
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 450.ms, delay: 150.ms)
        .slideY(begin: 0.08, end: 0, duration: 450.ms, curve: Curves.easeOut);
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip({required this.icon, required this.label});

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
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: gymTheme.secondaryText,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}
