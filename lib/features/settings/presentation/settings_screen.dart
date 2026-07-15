import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/constants/app_constants.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/core/widgets/section_header.dart';
import 'package:gym_coach/core/widgets/app_update_checker.dart';
import 'package:gym_coach/data/models/app_settings.dart';
import 'package:gym_coach/data/repositories/backup_repository.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/exercise_strength_provider.dart';
import 'package:gym_coach/providers/measurement_provider.dart';
import 'package:gym_coach/providers/program_provider.dart';
import 'package:gym_coach/providers/repository_providers.dart';
import 'package:gym_coach/providers/settings_provider.dart';
import 'package:gym_coach/providers/workout_logs_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _nameController = TextEditingController();
  bool _backupBusy = false;
  bool _updateBusy = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _exportBackup() async {
    final l10n = context.l10n;
    setState(() => _backupBusy = true);
    final result = await ref.read(backupRepositoryProvider).exportAndShare(
          subject: l10n.backupShareSubject,
          text: l10n.backupShareText(DateTime.now().toLocal().toString()),
        );
    if (!mounted) return;
    setState(() => _backupBusy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success ? l10n.backupExported : result.error ?? l10n.exportFailed,
        ),
      ),
    );
  }

  String _importErrorMessage(String? code) {
    final l10n = context.l10n;
    return switch (code) {
      BackupErrorCodes.cancelled => l10n.backupCancelled,
      BackupErrorCodes.unableToRead => l10n.backupUnableToRead,
      BackupErrorCodes.invalidFormat => l10n.backupInvalidFormat,
      _ => code ?? l10n.importFailed,
    };
  }

  Future<void> _importBackup() async {
    final l10n = context.l10n;
    setState(() => _backupBusy = true);
    final result =
        await ref.read(backupRepositoryProvider).importFromFilePicker();
    if (!mounted) return;
    setState(() => _backupBusy = false);

    if (result.wasCancelled) return;

    if (result.success) {
      ref.invalidate(settingsProvider);
      ref.invalidate(workoutLogsProvider);
      ref.invalidate(measurementsProvider);
      ref.invalidate(workoutProgramProvider);
      ref.invalidate(allExerciseStrengthProfilesProvider);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result.success
              ? l10n.restoreSuccess(
                  result.workoutLogCount,
                  result.measurementCount,
                )
              : _importErrorMessage(result.error),
        ),
      ),
    );
  }

  Future<void> _restoreFromLocal() async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.restoreBackupTitle),
        content: Text(l10n.restoreBackupBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.restore),
          ),
        ],
      ),
    );
    if (confirmed == true) await _importBackup();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final gymTheme = context.gymTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settings)),
      body: settingsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => Center(child: Text(l10n.errorPrefix('$e'))),
        data: (settings) {
          if (_nameController.text != settings.userName) {
            _nameController.text = settings.userName;
          }

          return ListView(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 32.h),
            children: [
              SectionHeader(title: l10n.appearance),
              GymCard(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: Column(
                  children: [
                    _SettingsTile(
                      title: l10n.theme,
                      subtitle: _themeLabel(l10n, settings.themeMode),
                      trailing: SegmentedButton<AppThemeModeSetting>(
                        segments: const [
                          ButtonSegment(
                            value: AppThemeModeSetting.dark,
                            icon: Icon(Icons.dark_mode_rounded),
                          ),
                          ButtonSegment(
                            value: AppThemeModeSetting.light,
                            icon: Icon(Icons.light_mode_rounded),
                          ),
                          ButtonSegment(
                            value: AppThemeModeSetting.system,
                            icon: Icon(Icons.brightness_auto_rounded),
                          ),
                        ],
                        selected: {settings.themeMode},
                        onSelectionChanged: (s) => ref
                            .read(settingsProvider.notifier)
                            .setTheme(s.first),
                      ),
                    ),
                    Divider(color: gymTheme.border.withValues(alpha: 0.4)),
                    SwitchListTile(
                      title: Text(l10n.amoledTitle),
                      subtitle: Text(l10n.amoledSubtitle),
                      value: settings.amoledBlack,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setAmoled(v),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SectionHeader(title: l10n.language),
              GymCard(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                child: _SettingsTile(
                  title: l10n.language,
                  subtitle: _languageLabel(l10n, settings.language),
                  trailing: SegmentedButton<AppLanguage>(
                    segments: [
                      ButtonSegment(
                        value: AppLanguage.system,
                        label: Text(l10n.languageSystem),
                      ),
                      ButtonSegment(
                        value: AppLanguage.en,
                        label: Text(l10n.languageEnglish),
                      ),
                      ButtonSegment(
                        value: AppLanguage.vi,
                        label: Text(l10n.languageVietnamese),
                      ),
                    ],
                    selected: {settings.language},
                    onSelectionChanged: (s) => ref
                        .read(settingsProvider.notifier)
                        .setLanguage(s.first),
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              SectionHeader(title: l10n.sectionWorkout),
              GymCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.defaultRestTimer,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      children: AppConstants.restPresets.map((seconds) {
                        final selected = settings.restSeconds == seconds;
                        return ChoiceChip(
                          label: Text(l10n.restSecondsLabel(seconds)),
                          selected: selected,
                          onSelected: (_) => ref
                              .read(settingsProvider.notifier)
                              .setRest(seconds),
                        );
                      }).toList(),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      l10n.weightUnit,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    SizedBox(height: 8.h),
                    SegmentedButton<WeightUnit>(
                      segments: [
                        ButtonSegment(value: WeightUnit.kg, label: Text(l10n.unitKg)),
                        ButtonSegment(value: WeightUnit.lbs, label: Text(l10n.unitLbs)),
                      ],
                      selected: {settings.weightUnit},
                      onSelectionChanged: (s) => ref
                          .read(settingsProvider.notifier)
                          .setUnit(s.first),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SectionHeader(title: l10n.feedback),
              GymCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      title: Text(l10n.restTimerSound),
                      value: settings.soundEnabled,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setSound(v),
                    ),
                    Divider(color: gymTheme.border.withValues(alpha: 0.4)),
                    SwitchListTile(
                      title: Text(l10n.restTimerVibration),
                      value: settings.vibrateEnabled,
                      onChanged: (v) => ref
                          .read(settingsProvider.notifier)
                          .setVibrate(v),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              SectionHeader(title: l10n.profile),
              GymCard(
                child: TextField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: l10n.yourName,
                    hintText: l10n.nameHint,
                  ),
                  onSubmitted: (v) => ref
                      .read(settingsProvider.notifier)
                      .setName(v),
                  onEditingComplete: () => ref
                      .read(settingsProvider.notifier)
                      .setName(_nameController.text),
                ),
              ),
              SizedBox(height: 20.h),
              SectionHeader(title: l10n.sectionData),
              GymCard(
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.system_update_rounded),
                      title: Text(l10n.checkForUpdates),
                      subtitle: Text(l10n.checkForUpdatesSubtitle),
                      trailing: _updateBusy
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: _updateBusy
                          ? null
                          : () async {
                              setState(() => _updateBusy = true);
                              await checkForAppUpdate(
                                context,
                                ref,
                                showUpToDateMessage: true,
                              );
                              if (mounted) {
                                setState(() => _updateBusy = false);
                              }
                            },
                    ),
                    Divider(color: gymTheme.border.withValues(alpha: 0.4)),
                    ListTile(
                      leading: const Icon(Icons.upload_rounded),
                      title: Text(l10n.exportBackup),
                      subtitle: Text(l10n.exportBackupSubtitle),
                      trailing: _backupBusy
                          ? SizedBox(
                              width: 24.w,
                              height: 24.w,
                              child: const CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.chevron_right_rounded),
                      onTap: _backupBusy ? null : _exportBackup,
                    ),
                    Divider(color: gymTheme.border.withValues(alpha: 0.4)),
                    ListTile(
                      leading: const Icon(Icons.download_rounded),
                      title: Text(l10n.importBackup),
                      subtitle: Text(l10n.importBackupSubtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _backupBusy ? null : _importBackup,
                    ),
                    Divider(color: gymTheme.border.withValues(alpha: 0.4)),
                    ListTile(
                      leading: const Icon(Icons.restore_rounded),
                      title: Text(l10n.restore),
                      subtitle: Text(l10n.restoreSubtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                      onTap: _backupBusy ? null : _restoreFromLocal,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),
              Center(
                child: Text(
                  l10n.appVersionLabel(AppConstants.appName, AppConstants.appVersion),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: gymTheme.secondaryText,
                      ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeLabel(AppLocalizations l10n, AppThemeModeSetting mode) {
    return switch (mode) {
      AppThemeModeSetting.dark => l10n.themeDark,
      AppThemeModeSetting.light => l10n.themeLight,
      AppThemeModeSetting.system => l10n.themeSystem,
    };
  }

  String _languageLabel(AppLocalizations l10n, AppLanguage language) {
    return switch (language) {
      AppLanguage.system => l10n.languageSystem,
      AppLanguage.en => l10n.languageEnglish,
      AppLanguage.vi => l10n.languageVietnamese,
    };
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  final String title;
  final String subtitle;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: context.gymTheme.secondaryText,
                ),
          ),
          SizedBox(height: 12.h),
          trailing,
        ],
      ),
    );
  }
}
