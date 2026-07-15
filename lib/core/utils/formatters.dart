import 'package:flutter/widgets.dart';
import 'package:gym_coach/l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../data/models/app_settings.dart';

/// Display formatters for durations, weights, volumes, dates, and greetings.
abstract final class Formatters {
  static final DateFormat _shortDate = DateFormat('MMM d, yyyy');
  static final DateFormat _mediumDate = DateFormat('EEEE, MMM d');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _dateTime = DateFormat('MMM d, yyyy · h:mm a');
  static final DateFormat _chartDate = DateFormat('MMM d');
  static final NumberFormat _weightKg = NumberFormat('#,##0.#');
  static final NumberFormat _volume = NumberFormat('#,##0');

  static String? _localeName(AppLocalizations? l10n, Locale? locale) {
    if (l10n != null) return l10n.localeName;
    if (locale != null) return locale.toString();
    return null;
  }

  static DateFormat _localizedDate(String pattern, {AppLocalizations? l10n, Locale? locale}) {
    final name = _localeName(l10n, locale);
    return name != null ? DateFormat(pattern, name) : DateFormat(pattern);
  }

  /// Formats a [Duration] as `MM:SS` or `H:MM:SS` when over one hour.
  static String formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds.abs();
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;

    if (hours > 0) {
      return '$hours:${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  static const double _lbsPerKg = 2.2046226218;

  /// Converts stored kg to the display unit.
  static double kgToDisplay(double kg, WeightUnit unit) =>
      unit == WeightUnit.lbs ? kg * _lbsPerKg : kg;

  /// Converts a display-unit value back to stored kg.
  static double displayToKg(double display, WeightUnit unit) =>
      unit == WeightUnit.lbs ? display / _lbsPerKg : display;

  /// Formats total lifted volume. [volumeKg] is always stored as kg×reps.
  static String formatVolume(
    double volumeKg, {
    WeightUnit? unit,
    AppLocalizations? l10n,
  }) {
    final resolved = unit ?? WeightUnit.kg;
    final display = kgToDisplay(volumeKg, resolved);
    final suffix = resolved == WeightUnit.kg
        ? (l10n?.unitKg ?? 'kg')
        : (l10n?.unitLbs ?? 'lbs');
    return '${_volume.format(display)} $suffix';
  }

  /// Formats a weight. [weightKg] is always stored as kilograms.
  static String formatWeight(
    double weightKg, {
    WeightUnit? unit,
    AppLocalizations? l10n,
  }) {
    final resolved = unit ?? WeightUnit.kg;
    final display = kgToDisplay(weightKg, resolved);
    final suffix = resolved == WeightUnit.kg
        ? (l10n?.unitKg ?? 'kg')
        : (l10n?.unitLbs ?? 'lbs');
    return '${_weightKg.format(display)} $suffix';
  }

  /// Returns a time-of-day greeting for [hour] (0–23).
  static String greetingByHour(
    AppLocalizations l10n,
    int hour, {
    String? name,
  }) {
    final displayName = name?.trim().isNotEmpty == true ? name!.trim() : null;
    final suffix = displayName != null ? ', $displayName' : '';

    if (hour >= 5 && hour < 12) {
      return '${l10n.greetingMorning}$suffix';
    }
    if (hour >= 12 && hour < 17) {
      return '${l10n.greetingAfternoon}$suffix';
    }
    if (hour >= 17 && hour < 22) {
      return '${l10n.greetingEvening}$suffix';
    }
    return '${l10n.greetingNight}$suffix';
  }

  /// Greeting based on the current local time.
  static String greetingNow(AppLocalizations l10n, {String? name}) {
    return greetingByHour(l10n, DateTime.now().hour, name: name);
  }

  static String formatShortDate(
    DateTime date, {
    AppLocalizations? l10n,
    Locale? locale,
  }) {
    final name = _localeName(l10n, locale);
    return name != null
        ? DateFormat('MMM d, yyyy', name).format(date)
        : _shortDate.format(date);
  }

  static String formatMediumDate(
    DateTime date, {
    AppLocalizations? l10n,
    Locale? locale,
  }) {
    final name = _localeName(l10n, locale);
    return name != null
        ? DateFormat('EEEE, MMM d', name).format(date)
        : _mediumDate.format(date);
  }

  static String formatTime(
    DateTime date, {
    AppLocalizations? l10n,
    Locale? locale,
  }) {
    final name = _localeName(l10n, locale);
    return name != null
        ? DateFormat('h:mm a', name).format(date)
        : _time.format(date);
  }

  static String formatDateTime(
    DateTime date, {
    AppLocalizations? l10n,
    Locale? locale,
  }) {
    final name = _localeName(l10n, locale);
    return name != null
        ? DateFormat('MMM d, yyyy · h:mm a', name).format(date)
        : _dateTime.format(date);
  }

  static String formatChartDate(
    DateTime date, {
    AppLocalizations? l10n,
    Locale? locale,
  }) {
    final name = _localeName(l10n, locale);
    return name != null
        ? DateFormat('MMM d', name).format(date)
        : _chartDate.format(date);
  }

  /// Relative label such as "Today", "Yesterday", or a short date.
  static String formatRelativeDate(
    DateTime date, {
    required AppLocalizations l10n,
  }) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return l10n.relativeToday;
    if (diff == 1) return l10n.relativeYesterday;
    if (diff < 7) {
      return _localizedDate('EEEE', l10n: l10n).format(date);
    }
    return formatShortDate(date, l10n: l10n);
  }
}
