import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/l10n/l10n.dart';

/// Top workout progress bar showing completed/total sets with animated percentage.
class AnimatedProgressBar extends StatelessWidget {
  const AnimatedProgressBar({
    super.key,
    required this.completed,
    required this.total,
    this.height,
    this.showLabel = true,
    this.color,
    this.animate = true,
  });

  final int completed;
  final int total;
  final double? height;
  final bool showLabel;
  final Color? color;
  final bool animate;

  double get _progress => total == 0 ? 0 : (completed / total).clamp(0.0, 1.0);
  int get _percent => (_progress * 100).round();

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final barHeight = height ?? 6.h;
    final fillColor = color ?? AppColors.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showLabel)
          Padding(
            padding: EdgeInsets.only(bottom: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.workoutProgress,
                  style: textTheme.labelMedium?.copyWith(
                    color: gymTheme.secondaryText,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  l10n.workoutProgressValue(completed, total, _percent),
                  style: textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: BorderRadius.circular(barHeight),
          child: SizedBox(
            height: barHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: gymTheme.border),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: _progress),
                  duration: animate
                      ? const Duration(milliseconds: 600)
                      : Duration.zero,
                  curve: Curves.easeOutCubic,
                  builder: (context, value, _) {
                    return FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: value,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              fillColor,
                              fillColor.withValues(alpha: 0.75),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    ).animate(target: animate ? 1 : 0).fadeIn(duration: 250.ms);
  }
}
