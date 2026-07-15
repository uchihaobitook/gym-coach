import 'package:flutter/widgets.dart';

/// Returns true when the user prefers reduced motion.
bool prefersReducedMotion(BuildContext context) {
  return MediaQuery.disableAnimationsOf(context) ||
      MediaQuery.accessibleNavigationOf(context);
}

/// Duration that collapses to zero when reduce-motion is on.
Duration motionDuration(BuildContext context, Duration normal) {
  return prefersReducedMotion(context) ? Duration.zero : normal;
}
