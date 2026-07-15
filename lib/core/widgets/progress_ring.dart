import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';

/// Animated circular progress indicator with percentage label in the center.
class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size,
    this.strokeWidth,
    this.color,
    this.trackColor,
    this.showPercentage = true,
    this.centerLabel,
    this.animate = true,
  });

  /// Value between 0.0 and 1.0.
  final double progress;
  final double? size;
  final double? strokeWidth;
  final Color? color;
  final Color? trackColor;
  final bool showPercentage;
  final String? centerLabel;
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final ringSize = size ?? 96.w;
    final stroke = strokeWidth ?? 8.w;
    final progressColor = color ?? AppColors.primary;
    final backgroundTrack = trackColor ?? gymTheme.border;
    final clamped = progress.clamp(0.0, 1.0);
    final percentText = '${(clamped * 100).round()}%';

    return SizedBox(
      width: ringSize,
      height: ringSize,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clamped),
        duration: animate ? const Duration(milliseconds: 800) : Duration.zero,
        curve: Curves.easeOutCubic,
        builder: (context, animatedProgress, child) {
          return CustomPaint(
            painter: _RingPainter(
              progress: animatedProgress,
              strokeWidth: stroke,
              progressColor: progressColor,
              trackColor: backgroundTrack,
            ),
            child: child,
          );
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showPercentage)
                Text(
                  percentText,
                  style: textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              if (centerLabel != null) ...[
                if (showPercentage) SizedBox(height: 2.h),
                Text(
                  centerLabel!,
                  style: (showPercentage
                          ? textTheme.labelSmall
                          : textTheme.titleLarge)
                      ?.copyWith(
                    color: showPercentage
                        ? gymTheme.secondaryText
                        : textTheme.titleLarge?.color,
                    fontWeight:
                        showPercentage ? FontWeight.w500 : FontWeight.w700,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      ),
    ).animate(target: animate ? 1 : 0).fadeIn(duration: 300.ms);
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.progressColor,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Color progressColor;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.shortestSide - strokeWidth) / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.trackColor != trackColor;
  }
}
