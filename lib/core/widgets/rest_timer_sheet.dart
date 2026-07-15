import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/constants/app_constants.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/l10n/l10n.dart';

import 'progress_ring.dart';

/// Bottom sheet UI for rest countdown. Bind to [RestTimerService] via callbacks.
class RestTimerSheet extends StatelessWidget {
  const RestTimerSheet({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.isPaused,
    required this.onPause,
    required this.onResume,
    required this.onSkip,
    required this.onPreset,
  });

  final int remainingSeconds;
  final int totalSeconds;
  final bool isPaused;
  final VoidCallback onPause;
  final VoidCallback onResume;
  final VoidCallback onSkip;
  final ValueChanged<int> onPreset;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final l10n = context.l10n;
    final progress =
        totalSeconds == 0 ? 0.0 : 1 - (remainingSeconds / totalSeconds);
    final remainingLabel = Formatters.formatDuration(
      Duration(seconds: remainingSeconds),
    );
    final totalLabel = Formatters.formatDuration(
      Duration(seconds: totalSeconds),
    );

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 28.h),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        border: Border(
          top: BorderSide(color: gymTheme.border.withValues(alpha: 0.5)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: gymTheme.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              l10n.restTimer,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            SizedBox(height: 4.h),
            Text(
              isPaused ? l10n.paused : l10n.recoverBeforeNext,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: gymTheme.secondaryText,
                  ),
            ),
            SizedBox(height: 24.h),
            ProgressRing(
              progress: progress.clamp(0.0, 1.0),
              size: 168.w,
              strokeWidth: 10.w,
              color: AppColors.accent,
              showPercentage: false,
              centerLabel: remainingLabel,
            ),
            SizedBox(height: 8.h),
            Text(
              l10n.ofTotal(totalLabel),
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: gymTheme.secondaryText,
                  ),
            ),
            SizedBox(height: 24.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isPaused ? onResume : onPause,
                    icon: Icon(
                      isPaused
                          ? Icons.play_arrow_rounded
                          : Icons.pause_rounded,
                    ),
                    label: Text(isPaused ? l10n.resume : l10n.pause),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onSkip,
                    icon: const Icon(Icons.skip_next_rounded),
                    label: Text(l10n.skip),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: AppConstants.restPresets.map((seconds) {
                return _PresetChip(
                  seconds: seconds,
                  isSelected: totalSeconds == seconds,
                  onTap: () => onPreset(seconds),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({
    required this.seconds,
    required this.isSelected,
    required this.onTap,
  });

  final int seconds;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;

    return Semantics(
      button: true,
      selected: isSelected,
      label: context.l10n.restPresetA11y(seconds),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 72.w, minHeight: 48.h),
            child: Ink(
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.18)
                    : gymTheme.elevatedSurface,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? AppColors.primary : gymTheme.border,
                ),
              ),
              child: Center(
                child: Text(
                  context.l10n.restSecondsLabel(seconds),
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : Theme.of(context).colorScheme.onSurface,
                      ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
