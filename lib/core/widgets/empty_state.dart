import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_theme.dart';

import 'primary_button.dart';

/// Centered empty state with icon, title, subtitle, and optional CTA.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.padding,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 32.w, vertical: 48.h),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80.w,
              height: 80.w,
              decoration: BoxDecoration(
                color: gymTheme.elevatedSurface,
                shape: BoxShape.circle,
                border: Border.all(
                  color: gymTheme.border.withValues(alpha: 0.6),
                ),
              ),
              child: Icon(
                icon,
                size: 36.sp,
                color: primaryColor.withValues(alpha: 0.85),
                semanticLabel: title,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              SizedBox(height: 8.h),
              Text(
                subtitle!,
                style: textTheme.bodyMedium?.copyWith(
                  color: gymTheme.secondaryText,
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 24.h),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 280.w),
                child: PrimaryButton(
                  label: actionLabel!,
                  onPressed: onAction,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
