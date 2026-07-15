import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:gym_coach/core/theme/app_colors.dart';
import 'package:gym_coach/core/theme/app_theme.dart';
import 'package:gym_coach/core/utils/formatters.dart';
import 'package:gym_coach/core/widgets/empty_state.dart';
import 'package:gym_coach/core/widgets/gym_card.dart';
import 'package:gym_coach/core/widgets/loading_view.dart';
import 'package:gym_coach/core/widgets/section_header.dart';
import 'package:gym_coach/data/models/measurement_models.dart';
import 'package:gym_coach/l10n/l10n.dart';
import 'package:gym_coach/providers/exercise_strength_provider.dart';
import 'package:gym_coach/providers/measurement_provider.dart';
import 'package:gym_coach/providers/settings_provider.dart';
import 'package:uuid/uuid.dart';

String _measurementLabel(AppLocalizations l10n, String field) {
  return switch (field) {
    'weight' => l10n.measureBodyWeight,
    'chest' => l10n.measureChest,
    'waist' => l10n.measureWaist,
    'arm' => l10n.measureArm,
    'forearm' => l10n.measureForearm,
    'thigh' => l10n.measureThigh,
    'calf' => l10n.measureCalf,
    'shoulder' => l10n.measureShoulder,
    _ => field,
  };
}

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  String _selectedField = 'weight';

  Future<void> _showAddMeasurementDialog() async {
    final result = await showDialog<BodyMeasurement>(
      context: context,
      builder: (context) => const _AddMeasurementDialog(),
    );
    if (result != null) {
      await ref.read(measurementsProvider.notifier).add(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final measurementsAsync = ref.watch(measurementsProvider);
    final strengthAsync = ref.watch(allExerciseStrengthProfilesProvider);
    final gymTheme = context.gymTheme;
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navProgress),
        actions: [
          TextButton.icon(
            onPressed: () => context.push('/calendar'),
            icon: const Icon(Icons.calendar_month_rounded),
            label: Text(l10n.calendar),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddMeasurementDialog,
        icon: const Icon(Icons.add_rounded),
        label: Text(l10n.addMeasurement),
      ),
      body: measurementsAsync.when(
        loading: () => const LoadingView(),
        error: (e, _) => EmptyState(
          icon: Icons.error_outline_rounded,
          title: l10n.couldNotLoadMeasurements,
          subtitle: e.toString(),
        ),
        data: (measurements) {
          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(title: l10n.bodyMeasurements),
                ),
              ),
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 44.h,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    children: BodyMeasurement.fields.map((field) {
                      final selected = _selectedField == field;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: FilterChip(
                          label: Text(_measurementLabel(l10n, field)),
                          selected: selected,
                          onSelected: (_) => setState(() => _selectedField = field),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 8.h),
                sliver: SliverToBoxAdapter(
                  child: _MeasurementChart(
                    measurements: measurements,
                    field: _selectedField,
                  ).animate().fadeIn(duration: 400.ms),
                ),
              ),
              if (measurements.isEmpty)
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.straighten_rounded,
                    title: l10n.noMeasurementsYet,
                    subtitle: l10n.noMeasurementsSubtitle,
                    actionLabel: l10n.addFirstEntry,
                    onAction: _showAddMeasurementDialog,
                  ),
                ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 8.h),
                sliver: SliverToBoxAdapter(
                  child: SectionHeader(title: l10n.strengthProgress),
                ),
              ),
              strengthAsync.when(
                loading: () => const SliverToBoxAdapter(child: LoadingView()),
                error: (e, _) => SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.error_outline_rounded,
                    title: l10n.strengthUnavailable,
                    subtitle: e.toString(),
                  ),
                ),
                data: (profiles) {
                  if (profiles.isEmpty) {
                    return SliverToBoxAdapter(
                      child: EmptyState(
                        icon: Icons.fitness_center_outlined,
                        title: l10n.noStrengthHistory,
                        subtitle: l10n.noStrengthSubtitle,
                      ),
                    );
                  }

                  final sorted = [...profiles]
                    ..sort((a, b) => b.bestWeight.compareTo(a.bestWeight));
                  final settings = ref.watch(settingsProvider).value;

                  return SliverPadding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 100.h),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final profile = sorted[index];
                          return Padding(
                            padding: EdgeInsets.only(bottom: 10.h),
                            child: GymCard(
                              onTap: () => context.push(
                                '/progress/strength/${profile.exerciseId}',
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44.w,
                                    height: 44.w,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary.withValues(alpha: 0.14),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Icon(
                                      Icons.fitness_center_rounded,
                                      color: AppColors.primary,
                                      size: 22.sp,
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
                                        Text(
                                          profile.muscleGroup,
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(color: gymTheme.secondaryText),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        Formatters.formatWeight(
                                          profile.bestWeight,
                                          unit: settings?.weightUnit,
                                          l10n: l10n,
                                        ),
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              fontWeight: FontWeight.w800,
                                              color: AppColors.accent,
                                            ),
                                      ),
                                      Text(
                                        l10n.sessionsCount(profile.history.length),
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelSmall
                                            ?.copyWith(color: gymTheme.secondaryText),
                                      ),
                                    ],
                                  ),
                                  Icon(
                                    Icons.chevron_right_rounded,
                                    color: gymTheme.secondaryText,
                                  ),
                                ],
                              ),
                            ).animate().fadeIn(delay: (index * 50).ms),
                          );
                        },
                        childCount: sorted.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MeasurementChart extends StatelessWidget {
  const _MeasurementChart({
    required this.measurements,
    required this.field,
  });

  final List<BodyMeasurement> measurements;
  final String field;

  @override
  Widget build(BuildContext context) {
    final gymTheme = context.gymTheme;
    final textTheme = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final fieldLabel = _measurementLabel(l10n, field);
    // Chart X-axis must run oldest → newest.
    final points = measurements
        .where((m) => m.valueOf(field) != null)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (points.length < 2) {
      return GymCard(
        child: SizedBox(
          height: 180.h,
          child: Center(
            child: Text(
              points.isEmpty
                  ? l10n.needTwoEntries
                  : l10n.needOneMoreEntry(fieldLabel),
              style: textTheme.bodyMedium?.copyWith(color: gymTheme.secondaryText),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    final spots = <FlSpot>[];
    for (var i = 0; i < points.length; i++) {
      spots.add(FlSpot(i.toDouble(), points[i].valueOf(field)!));
    }

    final minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    final maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) * 0.15 + 1;

    return GymCard(
      padding: EdgeInsets.fromLTRB(12.w, 16.h, 16.w, 12.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            fieldLabel,
            style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 200.h,
            child: LineChart(
              LineChartData(
                minY: minY - padding,
                maxY: maxY + padding,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: gymTheme.border.withValues(alpha: 0.5),
                    strokeWidth: 1,
                  ),
                ),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 40.w,
                      getTitlesWidget: (value, _) => Text(
                        value.toStringAsFixed(0),
                        style: textTheme.labelSmall?.copyWith(
                          color: gymTheme.secondaryText,
                          fontSize: 10.sp,
                        ),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      interval: (points.length / 4).ceilToDouble().clamp(1, 999),
                      getTitlesWidget: (value, _) {
                        final index = value.toInt();
                        if (index < 0 || index >= points.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Text(
                            Formatters.formatChartDate(points[index].date, l10n: l10n),
                            style: textTheme.labelSmall?.copyWith(
                              color: gymTheme.secondaryText,
                              fontSize: 9.sp,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: AppColors.primary,
                    barWidth: 3,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, bar, index) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: AppColors.primary,
                        strokeWidth: 2,
                        strokeColor: Theme.of(context).cardColor,
                      ),
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      color: AppColors.primary.withValues(alpha: 0.12),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddMeasurementDialog extends StatefulWidget {
  const _AddMeasurementDialog();

  @override
  State<_AddMeasurementDialog> createState() => _AddMeasurementDialogState();
}

class _AddMeasurementDialogState extends State<_AddMeasurementDialog> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _chestCtrl = TextEditingController();
  final _waistCtrl = TextEditingController();
  final _armCtrl = TextEditingController();
  final _forearmCtrl = TextEditingController();
  final _thighCtrl = TextEditingController();
  final _calfCtrl = TextEditingController();
  final _shoulderCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _weightCtrl.dispose();
    _chestCtrl.dispose();
    _waistCtrl.dispose();
    _armCtrl.dispose();
    _forearmCtrl.dispose();
    _thighCtrl.dispose();
    _calfCtrl.dispose();
    _shoulderCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  double? _parse(String text) {
    if (text.trim().isEmpty) return null;
    return double.tryParse(text.trim());
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AlertDialog(
      title: Text(l10n.addMeasurementTitle),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.date),
                subtitle: Text(Formatters.formatShortDate(_date, l10n: l10n)),
                trailing: IconButton(
                  icon: const Icon(Icons.calendar_today_rounded),
                  onPressed: () async {
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (picked != null) setState(() => _date = picked);
                  },
                ),
              ),
              _field(l10n.weightKg, _weightCtrl),
              _field(l10n.chestCm, _chestCtrl),
              _field(l10n.waistCm, _waistCtrl),
              _field(l10n.armCm, _armCtrl),
              _field(l10n.forearmCm, _forearmCtrl),
              _field(l10n.thighCm, _thighCtrl),
              _field(l10n.calfCm, _calfCtrl),
              _field(l10n.shoulderCm, _shoulderCtrl),
              TextField(
                controller: _notesCtrl,
                decoration: InputDecoration(labelText: l10n.notes),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            final measurement = BodyMeasurement(
              id: const Uuid().v4(),
              date: _date,
              weight: _parse(_weightCtrl.text),
              chest: _parse(_chestCtrl.text),
              waist: _parse(_waistCtrl.text),
              arm: _parse(_armCtrl.text),
              forearm: _parse(_forearmCtrl.text),
              thigh: _parse(_thighCtrl.text),
              calf: _parse(_calfCtrl.text),
              shoulder: _parse(_shoulderCtrl.text),
              notes: _notesCtrl.text.trim().isEmpty
                  ? null
                  : _notesCtrl.text.trim(),
            );
            if (measurement.weight == null &&
                measurement.chest == null &&
                measurement.waist == null &&
                measurement.arm == null &&
                measurement.forearm == null &&
                measurement.thigh == null &&
                measurement.calf == null &&
                measurement.shoulder == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.enterAtLeastOneMeasurement)),
              );
              return;
            }
            Navigator.pop(context, measurement);
          },
          child: Text(l10n.save),
        ),
      ],
    );
  }

  Widget _field(String label, TextEditingController controller) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}
