import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('vi'),
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Gym Coach'**
  String get appName;

  /// No description provided for @splashTagline.
  ///
  /// In en, this message translates to:
  /// **'Train smarter. Lift stronger.'**
  String get splashTagline;

  /// No description provided for @splashLoading.
  ///
  /// In en, this message translates to:
  /// **'Preparing your program…'**
  String get splashLoading;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get navWorkouts;

  /// No description provided for @navProgress.
  ///
  /// In en, this message translates to:
  /// **'Progress'**
  String get navProgress;

  /// No description provided for @navStats.
  ///
  /// In en, this message translates to:
  /// **'Stats'**
  String get navStats;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @restore.
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get restore;

  /// No description provided for @goBack.
  ///
  /// In en, this message translates to:
  /// **'Go back'**
  String get goBack;

  /// No description provided for @goHome.
  ///
  /// In en, this message translates to:
  /// **'Go home'**
  String get goHome;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading…'**
  String get loading;

  /// No description provided for @errorPrefix.
  ///
  /// In en, this message translates to:
  /// **'Error: {message}'**
  String errorPrefix(String message);

  /// No description provided for @couldNotLoadProgram.
  ///
  /// In en, this message translates to:
  /// **'Could not load program'**
  String get couldNotLoadProgram;

  /// No description provided for @settingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Settings unavailable'**
  String get settingsUnavailable;

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'Current streak'**
  String get currentStreak;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count} days'**
  String streakDays(int count);

  /// No description provided for @thisWeek.
  ///
  /// In en, this message translates to:
  /// **'This week'**
  String get thisWeek;

  /// No description provided for @weekDone.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} done'**
  String weekDone(int completed, int total);

  /// No description provided for @totalWorkouts.
  ///
  /// In en, this message translates to:
  /// **'Total workouts'**
  String get totalWorkouts;

  /// No description provided for @yourStatistics.
  ///
  /// In en, this message translates to:
  /// **'Your Statistics'**
  String get yourStatistics;

  /// No description provided for @workouts.
  ///
  /// In en, this message translates to:
  /// **'Workouts'**
  String get workouts;

  /// No description provided for @keepItUp.
  ///
  /// In en, this message translates to:
  /// **'Keep it up!'**
  String get keepItUp;

  /// No description provided for @startToday.
  ///
  /// In en, this message translates to:
  /// **'Start today'**
  String get startToday;

  /// No description provided for @trainingHours.
  ///
  /// In en, this message translates to:
  /// **'Training hours'**
  String get trainingHours;

  /// No description provided for @hoursLogged.
  ///
  /// In en, this message translates to:
  /// **'hours logged'**
  String get hoursLogged;

  /// No description provided for @totalVolume.
  ///
  /// In en, this message translates to:
  /// **'Total volume'**
  String get totalVolume;

  /// No description provided for @allTimeLifted.
  ///
  /// In en, this message translates to:
  /// **'all time lifted'**
  String get allTimeLifted;

  /// No description provided for @favoriteExerciseLabel.
  ///
  /// In en, this message translates to:
  /// **'Favorite: {exercise}'**
  String favoriteExerciseLabel(String exercise);

  /// No description provided for @weekNumber.
  ///
  /// In en, this message translates to:
  /// **'Week {number}'**
  String weekNumber(int number);

  /// No description provided for @weekDayBadge.
  ///
  /// In en, this message translates to:
  /// **'Week {week} · Day {day}'**
  String weekDayBadge(int week, int day);

  /// No description provided for @minutesShort.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String minutesShort(int minutes);

  /// No description provided for @exercisesCount.
  ///
  /// In en, this message translates to:
  /// **'{count} exercises'**
  String exercisesCount(int count);

  /// No description provided for @setsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sets'**
  String setsCount(int count);

  /// No description provided for @quickStart.
  ///
  /// In en, this message translates to:
  /// **'Quick Start'**
  String get quickStart;

  /// No description provided for @trainAgain.
  ///
  /// In en, this message translates to:
  /// **'Train Again'**
  String get trainAgain;

  /// No description provided for @programUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Program unavailable'**
  String get programUnavailable;

  /// No description provided for @trainingDaysCount.
  ///
  /// In en, this message translates to:
  /// **'{count} training days'**
  String trainingDaysCount(int count);

  /// No description provided for @startingWorkout.
  ///
  /// In en, this message translates to:
  /// **'Starting workout…'**
  String get startingWorkout;

  /// No description provided for @workoutUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Workout unavailable'**
  String get workoutUnavailable;

  /// No description provided for @workoutDayNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout day not found'**
  String get workoutDayNotFound;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @weekElapsed.
  ///
  /// In en, this message translates to:
  /// **'Week {week} · {elapsed}'**
  String weekElapsed(int week, String elapsed);

  /// No description provided for @finish.
  ///
  /// In en, this message translates to:
  /// **'Finish'**
  String get finish;

  /// No description provided for @finishWorkout.
  ///
  /// In en, this message translates to:
  /// **'Finish Workout'**
  String get finishWorkout;

  /// No description provided for @noVideoAvailable.
  ///
  /// In en, this message translates to:
  /// **'No video available for this exercise'**
  String get noVideoAvailable;

  /// No description provided for @openingVideo.
  ///
  /// In en, this message translates to:
  /// **'Opening video: {name}'**
  String openingVideo(String name);

  /// No description provided for @setsProgress.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} sets'**
  String setsProgress(int completed, int total);

  /// No description provided for @watchDemo.
  ///
  /// In en, this message translates to:
  /// **'Watch demo'**
  String get watchDemo;

  /// No description provided for @targetSetsReps.
  ///
  /// In en, this message translates to:
  /// **'Target: {sets} × {reps}'**
  String targetSetsReps(int sets, String reps);

  /// No description provided for @previousBest.
  ///
  /// In en, this message translates to:
  /// **'Previous best: {weight}'**
  String previousBest(String weight);

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @notesHint.
  ///
  /// In en, this message translates to:
  /// **'Form cues, how it felt…'**
  String get notesHint;

  /// No description provided for @reps.
  ///
  /// In en, this message translates to:
  /// **'Reps'**
  String get reps;

  /// No description provided for @summary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get summary;

  /// No description provided for @loadingSummary.
  ///
  /// In en, this message translates to:
  /// **'Loading summary…'**
  String get loadingSummary;

  /// No description provided for @couldNotLoadSummary.
  ///
  /// In en, this message translates to:
  /// **'Could not load summary'**
  String get couldNotLoadSummary;

  /// No description provided for @workoutNotFound.
  ///
  /// In en, this message translates to:
  /// **'Workout not found'**
  String get workoutNotFound;

  /// No description provided for @workoutNotFoundSubtitle.
  ///
  /// In en, this message translates to:
  /// **'This session may have been removed.'**
  String get workoutNotFoundSubtitle;

  /// No description provided for @workoutComplete.
  ///
  /// In en, this message translates to:
  /// **'Workout Complete'**
  String get workoutComplete;

  /// No description provided for @greatWork.
  ///
  /// In en, this message translates to:
  /// **'Great work!'**
  String get greatWork;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @exercises.
  ///
  /// In en, this message translates to:
  /// **'Exercises'**
  String get exercises;

  /// No description provided for @prs.
  ///
  /// In en, this message translates to:
  /// **'PRs'**
  String get prs;

  /// No description provided for @calories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get calories;

  /// No description provided for @sessionNotes.
  ///
  /// In en, this message translates to:
  /// **'Session notes'**
  String get sessionNotes;

  /// No description provided for @sessionNotesHint.
  ///
  /// In en, this message translates to:
  /// **'How did it feel? Any PRs or adjustments?'**
  String get sessionNotesHint;

  /// No description provided for @saveAndGoHome.
  ///
  /// In en, this message translates to:
  /// **'Save & Go Home'**
  String get saveAndGoHome;

  /// No description provided for @calendar.
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendar;

  /// No description provided for @addMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Add measurement'**
  String get addMeasurement;

  /// No description provided for @couldNotLoadMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Could not load measurements'**
  String get couldNotLoadMeasurements;

  /// No description provided for @bodyMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Body Measurements'**
  String get bodyMeasurements;

  /// No description provided for @noMeasurementsYet.
  ///
  /// In en, this message translates to:
  /// **'No measurements yet'**
  String get noMeasurementsYet;

  /// No description provided for @noMeasurementsSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track weight and body metrics over time.'**
  String get noMeasurementsSubtitle;

  /// No description provided for @addFirstEntry.
  ///
  /// In en, this message translates to:
  /// **'Add first entry'**
  String get addFirstEntry;

  /// No description provided for @strengthProgress.
  ///
  /// In en, this message translates to:
  /// **'Strength Progress'**
  String get strengthProgress;

  /// No description provided for @strengthUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Strength data unavailable'**
  String get strengthUnavailable;

  /// No description provided for @noStrengthHistory.
  ///
  /// In en, this message translates to:
  /// **'No strength history'**
  String get noStrengthHistory;

  /// No description provided for @noStrengthSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to track lifts.'**
  String get noStrengthSubtitle;

  /// No description provided for @sessionsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} sessions'**
  String sessionsCount(int count);

  /// No description provided for @needTwoEntries.
  ///
  /// In en, this message translates to:
  /// **'Add at least 2 entries to see a trend'**
  String get needTwoEntries;

  /// No description provided for @needOneMoreEntry.
  ///
  /// In en, this message translates to:
  /// **'Add one more entry to chart {field}'**
  String needOneMoreEntry(String field);

  /// No description provided for @addMeasurementTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Measurement'**
  String get addMeasurementTitle;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @weightKg.
  ///
  /// In en, this message translates to:
  /// **'Weight (kg)'**
  String get weightKg;

  /// No description provided for @chestCm.
  ///
  /// In en, this message translates to:
  /// **'Chest (cm)'**
  String get chestCm;

  /// No description provided for @waistCm.
  ///
  /// In en, this message translates to:
  /// **'Waist (cm)'**
  String get waistCm;

  /// No description provided for @armCm.
  ///
  /// In en, this message translates to:
  /// **'Arm (cm)'**
  String get armCm;

  /// No description provided for @enterAtLeastOneMeasurement.
  ///
  /// In en, this message translates to:
  /// **'Enter at least one measurement'**
  String get enterAtLeastOneMeasurement;

  /// No description provided for @measureBodyWeight.
  ///
  /// In en, this message translates to:
  /// **'Body Weight'**
  String get measureBodyWeight;

  /// No description provided for @measureChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get measureChest;

  /// No description provided for @measureWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get measureWaist;

  /// No description provided for @measureArm.
  ///
  /// In en, this message translates to:
  /// **'Arm'**
  String get measureArm;

  /// No description provided for @measureForearm.
  ///
  /// In en, this message translates to:
  /// **'Forearm'**
  String get measureForearm;

  /// No description provided for @measureThigh.
  ///
  /// In en, this message translates to:
  /// **'Thigh'**
  String get measureThigh;

  /// No description provided for @measureCalf.
  ///
  /// In en, this message translates to:
  /// **'Calf'**
  String get measureCalf;

  /// No description provided for @measureShoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get measureShoulder;

  /// No description provided for @strengthDetail.
  ///
  /// In en, this message translates to:
  /// **'Strength Detail'**
  String get strengthDetail;

  /// No description provided for @couldNotLoadHistory.
  ///
  /// In en, this message translates to:
  /// **'Could not load history'**
  String get couldNotLoadHistory;

  /// No description provided for @noHistoryYet.
  ///
  /// In en, this message translates to:
  /// **'No history yet'**
  String get noHistoryYet;

  /// No description provided for @noHistorySubtitle.
  ///
  /// In en, this message translates to:
  /// **'Complete sets for this exercise to build a chart.'**
  String get noHistorySubtitle;

  /// No description provided for @bestWeight.
  ///
  /// In en, this message translates to:
  /// **'Best weight'**
  String get bestWeight;

  /// No description provided for @bestReps.
  ///
  /// In en, this message translates to:
  /// **'Best reps'**
  String get bestReps;

  /// No description provided for @bestVolume.
  ///
  /// In en, this message translates to:
  /// **'Best volume'**
  String get bestVolume;

  /// No description provided for @weightOverTime.
  ///
  /// In en, this message translates to:
  /// **'Weight over time'**
  String get weightOverTime;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @repsCount.
  ///
  /// In en, this message translates to:
  /// **'{count} reps'**
  String repsCount(int count);

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @favoriteExercise.
  ///
  /// In en, this message translates to:
  /// **'Favorite exercise'**
  String get favoriteExercise;

  /// No description provided for @mostLogged.
  ///
  /// In en, this message translates to:
  /// **'most logged'**
  String get mostLogged;

  /// No description provided for @mostTrainedMuscle.
  ///
  /// In en, this message translates to:
  /// **'Most trained muscle'**
  String get mostTrainedMuscle;

  /// No description provided for @longestStreak.
  ///
  /// In en, this message translates to:
  /// **'Longest streak'**
  String get longestStreak;

  /// No description provided for @weeklyTrend.
  ///
  /// In en, this message translates to:
  /// **'Weekly trend'**
  String get weeklyTrend;

  /// No description provided for @volume.
  ///
  /// In en, this message translates to:
  /// **'Volume'**
  String get volume;

  /// No description provided for @completeWorkoutsForTrends.
  ///
  /// In en, this message translates to:
  /// **'Complete workouts to see trends'**
  String get completeWorkoutsForTrends;

  /// No description provided for @lifetimeVolume.
  ///
  /// In en, this message translates to:
  /// **'Lifetime volume: {volume}'**
  String lifetimeVolume(String volume);

  /// No description provided for @trainingCalendar.
  ///
  /// In en, this message translates to:
  /// **'Training Calendar'**
  String get trainingCalendar;

  /// No description provided for @longestStreakLabel.
  ///
  /// In en, this message translates to:
  /// **'Longest: {count} days'**
  String longestStreakLabel(int count);

  /// No description provided for @legendCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get legendCompleted;

  /// No description provided for @legendMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get legendMissed;

  /// No description provided for @legendToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get legendToday;

  /// No description provided for @restDayElsewhere.
  ///
  /// In en, this message translates to:
  /// **'Rest day logged elsewhere'**
  String get restDayElsewhere;

  /// No description provided for @noWorkoutThisDay.
  ///
  /// In en, this message translates to:
  /// **'No workout logged this day'**
  String get noWorkoutThisDay;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @backupExported.
  ///
  /// In en, this message translates to:
  /// **'Backup exported successfully'**
  String get backupExported;

  /// No description provided for @exportFailed.
  ///
  /// In en, this message translates to:
  /// **'Export failed'**
  String get exportFailed;

  /// No description provided for @restoreSuccess.
  ///
  /// In en, this message translates to:
  /// **'Restored {workouts} workouts, {measurements} measurements'**
  String restoreSuccess(int workouts, int measurements);

  /// No description provided for @importFailed.
  ///
  /// In en, this message translates to:
  /// **'Import failed'**
  String get importFailed;

  /// No description provided for @restoreBackupTitle.
  ///
  /// In en, this message translates to:
  /// **'Restore backup?'**
  String get restoreBackupTitle;

  /// No description provided for @restoreBackupBody.
  ///
  /// In en, this message translates to:
  /// **'Pick a previously exported JSON backup file to restore all data.'**
  String get restoreBackupBody;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @theme.
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get theme;

  /// No description provided for @themeDark.
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get themeLight;

  /// No description provided for @themeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get themeSystem;

  /// No description provided for @amoledTitle.
  ///
  /// In en, this message translates to:
  /// **'AMOLED pure black'**
  String get amoledTitle;

  /// No description provided for @amoledSubtitle.
  ///
  /// In en, this message translates to:
  /// **'True black backgrounds in dark mode'**
  String get amoledSubtitle;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get languageSystem;

  /// No description provided for @languageEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get languageEnglish;

  /// No description provided for @languageVietnamese.
  ///
  /// In en, this message translates to:
  /// **'Tiếng Việt'**
  String get languageVietnamese;

  /// No description provided for @sectionWorkout.
  ///
  /// In en, this message translates to:
  /// **'Workout'**
  String get sectionWorkout;

  /// No description provided for @defaultRestTimer.
  ///
  /// In en, this message translates to:
  /// **'Default rest timer'**
  String get defaultRestTimer;

  /// No description provided for @weightUnit.
  ///
  /// In en, this message translates to:
  /// **'Weight unit'**
  String get weightUnit;

  /// No description provided for @feedback.
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// No description provided for @restTimerSound.
  ///
  /// In en, this message translates to:
  /// **'Rest timer sound'**
  String get restTimerSound;

  /// No description provided for @restTimerVibration.
  ///
  /// In en, this message translates to:
  /// **'Rest timer vibration'**
  String get restTimerVibration;

  /// No description provided for @profile.
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// No description provided for @yourName.
  ///
  /// In en, this message translates to:
  /// **'Your name'**
  String get yourName;

  /// No description provided for @nameHint.
  ///
  /// In en, this message translates to:
  /// **'Athlete'**
  String get nameHint;

  /// No description provided for @sectionData.
  ///
  /// In en, this message translates to:
  /// **'Data'**
  String get sectionData;

  /// No description provided for @exportBackup.
  ///
  /// In en, this message translates to:
  /// **'Export backup'**
  String get exportBackup;

  /// No description provided for @exportBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Save and share all app data'**
  String get exportBackupSubtitle;

  /// No description provided for @importBackup.
  ///
  /// In en, this message translates to:
  /// **'Import backup'**
  String get importBackup;

  /// No description provided for @importBackupSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Restore from JSON file'**
  String get importBackupSubtitle;

  /// No description provided for @restoreSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Pick a backup file to restore'**
  String get restoreSubtitle;

  /// No description provided for @appVersionLabel.
  ///
  /// In en, this message translates to:
  /// **'{appName} v{version}'**
  String appVersionLabel(String appName, String version);

  /// No description provided for @greetingMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get greetingMorning;

  /// No description provided for @greetingAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get greetingAfternoon;

  /// No description provided for @greetingEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get greetingEvening;

  /// No description provided for @greetingNight.
  ///
  /// In en, this message translates to:
  /// **'Good night'**
  String get greetingNight;

  /// No description provided for @relativeToday.
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get relativeToday;

  /// No description provided for @relativeYesterday.
  ///
  /// In en, this message translates to:
  /// **'Yesterday'**
  String get relativeYesterday;

  /// No description provided for @badgeDropSet.
  ///
  /// In en, this message translates to:
  /// **'Drop Set'**
  String get badgeDropSet;

  /// No description provided for @badgeFail.
  ///
  /// In en, this message translates to:
  /// **'Fail'**
  String get badgeFail;

  /// No description provided for @badgePr.
  ///
  /// In en, this message translates to:
  /// **'PR'**
  String get badgePr;

  /// No description provided for @restTimer.
  ///
  /// In en, this message translates to:
  /// **'Rest Timer'**
  String get restTimer;

  /// No description provided for @paused.
  ///
  /// In en, this message translates to:
  /// **'Paused'**
  String get paused;

  /// No description provided for @recoverBeforeNext.
  ///
  /// In en, this message translates to:
  /// **'Recover before next set'**
  String get recoverBeforeNext;

  /// No description provided for @ofTotal.
  ///
  /// In en, this message translates to:
  /// **'of {time}'**
  String ofTotal(String time);

  /// No description provided for @resume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get resume;

  /// No description provided for @pause.
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get pause;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @workoutProgress.
  ///
  /// In en, this message translates to:
  /// **'Workout progress'**
  String get workoutProgress;

  /// No description provided for @workoutProgressValue.
  ///
  /// In en, this message translates to:
  /// **'{completed} / {total} · {percent}%'**
  String workoutProgressValue(int completed, int total, int percent);

  /// No description provided for @loadingApp.
  ///
  /// In en, this message translates to:
  /// **'Loading {appName}…'**
  String loadingApp(String appName);

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitLbs.
  ///
  /// In en, this message translates to:
  /// **'lbs'**
  String get unitLbs;

  /// No description provided for @resumeWorkout.
  ///
  /// In en, this message translates to:
  /// **'Resume Workout'**
  String get resumeWorkout;

  /// No description provided for @discardWorkout.
  ///
  /// In en, this message translates to:
  /// **'Discard Workout'**
  String get discardWorkout;

  /// No description provided for @finishConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Finish workout?'**
  String get finishConfirmTitle;

  /// No description provided for @finishConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Save this session and view summary.'**
  String get finishConfirmBody;

  /// No description provided for @discardConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Discard workout?'**
  String get discardConfirmTitle;

  /// No description provided for @discardConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Progress for this session will be deleted.'**
  String get discardConfirmBody;

  /// No description provided for @activeSessionTitle.
  ///
  /// In en, this message translates to:
  /// **'Workout in progress'**
  String get activeSessionTitle;

  /// No description provided for @confirm.
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// No description provided for @muscleGroupA11y.
  ///
  /// In en, this message translates to:
  /// **'Muscle group: {label}'**
  String muscleGroupA11y(String label);

  /// No description provided for @restPresetA11y.
  ///
  /// In en, this message translates to:
  /// **'{seconds} second rest preset'**
  String restPresetA11y(int seconds);

  /// No description provided for @videoShareSubject.
  ///
  /// In en, this message translates to:
  /// **'{name} demo'**
  String videoShareSubject(String name);

  /// No description provided for @backupShareSubject.
  ///
  /// In en, this message translates to:
  /// **'Gym Coach Backup'**
  String get backupShareSubject;

  /// No description provided for @backupShareText.
  ///
  /// In en, this message translates to:
  /// **'Gym Coach data backup exported on {timestamp}'**
  String backupShareText(String timestamp);

  /// No description provided for @backupCancelled.
  ///
  /// In en, this message translates to:
  /// **'No file selected'**
  String get backupCancelled;

  /// No description provided for @backupUnableToRead.
  ///
  /// In en, this message translates to:
  /// **'Unable to read selected file'**
  String get backupUnableToRead;

  /// No description provided for @backupInvalidFormat.
  ///
  /// In en, this message translates to:
  /// **'Invalid backup file'**
  String get backupInvalidFormat;

  /// No description provided for @restSecondsLabel.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String restSecondsLabel(int seconds);

  /// No description provided for @dayCardA11y.
  ///
  /// In en, this message translates to:
  /// **'{dayName}, {muscleGroup}, {percent} percent complete'**
  String dayCardA11y(String dayName, String muscleGroup, int percent);

  /// No description provided for @restMiniBarA11y.
  ///
  /// In en, this message translates to:
  /// **'Rest timer {time} remaining. Tap to open'**
  String restMiniBarA11y(String time);

  /// No description provided for @forearmCm.
  ///
  /// In en, this message translates to:
  /// **'Forearm (cm)'**
  String get forearmCm;

  /// No description provided for @thighCm.
  ///
  /// In en, this message translates to:
  /// **'Thigh (cm)'**
  String get thighCm;

  /// No description provided for @calfCm.
  ///
  /// In en, this message translates to:
  /// **'Calf (cm)'**
  String get calfCm;

  /// No description provided for @shoulderCm.
  ///
  /// In en, this message translates to:
  /// **'Shoulder (cm)'**
  String get shoulderCm;

  /// No description provided for @checkForUpdates.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get checkForUpdates;

  /// No description provided for @checkForUpdatesSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Download the latest version from GitHub'**
  String get checkForUpdatesSubtitle;

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Version {version} (build {build}) is ready.'**
  String updateAvailableBody(String version, int build);

  /// No description provided for @updateNow.
  ///
  /// In en, this message translates to:
  /// **'Update now'**
  String get updateNow;

  /// No description provided for @updateLater.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get updateLater;

  /// No description provided for @updateDownloading.
  ///
  /// In en, this message translates to:
  /// **'Downloading update…'**
  String get updateDownloading;

  /// No description provided for @updateInstalling.
  ///
  /// In en, this message translates to:
  /// **'Opening installer…'**
  String get updateInstalling;

  /// No description provided for @updateUpToDate.
  ///
  /// In en, this message translates to:
  /// **'You are on the latest version'**
  String get updateUpToDate;

  /// No description provided for @updateCheckFailed.
  ///
  /// In en, this message translates to:
  /// **'Could not check for updates'**
  String get updateCheckFailed;

  /// No description provided for @updateFailed.
  ///
  /// In en, this message translates to:
  /// **'Update failed'**
  String get updateFailed;

  /// No description provided for @updateCancelled.
  ///
  /// In en, this message translates to:
  /// **'Download cancelled'**
  String get updateCancelled;

  /// No description provided for @updatePermissionDenied.
  ///
  /// In en, this message translates to:
  /// **'Install permission required for unknown sources'**
  String get updatePermissionDenied;

  /// No description provided for @updateAlreadyRunning.
  ///
  /// In en, this message translates to:
  /// **'Another update is already in progress'**
  String get updateAlreadyRunning;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
