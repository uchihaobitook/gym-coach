import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/l10n/l10n.dart';

/// Workout badge types with semantic colors from [AppColors].
enum GymBadgeType {
  dropSet,
  fail,
  pr,
  muscle,
}

/// Compact badge for Drop Set, Fail, PR, or muscle group labels.
class BadgeChip extends StatelessWidget {
  const BadgeChip({
    super.key,
    required this.label,
    required this.type,
    this.color,
    this.icon,
    this.compact = false,
  });

  const BadgeChip.dropSet({super.key, this.compact = false})
      : label = '',
        type = GymBadgeType.dropSet,
        color = null,
        icon = Icons.trending_down_rounded;

  const BadgeChip.fail({super.key, this.compact = false})
      : label = '',
        type = GymBadgeType.fail,
        color = null,
        icon = Icons.close_rounded;

  const BadgeChip.pr({super.key, this.compact = false})
      : label = '',
        type = GymBadgeType.pr,
        color = null,
        icon = Icons.emoji_events_rounded;

  const BadgeChip.muscle({
    super.key,
    required this.label,
    this.color,
    this.compact = false,
  })  : type = GymBadgeType.muscle,
        icon = null;

  final String label;
  final GymBadgeType type;
  final Color? color;
  final IconData? icon;
  final bool compact;

  String _displayLabel(BuildContext context) {
    final l10n = context.l10n;
    return switch (type) {
      GymBadgeType.dropSet => l10n.badgeDropSet,
      GymBadgeType.fail => l10n.badgeFail,
      GymBadgeType.pr => l10n.badgePr,
      GymBadgeType.muscle => label,
    };
  }

  Color _backgroundColor(Color fg) => fg.withValues(alpha: 0.16);

  Color _foregroundColor() {
    if (color != null) return color!;
    return switch (type) {
      GymBadgeType.dropSet => AppColors.dropSet,
      GymBadgeType.fail => AppColors.failBadge,
      GymBadgeType.pr => AppColors.prGold,
      GymBadgeType.muscle => AppColors.accent,
    };
  }

  @override
  Widget build(BuildContext context) {
    final displayLabel = _displayLabel(context);
    final fg = _foregroundColor();
    final bg = _backgroundColor(fg);
    final textStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          color: fg,
          fontWeight: FontWeight.w700,
          fontSize: compact ? 10.sp : 11.sp,
          letterSpacing: 0.3,
        );

    return Semantics(
      label: displayLabel,
      child: Container(
        constraints: BoxConstraints(minHeight: compact ? 24.h : 28.h),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 8.w : 10.w,
          vertical: compact ? 4.h : 5.h,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: fg.withValues(alpha: 0.35)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 12.sp : 14.sp, color: fg),
              SizedBox(width: 4.w),
            ],
            Text(displayLabel, style: textStyle),
          ],
        ),
      ),
    );
  }
}
