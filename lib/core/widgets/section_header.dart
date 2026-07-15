import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
/// Section title with optional trailing action widget.
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.title,
    this.trailing,
    this.padding,
  });

  final String title;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 4.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Text(
              title,
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 8.w),
            ConstrainedBox(
              constraints: BoxConstraints(minHeight: 48.h, minWidth: 48.w),
              child: Align(
                alignment: Alignment.centerRight,
                child: trailing!,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Text action button sized for section headers.
class SectionHeaderAction extends StatelessWidget {
  const SectionHeaderAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        minimumSize: Size(48.w, 48.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          if (icon != null) ...[
            SizedBox(width: 4.w),
            Icon(icon, size: 18.sp),
          ],
        ],
      ),
    );
  }
}
