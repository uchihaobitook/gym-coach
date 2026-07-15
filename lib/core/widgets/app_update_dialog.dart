import 'package:flutter/material.dart';
import 'package:gym_coach/core/services/app_update_service.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:ota_update/ota_update.dart';

/// Prompts the user to download an OTA update from GitHub Releases.
class AppUpdateDialog extends StatefulWidget {
  const AppUpdateDialog({
    super.key,
    required this.update,
    required this.updateService,
  });

  final AppUpdateInfo update;
  final AppUpdateService updateService;

  @override
  State<AppUpdateDialog> createState() => _AppUpdateDialogState();
}

class _AppUpdateDialogState extends State<AppUpdateDialog> {
  bool _installing = false;
  double? _progress;
  String? _status;

  Future<void> _startInstall() async {
    final l10n = context.l10n;
    setState(() {
      _installing = true;
      _status = l10n.updateDownloading;
    });

    try {
      await for (final event in widget.updateService.installUpdate(
        widget.update.apkUrl,
      )) {
        if (!mounted) return;
        setState(() {
          switch (event.status) {
            case OtaStatus.DOWNLOADING:
              _progress = event.value != null
                  ? (double.tryParse(event.value!) ?? 0) / 100
                  : null;
              _status = l10n.updateDownloading;
            case OtaStatus.INSTALLING:
              _status = l10n.updateInstalling;
            case OtaStatus.INSTALLATION_DONE:
              _status = l10n.updateInstalling;
              _installing = false;
            case OtaStatus.ALREADY_RUNNING_ERROR:
              _status = l10n.updateAlreadyRunning;
              _installing = false;
            case OtaStatus.PERMISSION_NOT_GRANTED_ERROR:
              _status = l10n.updatePermissionDenied;
              _installing = false;
            case OtaStatus.INSTALLATION_ERROR:
            case OtaStatus.INTERNAL_ERROR:
            case OtaStatus.DOWNLOAD_ERROR:
            case OtaStatus.CHECKSUM_ERROR:
              _status = l10n.updateFailed;
              _installing = false;
              _progress = null;
            case OtaStatus.CANCELED:
              _status = l10n.updateCancelled;
              _installing = false;
              _progress = null;
          }
        });
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _status = l10n.updateFailed;
        _installing = false;
        _progress = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final notes = widget.update.releaseNotes?.trim();

    return AlertDialog(
      title: Text(l10n.updateAvailableTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.updateAvailableBody(
              widget.update.versionName,
              widget.update.buildNumber,
            ),
          ),
          if (notes != null && notes.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              notes,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          if (_installing || _status != null) ...[
            const SizedBox(height: 16),
            if (_progress != null)
              LinearProgressIndicator(value: _progress!.clamp(0.0, 1.0)),
            if (_status != null) ...[
              const SizedBox(height: 8),
              Text(_status!, style: Theme.of(context).textTheme.bodySmall),
            ],
          ],
        ],
      ),
      actions: [
        if (!_installing)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.updateLater),
          ),
        FilledButton(
          onPressed: _installing ? null : _startInstall,
          child: Text(_installing ? l10n.updateDownloading : l10n.updateNow),
        ),
      ],
    );
  }
}

Future<void> showAppUpdateDialog(
  BuildContext context, {
  required AppUpdateInfo update,
  required AppUpdateService updateService,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AppUpdateDialog(
      update: update,
      updateService: updateService,
    ),
  );
}
