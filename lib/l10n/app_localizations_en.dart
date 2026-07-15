// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Gym Coach';

  @override
  String get splashTagline => 'Train smarter. Lift stronger.';

  @override
  String get splashLoading => 'Preparing your program…';

  @override
  String get navHome => 'Home';

  @override
  String get navWorkouts => 'Workouts';

  @override
  String get navProgress => 'Progress';

  @override
  String get navStats => 'Stats';

  @override
  String get navSettings => 'Settings';

  @override
  String get retry => 'Retry';

  @override
  String get cancel => 'Cancel';

  @override
  String get save => 'Save';

  @override
  String get restore => 'Restore';

  @override
  String get goBack => 'Go back';

  @override
  String get goHome => 'Go home';

  @override
  String get loading => 'Loading…';

  @override
  String errorPrefix(String message) {
    return 'Error: $message';
  }

  @override
  String get couldNotLoadProgram => 'Could not load program';

  @override
  String get settingsUnavailable => 'Settings unavailable';

  @override
  String get currentStreak => 'Current streak';

  @override
  String streakDays(int count) {
    return '$count days';
  }

  @override
  String get thisWeek => 'This week';

  @override
  String weekDone(int completed, int total) {
    return '$completed / $total done';
  }

  @override
  String get totalWorkouts => 'Total workouts';

  @override
  String get yourStatistics => 'Your Statistics';

  @override
  String get workouts => 'Workouts';

  @override
  String get keepItUp => 'Keep it up!';

  @override
  String get startToday => 'Start today';

  @override
  String get trainingHours => 'Training hours';

  @override
  String get hoursLogged => 'hours logged';

  @override
  String get totalVolume => 'Total volume';

  @override
  String get allTimeLifted => 'all time lifted';

  @override
  String favoriteExerciseLabel(String exercise) {
    return 'Favorite: $exercise';
  }

  @override
  String weekNumber(int number) {
    return 'Week $number';
  }

  @override
  String weekDayBadge(int week, int day) {
    return 'Week $week · Day $day';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes min';
  }

  @override
  String exercisesCount(int count) {
    return '$count exercises';
  }

  @override
  String setsCount(int count) {
    return '$count sets';
  }

  @override
  String get quickStart => 'Quick Start';

  @override
  String get trainAgain => 'Train Again';

  @override
  String get programUnavailable => 'Program unavailable';

  @override
  String trainingDaysCount(int count) {
    return '$count training days';
  }

  @override
  String get startingWorkout => 'Starting workout…';

  @override
  String get workoutUnavailable => 'Workout unavailable';

  @override
  String get workoutDayNotFound => 'Workout day not found';

  @override
  String get unknownError => 'Unknown error';

  @override
  String weekElapsed(int week, String elapsed) {
    return 'Week $week · $elapsed';
  }

  @override
  String get finish => 'Finish';

  @override
  String get finishWorkout => 'Finish Workout';

  @override
  String get noVideoAvailable => 'No video available for this exercise';

  @override
  String openingVideo(String name) {
    return 'Opening video: $name';
  }

  @override
  String setsProgress(int completed, int total) {
    return '$completed / $total sets';
  }

  @override
  String setNumber(int number) {
    return 'Set $number';
  }

  @override
  String get watchDemo => 'Watch demo';

  @override
  String targetSetsReps(int sets, String reps) {
    return 'Target: $sets × $reps';
  }

  @override
  String previousBest(String weight) {
    return 'Previous best: $weight';
  }

  @override
  String get notes => 'Notes';

  @override
  String get notesHint => 'Form cues, how it felt…';

  @override
  String get reps => 'Reps';

  @override
  String get weight => 'Weight';

  @override
  String decreaseValue(String value) {
    return 'Decrease $value';
  }

  @override
  String increaseValue(String value) {
    return 'Increase $value';
  }

  @override
  String get summary => 'Summary';

  @override
  String get loadingSummary => 'Loading summary…';

  @override
  String get couldNotLoadSummary => 'Could not load summary';

  @override
  String get workoutNotFound => 'Workout not found';

  @override
  String get workoutNotFoundSubtitle => 'This session may have been removed.';

  @override
  String get workoutComplete => 'Workout Complete';

  @override
  String get greatWork => 'Great work!';

  @override
  String get duration => 'Duration';

  @override
  String get exercises => 'Exercises';

  @override
  String get prs => 'PRs';

  @override
  String get calories => 'Calories';

  @override
  String get sessionNotes => 'Session notes';

  @override
  String get sessionNotesHint => 'How did it feel? Any PRs or adjustments?';

  @override
  String get saveAndGoHome => 'Save & Go Home';

  @override
  String get calendar => 'Calendar';

  @override
  String get addMeasurement => 'Add measurement';

  @override
  String get couldNotLoadMeasurements => 'Could not load measurements';

  @override
  String get bodyMeasurements => 'Body Measurements';

  @override
  String get noMeasurementsYet => 'No measurements yet';

  @override
  String get noMeasurementsSubtitle =>
      'Track weight and body metrics over time.';

  @override
  String get addFirstEntry => 'Add first entry';

  @override
  String get strengthProgress => 'Strength Progress';

  @override
  String get strengthUnavailable => 'Strength data unavailable';

  @override
  String get noStrengthHistory => 'No strength history';

  @override
  String get noStrengthSubtitle => 'Complete workouts to track lifts.';

  @override
  String sessionsCount(int count) {
    return '$count sessions';
  }

  @override
  String get needTwoEntries => 'Add at least 2 entries to see a trend';

  @override
  String needOneMoreEntry(String field) {
    return 'Add one more entry to chart $field';
  }

  @override
  String get addMeasurementTitle => 'Add Measurement';

  @override
  String get date => 'Date';

  @override
  String get weightKg => 'Weight (kg)';

  @override
  String get chestCm => 'Chest (cm)';

  @override
  String get waistCm => 'Waist (cm)';

  @override
  String get armCm => 'Arm (cm)';

  @override
  String get enterAtLeastOneMeasurement => 'Enter at least one measurement';

  @override
  String get measureBodyWeight => 'Body Weight';

  @override
  String get measureChest => 'Chest';

  @override
  String get measureWaist => 'Waist';

  @override
  String get measureArm => 'Arm';

  @override
  String get measureForearm => 'Forearm';

  @override
  String get measureThigh => 'Thigh';

  @override
  String get measureCalf => 'Calf';

  @override
  String get measureShoulder => 'Shoulder';

  @override
  String get strengthDetail => 'Strength Detail';

  @override
  String get couldNotLoadHistory => 'Could not load history';

  @override
  String get noHistoryYet => 'No history yet';

  @override
  String get noHistorySubtitle =>
      'Complete sets for this exercise to build a chart.';

  @override
  String get bestWeight => 'Best weight';

  @override
  String get bestReps => 'Best reps';

  @override
  String get bestVolume => 'Best volume';

  @override
  String get weightOverTime => 'Weight over time';

  @override
  String get history => 'History';

  @override
  String repsCount(int count) {
    return '$count reps';
  }

  @override
  String get statistics => 'Statistics';

  @override
  String get favoriteExercise => 'Favorite exercise';

  @override
  String get mostLogged => 'most logged';

  @override
  String get mostTrainedMuscle => 'Most trained muscle';

  @override
  String get longestStreak => 'Longest streak';

  @override
  String get weeklyTrend => 'Weekly trend';

  @override
  String get volume => 'Volume';

  @override
  String get completeWorkoutsForTrends => 'Complete workouts to see trends';

  @override
  String lifetimeVolume(String volume) {
    return 'Lifetime volume: $volume';
  }

  @override
  String get trainingCalendar => 'Training Calendar';

  @override
  String longestStreakLabel(int count) {
    return 'Longest: $count days';
  }

  @override
  String get legendCompleted => 'Completed';

  @override
  String get legendMissed => 'Missed';

  @override
  String get legendToday => 'Today';

  @override
  String get restDayElsewhere => 'Rest day logged elsewhere';

  @override
  String get noWorkoutThisDay => 'No workout logged this day';

  @override
  String get settings => 'Settings';

  @override
  String get backupExported => 'Backup exported successfully';

  @override
  String get exportFailed => 'Export failed';

  @override
  String restoreSuccess(int workouts, int measurements) {
    return 'Restored $workouts workouts, $measurements measurements';
  }

  @override
  String get importFailed => 'Import failed';

  @override
  String get restoreBackupTitle => 'Restore backup?';

  @override
  String get restoreBackupBody =>
      'Pick a previously exported JSON backup file to restore all data.';

  @override
  String get appearance => 'Appearance';

  @override
  String get theme => 'Theme';

  @override
  String get themeDark => 'Dark';

  @override
  String get themeLight => 'Light';

  @override
  String get themeSystem => 'System';

  @override
  String get amoledTitle => 'AMOLED pure black';

  @override
  String get amoledSubtitle => 'True black backgrounds in dark mode';

  @override
  String get language => 'Language';

  @override
  String get languageSystem => 'System';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get sectionWorkout => 'Workout';

  @override
  String get defaultRestTimer => 'Default rest timer';

  @override
  String get weightUnit => 'Weight unit';

  @override
  String get feedback => 'Feedback';

  @override
  String get restTimerSound => 'Rest timer sound';

  @override
  String get restTimerVibration => 'Rest timer vibration';

  @override
  String get profile => 'Profile';

  @override
  String get yourName => 'Your name';

  @override
  String get nameHint => 'Athlete';

  @override
  String get sectionData => 'Data';

  @override
  String get exportBackup => 'Export backup';

  @override
  String get exportBackupSubtitle => 'Save and share the current profile';

  @override
  String get importBackup => 'Import backup';

  @override
  String get importBackupSubtitle => 'Restore into the active profile';

  @override
  String get restoreSubtitle => 'Pick a backup file to restore';

  @override
  String appVersionLabel(String appName, String version) {
    return '$appName v$version';
  }

  @override
  String get greetingMorning => 'Good morning';

  @override
  String get greetingAfternoon => 'Good afternoon';

  @override
  String get greetingEvening => 'Good evening';

  @override
  String get greetingNight => 'Good night';

  @override
  String get relativeToday => 'Today';

  @override
  String get relativeYesterday => 'Yesterday';

  @override
  String get badgeDropSet => 'Drop Set';

  @override
  String get badgeFail => 'Fail';

  @override
  String get badgePr => 'PR';

  @override
  String get restTimer => 'Rest Timer';

  @override
  String get paused => 'Paused';

  @override
  String get recoverBeforeNext => 'Recover before next set';

  @override
  String ofTotal(String time) {
    return 'of $time';
  }

  @override
  String get resume => 'Resume';

  @override
  String get pause => 'Pause';

  @override
  String get skip => 'Skip';

  @override
  String get workoutProgress => 'Workout progress';

  @override
  String workoutProgressValue(int completed, int total, int percent) {
    return '$completed / $total · $percent%';
  }

  @override
  String loadingApp(String appName) {
    return 'Loading $appName…';
  }

  @override
  String get unitKg => 'kg';

  @override
  String get unitLbs => 'lbs';

  @override
  String get resumeWorkout => 'Resume Workout';

  @override
  String get discardWorkout => 'Discard Workout';

  @override
  String get finishConfirmTitle => 'Finish workout?';

  @override
  String get finishConfirmBody => 'Save this session and view summary.';

  @override
  String get discardConfirmTitle => 'Discard workout?';

  @override
  String get discardConfirmBody => 'Progress for this session will be deleted.';

  @override
  String get activeSessionTitle => 'Workout in progress';

  @override
  String get confirm => 'Confirm';

  @override
  String muscleGroupA11y(String label) {
    return 'Muscle group: $label';
  }

  @override
  String restPresetA11y(int seconds) {
    return '$seconds second rest preset';
  }

  @override
  String videoShareSubject(String name) {
    return '$name demo';
  }

  @override
  String get backupShareSubject => 'Gym Coach Backup';

  @override
  String backupShareText(String timestamp) {
    return 'Gym Coach data backup exported on $timestamp';
  }

  @override
  String get backupCancelled => 'No file selected';

  @override
  String get backupUnableToRead => 'Unable to read selected file';

  @override
  String get backupInvalidFormat => 'Invalid backup file';

  @override
  String restSecondsLabel(int seconds) {
    return '${seconds}s';
  }

  @override
  String dayCardA11y(String dayName, String muscleGroup, int percent) {
    return '$dayName, $muscleGroup, $percent percent complete';
  }

  @override
  String restMiniBarA11y(String time) {
    return 'Rest timer $time remaining. Tap to open';
  }

  @override
  String get forearmCm => 'Forearm (cm)';

  @override
  String get thighCm => 'Thigh (cm)';

  @override
  String get calfCm => 'Calf (cm)';

  @override
  String get shoulderCm => 'Shoulder (cm)';

  @override
  String get checkForUpdates => 'Check for updates';

  @override
  String get checkForUpdatesSubtitle =>
      'Download the latest version from GitHub';

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String version, int build) {
    return 'Version $version (build $build) is ready.';
  }

  @override
  String get updateNow => 'Update now';

  @override
  String get updateLater => 'Later';

  @override
  String get updateDownloading => 'Downloading update…';

  @override
  String get updateInstalling => 'Opening installer…';

  @override
  String get updateUpToDate => 'You are on the latest version';

  @override
  String get updateCheckFailed => 'Could not check for updates';

  @override
  String get updateFailed => 'Update failed';

  @override
  String get updateCancelled => 'Download cancelled';

  @override
  String get updatePermissionDenied =>
      'Install permission required for unknown sources';

  @override
  String get updateAlreadyRunning => 'Another update is already in progress';

  @override
  String get profilesTitle => 'Profiles';

  @override
  String get profilesSubtitle => 'Separate training data for each person';

  @override
  String get currentProfile => 'Current profile';

  @override
  String get switchProfile => 'Switch profile';

  @override
  String get addProfile => 'Add profile';

  @override
  String get createProfile => 'Create profile';

  @override
  String get editProfile => 'Edit profile';

  @override
  String get renameProfile => 'Rename';

  @override
  String get deleteProfile => 'Delete profile';

  @override
  String get deleteProfileTitle => 'Delete profile?';

  @override
  String deleteProfileBody(String name) {
    return 'All workouts, measurements, and progress for \"$name\" will be deleted. This cannot be undone.';
  }

  @override
  String get cannotDeleteLastProfile => 'Keep at least one profile';

  @override
  String get profileNameHint => 'e.g. Alex, Sam';

  @override
  String get profileCreated => 'Profile created';

  @override
  String profileSwitched(String name) {
    return 'Switched to $name';
  }

  @override
  String get profileDeleted => 'Profile deleted';

  @override
  String get switchWhileWorkoutTitle => 'Workout in progress?';

  @override
  String get switchWhileWorkoutBody =>
      'The open workout will stay with the current profile. Switch anyway?';

  @override
  String get activeBadge => 'Active';

  @override
  String get selectProfile => 'Select profile';
}
