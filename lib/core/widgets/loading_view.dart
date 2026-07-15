import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/constants/app_constants.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/l10n/l10n.dart';

/// Centered branded loading indicator for full-screen or inline use.
class LoadingView extends StatelessWidget {
  const LoadingView({
    super.key,
    this.message,
    this.padding,
  });

  final String? message;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Padding(
      padding: padding ?? EdgeInsets.all(32.w),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 72.w,
              height: 72.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 72.w,
                    height: 72.w,
                    child: CircularProgressIndicator(
                      strokeWidth: 3.w,
                      color: AppColors.primary,
                      backgroundColor: gymTheme.border,
                    ),
                  ),
                  Container(
                    width: 44.w,
                    height: 44.w,
                    decoration: BoxDecoration(
                      color: gymTheme.elevatedSurface,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: gymTheme.border.withValues(alpha: 0.6),
                      ),
                    ),
                    child: Icon(
                      Icons.fitness_center_rounded,
                      size: 22.sp,
                      color: AppColors.primary,
                      semanticLabel: l10n.loading,
                    ),
                  ),
                ],
              ),
            )
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 1800.ms,
                  color: AppColors.primary.withValues(alpha: 0.25),
                ),
            SizedBox(height: 20.h),
            Text(
              message ?? l10n.loadingApp(AppConstants.appName),
              style: textTheme.bodyMedium?.copyWith(
                color: gymTheme.secondaryText,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
