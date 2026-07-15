import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/core/utils/reps_parser.dart';
import 'package:gym_coach/core/widgets/badge_chip.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/muscle_chip.dart';
import 'package:gym_coach/data/models/app_settings.dart';
import 'package:gym_coach/data/models/program_models.dart';
import 'package:gym_coach/data/models/workout_log.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class ExerciseSessionCard extends StatefulWidget {
  const ExerciseSessionCard({
    super.key,
    required this.template,
    required this.loggedExercise,
    required this.weightUnit,
    required this.onSetToggled,
    required this.onWeightChanged,
    required this.onRepsChanged,
    required this.onNotesChanged,
    this.initiallyExpanded = false,
  });

  final ExerciseTemplate template;
  final LoggedExercise loggedExercise;
  final WeightUnit weightUnit;

  /// Toggles set completion. The parent owns rest-timer/sheet decisions and
  /// resolves the rest duration once this future completes.
  final Future<void> Function(int setIndex, bool completed) onSetToggled;
  final void Function(int setIndex, double weight) onWeightChanged;
  final void Function(int setIndex, int reps) onRepsChanged;
  final void Function(String notes) onNotesChanged;
  final bool initiallyExpanded;

  @override
  State<ExerciseSessionCard> createState() => _ExerciseSessionCardState();
}

class _ExerciseSessionCardState extends State<ExerciseSessionCard> {
  late bool _expanded;
  late TextEditingController _notesController;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
    _notesController = TextEditingController(text: widget.loggedExercise.notes);
  }

  @override
  void didUpdateWidget(covariant ExerciseSessionCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loggedExercise.notes != widget.loggedExercise.notes &&
        _notesController.text != widget.loggedExercise.notes) {
      _notesController.text = widget.loggedExercise.notes;
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _showVideo(BuildContext context) async {
    final l10n = context.l10n;
    final url = widget.template.videoUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noVideoAvailable)),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noVideoAvailable)),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.openingVideo(widget.template.name))),
    );

    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      await SharePlus.instance.share(
        ShareParams(
          text: url,
          subject: l10n.videoShareSubject(widget.template.name),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final completedCount = widget.loggedExercise.completedSets;
    final totalSets = widget.loggedExercise.sets.length;

    return GymCard(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
            child: Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.template.name,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Row(
                          children: [
                            MuscleChip(label: widget.template.muscleGroup),
                            SizedBox(width: 8.w),
                            Text(
                              l10n.setsProgress(completedCount, totalSets),
                              style: textTheme.labelSmall?.copyWith(
                                color: gymTheme.secondaryText,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Wrap(
                          spacing: 6.w,
                          runSpacing: 6.h,
                          children: [
                            if (widget.template.isDropSet)
                              const BadgeChip.dropSet(compact: true),
                            if (widget.template.isFail)
                              const BadgeChip.fail(compact: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (widget.template.videoUrl != null)
                    IconButton(
                      onPressed: () => _showVideo(context),
                      icon: Icon(Icons.play_circle_outline_rounded, size: 28.sp),
                      tooltip: l10n.watchDemo,
                    ),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: gymTheme.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Divider(color: gymTheme.border.withValues(alpha: 0.5)),
                  SizedBox(height: 8.h),
                  Text(
                    l10n.targetSetsReps(
                      widget.template.sets,
                      widget.template.reps,
                    ),
                    style: textTheme.labelMedium?.copyWith(
                      color: gymTheme.secondaryText,
                    ),
                  ),
                  if (widget.loggedExercise.previousBestWeight != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      l10n.previousBest(
                        Formatters.formatWeight(
                          widget.loggedExercise.previousBestWeight!,
                          unit: widget.weightUnit,
                        ),
                      ),
                      style: textTheme.labelSmall?.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  if (widget.template.tips != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      widget.template.tips!,
                      style: textTheme.bodySmall?.copyWith(
                        color: gymTheme.secondaryText,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  SizedBox(height: 12.h),
                  ...widget.loggedExercise.sets.asMap().entries.map((entry) {
                    return _SetRow(
                      setIndex: entry.key,
                      loggedSet: entry.value,
                      targetReps: parseTargetReps(widget.template.reps),
                      weightUnit: widget.weightUnit,
                      onToggle: (completed) =>
                          widget.onSetToggled(entry.key, completed),
                      onWeightChanged: (w) =>
                          widget.onWeightChanged(entry.key, w),
                      onRepsChanged: (r) =>
                          widget.onRepsChanged(entry.key, r),
                    );
                  }),
                  SizedBox(height: 12.h),
                  TextField(
                    controller: _notesController,
                    decoration: InputDecoration(
                      labelText: l10n.notes,
                      hintText: l10n.notesHint,
                    ),
                    maxLines: 2,
                    onChanged: widget.onNotesChanged,
                  ),
                ],
              ),
            ),
            crossFadeState: _expanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 280),
            sizeCurve: Curves.easeOutCubic,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SetRow extends StatefulWidget {
  const _SetRow({
    required this.setIndex,
    required this.loggedSet,
    required this.targetReps,
    required this.weightUnit,
    required this.onToggle,
    required this.onWeightChanged,
    required this.onRepsChanged,
  });

  final int setIndex;
  final LoggedSet loggedSet;
  final int targetReps;
  final WeightUnit weightUnit;
  final ValueChanged<bool> onToggle;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<int> onRepsChanged;

  @override
  State<_SetRow> createState() => _SetRowState();
}

class _SetRowState extends State<_SetRow> {
  late TextEditingController _weightController;
  late TextEditingController _repsController;

  @override
  void initState() {
    super.initState();
    final display = Formatters.kgToDisplay(
      widget.loggedSet.weight,
      widget.weightUnit,
    );
    _weightController = TextEditingController(
      text: widget.loggedSet.weight > 0
          ? _formatDisplay(display)
          : '',
    );
    _repsController = TextEditingController(
      text: widget.loggedSet.reps > 0
          ? widget.loggedSet.reps.toString()
          : widget.targetReps.toString(),
    );
  }

  String _formatDisplay(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(1);
  }

  @override
  void didUpdateWidget(covariant _SetRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.loggedSet.weight != widget.loggedSet.weight ||
        oldWidget.weightUnit != widget.weightUnit) {
      final display = Formatters.kgToDisplay(
        widget.loggedSet.weight,
        widget.weightUnit,
      );
      final text = widget.loggedSet.weight > 0 ? _formatDisplay(display) : '';
      if (_weightController.text != text) _weightController.text = text;
    }
    if (oldWidget.loggedSet.reps != widget.loggedSet.reps &&
        widget.loggedSet.reps > 0) {
      _repsController.text = widget.loggedSet.reps.toString();
    }
  }

  @override
  void dispose() {
    _weightController.dispose();
    _repsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final l10n = context.l10n;
    final unitLabel =
        widget.weightUnit == WeightUnit.kg ? l10n.unitKg : l10n.unitLbs;

    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        children: [
          SizedBox(
            width: 36.w,
            child: Text(
              '${widget.setIndex + 1}',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: gymTheme.secondaryText,
                  ),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: _weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: unitLabel,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 14.h,
                ),
                constraints: BoxConstraints(minHeight: 48.h),
              ),
              onChanged: (v) {
                final parsed = double.tryParse(v);
                if (parsed != null) {
                  widget.onWeightChanged(
                    Formatters.displayToKg(parsed, widget.weightUnit),
                  );
                }
              },
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _repsController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: l10n.reps,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 14.h,
                ),
                constraints: BoxConstraints(minHeight: 48.h),
              ),
              onChanged: (v) {
                final parsed = int.tryParse(v);
                if (parsed != null) widget.onRepsChanged(parsed);
              },
            ),
          ),
          SizedBox(width: 4.w),
          Checkbox(
            value: widget.loggedSet.completed,
            onChanged: (v) => widget.onToggle(v ?? false),
          ),
        ],
      ),
    );
  }
}
