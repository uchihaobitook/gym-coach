import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_theme.dart';

/// Rounded surface card with soft shadow, padding, and optional tap ripple.
class GymCard extends StatelessWidget {
  const GymCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
    this.borderRadius,
    this.color,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? borderRadius;
  final Color? color;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final radius = borderRadius ?? 20.r;
    final surfaceColor = color ?? Theme.of(context).cardColor;

    final card = DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(
          color: gymTheme.border.withValues(alpha: 0.5),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.22),
            blurRadius: 16.r,
            offset: Offset(0, 6.h),
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? EdgeInsets.all(16.w),
        child: child,
      ),
    );

    if (onTap == null) {
      return Padding(
        padding: margin ?? EdgeInsets.zero,
        child: card,
      );
    }

    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          splashColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          highlightColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.06),
          child: Semantics(
            button: true,
            label: semanticLabel,
            child: card,
          ),
        ),
      ),
    );
  }
}
