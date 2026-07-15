import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gym_coach/core/services/app_update_service.dart';
import 'package:gym_coach/core/widgets/app_update_dialog.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/app_update_provider.dart';

/// Checks GitHub Releases once when [child] is first shown.
class AppUpdateChecker extends ConsumerStatefulWidget {
  const AppUpdateChecker({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<AppUpdateChecker> createState() => _AppUpdateCheckerState();
}

class _AppUpdateCheckerState extends ConsumerState<AppUpdateChecker> {
  bool _checked = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _checkSilently());
  }

  Future<void> _checkSilently() async {
    if (_checked) return;
    _checked = true;
    await _check(showUpToDateMessage: false);
  }

  Future<void> _check({required bool showUpToDateMessage}) async {
    final service = ref.read(appUpdateServiceProvider);
    try {
      final update = await service.checkForUpdate();
      if (!mounted) return;
      if (update != null) {
        await showAppUpdateDialog(
          context,
          update: update,
          updateService: service,
        );
      } else if (showUpToDateMessage) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.updateUpToDate)),
        );
      }
    } on AppUpdateException {
      if (!mounted || !showUpToDateMessage) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.updateCheckFailed)),
      );
    } catch (_) {
      if (!mounted || !showUpToDateMessage) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.updateCheckFailed)),
      );
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Callable from Settings to manually check for updates.
Future<void> checkForAppUpdate(
  BuildContext context,
  WidgetRef ref, {
  required bool showUpToDateMessage,
}) async {
  final service = ref.read(appUpdateServiceProvider);
  try {
    final update = await service.checkForUpdate();
    if (!context.mounted) return;
    if (update != null) {
      await showAppUpdateDialog(
        context,
        update: update,
        updateService: service,
      );
    } else if (showUpToDateMessage) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.updateUpToDate)),
      );
    }
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.updateCheckFailed)),
    );
  }
}
