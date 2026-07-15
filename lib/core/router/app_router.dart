import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/calendar/presentation/calendar_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/progress/presentation/progress_screen.dart';
import '../../features/progress/presentation/strength_detail_screen.dart';
import '../../features/profiles/presentation/profile_selection_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/main_shell.dart';
import '../widgets/app_update_checker.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/statistics/presentation/statistics_screen.dart';
import '../../features/summary/presentation/workout_summary_screen.dart';
import '../../features/workout/presentation/week_screen.dart';
import '../../features/workout/presentation/workout_session_screen.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');
final _shellNavigatorHomeKey = GlobalKey<NavigatorState>(debugLabel: 'home');
final _shellNavigatorWeekKey = GlobalKey<NavigatorState>(debugLabel: 'week');
final _shellNavigatorProgressKey =
    GlobalKey<NavigatorState>(debugLabel: 'progress');
final _shellNavigatorStatsKey = GlobalKey<NavigatorState>(debugLabel: 'stats');
final _shellNavigatorSettingsKey =
    GlobalKey<NavigatorState>(debugLabel: 'settings');

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/profiles',
        name: 'profiles',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const ProfileSelectionScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) => AppUpdateChecker(
          child: MainShell(navigationShell: navigationShell),
        ),
        branches: [
          StatefulShellBranch(
            navigatorKey: _shellNavigatorHomeKey,
            routes: [
              GoRoute(
                path: '/home',
                name: 'home',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: HomeScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorWeekKey,
            routes: [
              GoRoute(
                path: '/week',
                name: 'week',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: WeekScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorProgressKey,
            routes: [
              GoRoute(
                path: '/progress',
                name: 'progress',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: ProgressScreen(),
                ),
                routes: [
                  GoRoute(
                    path: 'strength/:exerciseId',
                    name: 'strengthDetail',
                    builder: (context, state) => StrengthDetailScreen(
                      exerciseId: state.pathParameters['exerciseId']!,
                    ),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorStatsKey,
            routes: [
              GoRoute(
                path: '/statistics',
                name: 'statistics',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: StatisticsScreen(),
                ),
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: _shellNavigatorSettingsKey,
            routes: [
              GoRoute(
                path: '/settings',
                name: 'settings',
                pageBuilder: (context, state) => const NoTransitionPage(
                  child: SettingsScreen(),
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: '/workout/:dayId',
        name: 'workout',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => WorkoutSessionScreen(
          dayId: state.pathParameters['dayId']!,
        ),
      ),
      GoRoute(
        path: '/summary/:logId',
        name: 'summary',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => WorkoutSummaryScreen(
          logId: state.pathParameters['logId']!,
        ),
      ),
      GoRoute(
        path: '/calendar',
        name: 'calendar',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CalendarScreen(),
      ),
    ],
  );

  ref.onDispose(router.dispose);
  return router;
});
