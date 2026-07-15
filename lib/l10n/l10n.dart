import 'package:flutter/widgets.dart';
import 'package:gym_coach/l10n/app_localizations.dart';

export 'package:gym_coach/l10n/app_localizations.dart';

extension AppLocalizationsX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}
