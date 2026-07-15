import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/l10n/l10n.dart';

/// Maps common muscle group names to accent colors for quick visual scanning.
Color muscleGroupColor(String muscleGroup) {
  final key = muscleGroup.toLowerCase().trim();
  return switch (key) {
    'chest' || 'pectorals' => const Color(0xFF5B8DEF),
    'back' || 'lats' => const Color(0xFF7C6CF0),
    'shoulders' || 'delts' => const Color(0xFF2DD4BF),
    'biceps' || 'arms' => const Color(0xFF4FC3F7),
    'triceps' => const Color(0xFF29B6F6),
    'legs' || 'quads' || 'hamstrings' => const Color(0xFFFF8A65),
    'glutes' => const Color(0xFFFF7043),
    'core' || 'abs' => const Color(0xFFFFD54F),
    'calves' => const Color(0xFFA1887F),
    'cardio' || 'full body' => AppColors.accent,
    _ => AppColors.primary,
  };
}

/// Small chip for displaying a muscle group label.
class MuscleChip extends StatelessWidget {
  const MuscleChip({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.onTap,
    this.selected = false,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final accent = color ?? muscleGroupColor(label);
    final bg = selected
        ? accent.withValues(alpha: 0.22)
        : accent.withValues(alpha: 0.12);
    final fg = selected ? accent : accent.withValues(alpha: 0.95);
    final semanticLabel = context.l10n.muscleGroupA11y(label);

    final chip = Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(
          color: selected ? accent : gymTheme.border.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.sp, color: fg),
            SizedBox(width: 4.w),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );

    if (onTap == null) {
      return Semantics(label: semanticLabel, child: chip);
    }

    return Semantics(
      button: true,
      selected: selected,
      label: semanticLabel,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 48.w, minHeight: 48.h),
            child: Align(
              alignment: Alignment.centerLeft,
              child: chip,
            ),
          ),
        ),
      ),
    );
  }
}
