import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/l10n/l10n.dart';

class GreetingHeader extends StatelessWidget {
  const GreetingHeader({
    super.key,
    required this.userName,
    this.subtitle,
    this.profileInitials,
    this.onProfileTap,
  });

  final String userName;
  final String? subtitle;
  final String? profileInitials;
  final VoidCallback? onProfileTap;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final greeting = Formatters.greetingNow(l10n, name: userName);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greeting,
                style: textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                  height: 1.15,
                ),
              )
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideX(begin: -0.05, end: 0),
              if (subtitle != null) ...[
                SizedBox(height: 6.h),
                Text(
                  subtitle!,
                  style: textTheme.bodyMedium?.copyWith(
                    color: gymTheme.secondaryText,
                  ),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
              ],
            ],
          ),
        ),
        if (onProfileTap != null) ...[
          SizedBox(width: 8.w),
          InkWell(
            onTap: onProfileTap,
            borderRadius: BorderRadius.circular(24.r),
            child: CircleAvatar(
              radius: 22.r,
              backgroundColor: AppColors.primary.withValues(alpha: 0.18),
              child: Text(
                (profileInitials == null || profileInitials!.isEmpty)
                    ? '?'
                    : profileInitials!,
                style: textTheme.labelLarge?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
