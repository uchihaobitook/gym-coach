import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_coach/core/constants/app_constants.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/program_provider.dart';
import 'package:gym_coach/providers/active_profile_provider.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _navigated = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await Future.wait([
      ref.read(profileBootstrapProvider.future),
      ref.read(workoutProgramProvider.future),
      Future<void>.delayed(const Duration(milliseconds: 1200)),
    ]);

    if (!mounted || _navigated) return;
    _navigated = true;
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 96.w,
              height: 96.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.accent],
                ),
                borderRadius: BorderRadius.circular(28.r),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.35),
                    blurRadius: 32.r,
                    offset: Offset(0, 12.h),
                  ),
                ],
              ),
              child: Icon(
                Icons.fitness_center_rounded,
                size: 48.sp,
                color: Colors.white,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                .scale(
                  begin: const Offset(0.85, 0.85),
                  end: const Offset(1, 1),
                  duration: 700.ms,
                  curve: Curves.easeOutBack,
                ),
            SizedBox(height: 28.h),
            Text(
              AppConstants.appName,
              style: textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.5,
              ),
            )
                .animate()
                .fadeIn(delay: 200.ms, duration: 500.ms)
                .slideY(begin: 0.2, end: 0, duration: 500.ms),
            SizedBox(height: 8.h),
            Text(
              l10n.splashTagline,
              style: textTheme.bodyMedium?.copyWith(
                color: gymTheme.secondaryText,
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 500.ms),
            SizedBox(height: 48.h),
            LoadingView(message: l10n.splashLoading),
          ],
        ),
      ),
    );
  }
}
