import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/widgets/empty_state.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/data/models/local_profile.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/profile_provider.dart';
import 'package:gym_coach/providers/settings_provider.dart';

class ProfileSelectionScreen extends ConsumerStatefulWidget {
  const ProfileSelectionScreen({super.key});

  @override
  ConsumerState<ProfileSelectionScreen> createState() =>
      _ProfileSelectionScreenState();
}

class _ProfileSelectionScreenState
    extends ConsumerState<ProfileSelectionScreen> {
  bool _busy = false;

  Future<void> _switchTo(LocalProfile profile) async {
    final l10n = context.l10n;
    setState(() => _busy = true);
    try {
      await ref.read(profilesProvider.notifier).switchTo(profile.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileSwitched(profile.name))),
      );
      Navigator.of(context).maybePop();
    } on ActiveWorkoutInProgressException {
      if (!mounted) return;
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(l10n.switchWhileWorkoutTitle),
          content: Text(l10n.switchWhileWorkoutBody),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      );
      if (confirmed == true) {
        await ref
            .read(profilesProvider.notifier)
            .switchTo(profile.id, force: true);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.profileSwitched(profile.name))),
        );
        Navigator.of(context).maybePop();
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _createProfile() async {
    final l10n = context.l10n;
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.createProfile),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            labelText: l10n.yourName,
            hintText: l10n.profileNameHint,
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;

    setState(() => _busy = true);
    try {
      final created = await ref.read(profilesProvider.notifier).create(name);
      await ref.read(profilesProvider.notifier).switchTo(created.id);
      await ref.read(settingsProvider.notifier).setName(name);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileCreated)),
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _rename(LocalProfile profile) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: profile.name);
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.renameProfile),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.yourName),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.save),
          ),
        ],
      ),
    );
    if (name == null || name.isEmpty) return;
    await ref.read(profilesProvider.notifier).rename(profile.id, name);
  }

  Future<void> _delete(LocalProfile profile) async {
    final l10n = context.l10n;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.deleteProfileTitle),
        content: Text(l10n.deleteProfileBody(profile.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.deleteProfile),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    try {
      await ref.read(profilesProvider.notifier).delete(profile.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileDeleted)),
      );
    } on CannotDeleteLastProfileException {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.cannotDeleteLastProfile)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final profilesAsync = ref.watch(profilesProvider);
    final activeId = ref.watch(activeProfileIdProvider);
    final l10n = context.l10n;
    final gymTheme = context.gymTheme;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilesTitle)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _createProfile,
        icon: const Icon(Icons.person_add_alt_1_rounded),
        label: Text(l10n.addProfile),
      ),
      body: profilesAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.unknownError,
          subtitle: e.toString(),
        ),
        data: (profiles) {
          if (profiles.isEmpty) {
            return EmptyState(
              icon: Icons.people_outline_rounded,
              title: l10n.profilesTitle,
              subtitle: l10n.profilesSubtitle,
              actionLabel: l10n.addProfile,
              onAction: _createProfile,
            );
          }

          return ListView.separated(
            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 100.h),
            itemCount: profiles.length,
            separatorBuilder: (_, _) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              final profile = profiles[index];
              final selected = profile.id == activeId;
              return GymCard(
                onTap: _busy || selected ? null : () => _switchTo(profile),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24.r,
                      backgroundColor:
                          AppColors.primary.withValues(alpha: 0.18),
                      child: Text(
                        profile.initials,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleSmall
                                ?.copyWith(fontWeight: FontWeight.w700),
                          ),
                          if (selected)
                            Text(
                              l10n.activeBadge,
                              style: Theme.of(context)
                                  .textTheme
                                  .labelSmall
                                  ?.copyWith(color: AppColors.accent),
                            ),
                        ],
                      ),
                    ),
                    if (selected)
                      Icon(Icons.check_circle_rounded, color: gymTheme.success),
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'rename') _rename(profile);
                        if (value == 'delete') _delete(profile);
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'rename',
                          child: Text(l10n.renameProfile),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text(l10n.deleteProfile),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
