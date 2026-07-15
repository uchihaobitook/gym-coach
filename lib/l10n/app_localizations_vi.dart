// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appName => 'Gym Coach';

  @override
  String get splashTagline => 'Tập thông minh. Nâng mạnh hơn.';

  @override
  String get splashLoading => 'Đang chuẩn bị giáo án…';

  @override
  String get navHome => 'Trang chủ';

  @override
  String get navWorkouts => 'Buổi tập';

  @override
  String get navProgress => 'Tiến độ';

  @override
  String get navStats => 'Thống kê';

  @override
  String get navSettings => 'Cài đặt';

  @override
  String get retry => 'Thử lại';

  @override
  String get cancel => 'Hủy';

  @override
  String get save => 'Lưu';

  @override
  String get restore => 'Khôi phục';

  @override
  String get goBack => 'Quay lại';

  @override
  String get goHome => 'Về trang chủ';

  @override
  String get loading => 'Đang tải…';

  @override
  String errorPrefix(String message) {
    return 'Lỗi: $message';
  }

  @override
  String get couldNotLoadProgram => 'Không tải được giáo án';

  @override
  String get settingsUnavailable => 'Không tải được cài đặt';

  @override
  String get currentStreak => 'Chuỗi tập hiện tại';

  @override
  String streakDays(int count) {
    return '$count ngày';
  }

  @override
  String get thisWeek => 'Tuần này';

  @override
  String weekDone(int completed, int total) {
    return '$completed / $total hoàn thành';
  }

  @override
  String get totalWorkouts => 'Tổng buổi tập';

  @override
  String get yourStatistics => 'Thống kê của bạn';

  @override
  String get workouts => 'Buổi tập';

  @override
  String get keepItUp => 'Tiếp tục phát huy!';

  @override
  String get startToday => 'Bắt đầu hôm nay';

  @override
  String get trainingHours => 'Giờ tập';

  @override
  String get hoursLogged => 'giờ đã ghi';

  @override
  String get totalVolume => 'Tổng khối lượng';

  @override
  String get allTimeLifted => 'tất cả thời gian';

  @override
  String favoriteExerciseLabel(String exercise) {
    return 'Yêu thích: $exercise';
  }

  @override
  String weekNumber(int number) {
    return 'Tuần $number';
  }

  @override
  String weekDayBadge(int week, int day) {
    return 'Tuần $week · Ngày $day';
  }

  @override
  String minutesShort(int minutes) {
    return '$minutes phút';
  }

  @override
  String exercisesCount(int count) {
    return '$count bài';
  }

  @override
  String setsCount(int count) {
    return '$count hiệp';
  }

  @override
  String get quickStart => 'Bắt đầu nhanh';

  @override
  String get trainAgain => 'Tập lại';

  @override
  String get programUnavailable => 'Không có giáo án';

  @override
  String trainingDaysCount(int count) {
    return '$count ngày tập';
  }

  @override
  String get startingWorkout => 'Đang bắt đầu buổi tập…';

  @override
  String get workoutUnavailable => 'Không mở được buổi tập';

  @override
  String get workoutDayNotFound => 'Không tìm thấy ngày tập';

  @override
  String get unknownError => 'Lỗi không xác định';

  @override
  String weekElapsed(int week, String elapsed) {
    return 'Tuần $week · $elapsed';
  }

  @override
  String get finish => 'Kết thúc';

  @override
  String get finishWorkout => 'Kết thúc buổi tập';

  @override
  String get noVideoAvailable => 'Bài tập này chưa có video';

  @override
  String openingVideo(String name) {
    return 'Đang mở video: $name';
  }

  @override
  String setsProgress(int completed, int total) {
    return '$completed / $total hiệp';
  }

  @override
  String setNumber(int number) {
    return 'Hiệp $number';
  }

  @override
  String get watchDemo => 'Xem demo';

  @override
  String targetSetsReps(int sets, String reps) {
    return 'Mục tiêu: $sets × $reps';
  }

  @override
  String previousBest(String weight) {
    return 'Mốc trước: $weight';
  }

  @override
  String get notes => 'Ghi chú';

  @override
  String get notesHint => 'Kỹ thuật, cảm giác khi tập…';

  @override
  String get reps => 'Số lần';

  @override
  String get weight => 'Mức tạ';

  @override
  String decreaseValue(String value) {
    return 'Giảm $value';
  }

  @override
  String increaseValue(String value) {
    return 'Tăng $value';
  }

  @override
  String get summary => 'Tổng kết';

  @override
  String get loadingSummary => 'Đang tải tổng kết…';

  @override
  String get couldNotLoadSummary => 'Không tải được tổng kết';

  @override
  String get workoutNotFound => 'Không tìm thấy buổi tập';

  @override
  String get workoutNotFoundSubtitle => 'Buổi tập này có thể đã bị xóa.';

  @override
  String get workoutComplete => 'Hoàn thành buổi tập';

  @override
  String get greatWork => 'Tuyệt vời!';

  @override
  String get duration => 'Thời gian';

  @override
  String get exercises => 'Bài tập';

  @override
  String get prs => 'PR';

  @override
  String get calories => 'Calo';

  @override
  String get sessionNotes => 'Ghi chú buổi tập';

  @override
  String get sessionNotesHint =>
      'Cảm giác thế nào? Có PR hoặc cần chỉnh gì không?';

  @override
  String get saveAndGoHome => 'Lưu & Về trang chủ';

  @override
  String get calendar => 'Lịch';

  @override
  String get addMeasurement => 'Thêm số đo';

  @override
  String get couldNotLoadMeasurements => 'Không tải được số đo';

  @override
  String get bodyMeasurements => 'Số đo cơ thể';

  @override
  String get noMeasurementsYet => 'Chưa có số đo';

  @override
  String get noMeasurementsSubtitle =>
      'Theo dõi cân nặng và số đo theo thời gian.';

  @override
  String get addFirstEntry => 'Thêm lần đầu';

  @override
  String get strengthProgress => 'Tiến độ sức mạnh';

  @override
  String get strengthUnavailable => 'Không có dữ liệu sức mạnh';

  @override
  String get noStrengthHistory => 'Chưa có lịch sử sức mạnh';

  @override
  String get noStrengthSubtitle => 'Hoàn thành buổi tập để theo dõi mức tạ.';

  @override
  String sessionsCount(int count) {
    return '$count buổi';
  }

  @override
  String get needTwoEntries => 'Cần ít nhất 2 lần đo để xem biểu đồ';

  @override
  String needOneMoreEntry(String field) {
    return 'Thêm một lần nữa để vẽ biểu đồ $field';
  }

  @override
  String get addMeasurementTitle => 'Thêm số đo';

  @override
  String get date => 'Ngày';

  @override
  String get weightKg => 'Cân nặng (kg)';

  @override
  String get chestCm => 'Ngực (cm)';

  @override
  String get waistCm => 'Eo (cm)';

  @override
  String get armCm => 'Tay (cm)';

  @override
  String get enterAtLeastOneMeasurement => 'Nhập ít nhất một số đo';

  @override
  String get measureBodyWeight => 'Cân nặng';

  @override
  String get measureChest => 'Ngực';

  @override
  String get measureWaist => 'Eo';

  @override
  String get measureArm => 'Tay';

  @override
  String get measureForearm => 'Cẳng tay';

  @override
  String get measureThigh => 'Đùi';

  @override
  String get measureCalf => 'Bắp chân';

  @override
  String get measureShoulder => 'Vai';

  @override
  String get strengthDetail => 'Chi tiết sức mạnh';

  @override
  String get couldNotLoadHistory => 'Không tải được lịch sử';

  @override
  String get noHistoryYet => 'Chưa có lịch sử';

  @override
  String get noHistorySubtitle =>
      'Hoàn thành các hiệp của bài này để xem biểu đồ.';

  @override
  String get bestWeight => 'Mức tạ tốt nhất';

  @override
  String get bestReps => 'Rep tốt nhất';

  @override
  String get bestVolume => 'Khối lượng tốt nhất';

  @override
  String get weightOverTime => 'Mức tạ theo thời gian';

  @override
  String get history => 'Lịch sử';

  @override
  String repsCount(int count) {
    return '$count rep';
  }

  @override
  String get statistics => 'Thống kê';

  @override
  String get favoriteExercise => 'Bài tập yêu thích';

  @override
  String get mostLogged => 'tập nhiều nhất';

  @override
  String get mostTrainedMuscle => 'Nhóm cơ tập nhiều nhất';

  @override
  String get longestStreak => 'Chuỗi dài nhất';

  @override
  String get weeklyTrend => 'Xu hướng theo tuần';

  @override
  String get volume => 'Khối lượng';

  @override
  String get completeWorkoutsForTrends => 'Hoàn thành buổi tập để xem xu hướng';

  @override
  String lifetimeVolume(String volume) {
    return 'Tổng khối lượng: $volume';
  }

  @override
  String get trainingCalendar => 'Lịch tập luyện';

  @override
  String longestStreakLabel(int count) {
    return 'Dài nhất: $count ngày';
  }

  @override
  String get legendCompleted => 'Đã tập';

  @override
  String get legendMissed => 'Bỏ lỡ';

  @override
  String get legendToday => 'Hôm nay';

  @override
  String get restDayElsewhere => 'Ngày nghỉ (đã ghi ở chỗ khác)';

  @override
  String get noWorkoutThisDay => 'Ngày này chưa ghi buổi tập';

  @override
  String get settings => 'Cài đặt';

  @override
  String get backupExported => 'Xuất sao lưu thành công';

  @override
  String get exportFailed => 'Xuất sao lưu thất bại';

  @override
  String restoreSuccess(int workouts, int measurements) {
    return 'Đã khôi phục $workouts buổi tập, $measurements số đo';
  }

  @override
  String get importFailed => 'Nhập sao lưu thất bại';

  @override
  String get restoreBackupTitle => 'Khôi phục sao lưu?';

  @override
  String get restoreBackupBody =>
      'Chọn file JSON đã xuất trước đó để khôi phục toàn bộ dữ liệu.';

  @override
  String get appearance => 'Giao diện';

  @override
  String get theme => 'Chủ đề';

  @override
  String get themeDark => 'Tối';

  @override
  String get themeLight => 'Sáng';

  @override
  String get themeSystem => 'Theo hệ thống';

  @override
  String get amoledTitle => 'AMOLED đen thuần';

  @override
  String get amoledSubtitle => 'Nền đen tuyệt đối ở chế độ tối';

  @override
  String get language => 'Ngôn ngữ';

  @override
  String get languageSystem => 'Theo hệ thống';

  @override
  String get languageEnglish => 'English';

  @override
  String get languageVietnamese => 'Tiếng Việt';

  @override
  String get sectionWorkout => 'Tập luyện';

  @override
  String get defaultRestTimer => 'Thời gian nghỉ mặc định';

  @override
  String get weightUnit => 'Đơn vị cân nặng';

  @override
  String get feedback => 'Phản hồi';

  @override
  String get restTimerSound => 'Âm thanh đếm giờ nghỉ';

  @override
  String get restTimerVibration => 'Rung khi hết giờ nghỉ';

  @override
  String get profile => 'Hồ sơ';

  @override
  String get yourName => 'Tên của bạn';

  @override
  String get nameHint => 'VĐV';

  @override
  String get sectionData => 'Dữ liệu';

  @override
  String get exportBackup => 'Xuất sao lưu';

  @override
  String get exportBackupSubtitle => 'Lưu và chia sẻ dữ liệu hồ sơ hiện tại';

  @override
  String get importBackup => 'Nhập sao lưu';

  @override
  String get importBackupSubtitle => 'Khôi phục vào hồ sơ đang dùng';

  @override
  String get restoreSubtitle => 'Chọn file sao lưu để khôi phục';

  @override
  String appVersionLabel(String appName, String version) {
    return '$appName v$version';
  }

  @override
  String get greetingMorning => 'Chào buổi sáng';

  @override
  String get greetingAfternoon => 'Chào buổi chiều';

  @override
  String get greetingEvening => 'Chào buổi tối';

  @override
  String get greetingNight => 'Chúc ngủ ngon';

  @override
  String get relativeToday => 'Hôm nay';

  @override
  String get relativeYesterday => 'Hôm qua';

  @override
  String get badgeDropSet => 'Drop set';

  @override
  String get badgeFail => 'Đến thất bại';

  @override
  String get badgePr => 'PR';

  @override
  String get restTimer => 'Đếm giờ nghỉ';

  @override
  String get paused => 'Tạm dừng';

  @override
  String get recoverBeforeNext => 'Hồi phục trước hiệp tiếp theo';

  @override
  String ofTotal(String time) {
    return '/ $time';
  }

  @override
  String get resume => 'Tiếp tục';

  @override
  String get pause => 'Tạm dừng';

  @override
  String get skip => 'Bỏ qua';

  @override
  String get workoutProgress => 'Tiến độ buổi tập';

  @override
  String workoutProgressValue(int completed, int total, int percent) {
    return '$completed / $total · $percent%';
  }

  @override
  String loadingApp(String appName) {
    return 'Đang tải $appName…';
  }

  @override
  String get unitKg => 'kg';

  @override
  String get unitLbs => 'lbs';

  @override
  String get resumeWorkout => 'Tiếp tục tập';

  @override
  String get discardWorkout => 'Hủy buổi tập';

  @override
  String get finishConfirmTitle => 'Kết thúc buổi tập?';

  @override
  String get finishConfirmBody => 'Lưu buổi tập và xem tổng kết.';

  @override
  String get discardConfirmTitle => 'Hủy buổi tập?';

  @override
  String get discardConfirmBody => 'Tiến độ buổi tập này sẽ bị xóa.';

  @override
  String get activeSessionTitle => 'Đang tập';

  @override
  String get confirm => 'Xác nhận';

  @override
  String muscleGroupA11y(String label) {
    return 'Nhóm cơ: $label';
  }

  @override
  String restPresetA11y(int seconds) {
    return 'Nghỉ $seconds giây';
  }

  @override
  String videoShareSubject(String name) {
    return 'Demo: $name';
  }

  @override
  String get backupShareSubject => 'Sao lưu Gym Coach';

  @override
  String backupShareText(String timestamp) {
    return 'Dữ liệu Gym Coach xuất lúc $timestamp';
  }

  @override
  String get backupCancelled => 'Đã hủy chọn file';

  @override
  String get backupUnableToRead => 'Không đọc được file đã chọn';

  @override
  String get backupInvalidFormat => 'File sao lưu không hợp lệ';

  @override
  String restSecondsLabel(int seconds) {
    return '$seconds giây';
  }

  @override
  String dayCardA11y(String dayName, String muscleGroup, int percent) {
    return '$dayName, $muscleGroup, hoàn thành $percent%';
  }

  @override
  String restMiniBarA11y(String time) {
    return 'Đếm giờ nghỉ còn $time. Chạm để mở';
  }

  @override
  String get forearmCm => 'Cẳng tay (cm)';

  @override
  String get thighCm => 'Đùi (cm)';

  @override
  String get calfCm => 'Bắp chân (cm)';

  @override
  String get shoulderCm => 'Vai (cm)';

  @override
  String get checkForUpdates => 'Kiểm tra cập nhật';

  @override
  String get checkForUpdatesSubtitle => 'Tải phiên bản mới từ GitHub';

  @override
  String get updateAvailableTitle => 'Có phiên bản mới';

  @override
  String updateAvailableBody(String version, int build) {
    return 'Phiên bản $version (bản $build) đã sẵn sàng.';
  }

  @override
  String get updateNow => 'Cập nhật ngay';

  @override
  String get updateLater => 'Để sau';

  @override
  String get updateDownloading => 'Đang tải bản cập nhật…';

  @override
  String get updateInstalling => 'Đang mở trình cài đặt…';

  @override
  String get updateUpToDate => 'Bạn đang dùng phiên bản mới nhất';

  @override
  String get updateCheckFailed => 'Không kiểm tra được cập nhật';

  @override
  String get updateFailed => 'Cập nhật thất bại';

  @override
  String get updateCancelled => 'Đã hủy tải';

  @override
  String get updatePermissionDenied =>
      'Cần quyền cài ứng dụng từ nguồn không xác định';

  @override
  String get updateAlreadyRunning => 'Đang có bản cập nhật khác đang chạy';

  @override
  String get profilesTitle => 'Hồ sơ';

  @override
  String get profilesSubtitle => 'Mỗi người một dữ liệu tập luyện riêng';

  @override
  String get currentProfile => 'Hồ sơ hiện tại';

  @override
  String get switchProfile => 'Chuyển hồ sơ';

  @override
  String get addProfile => 'Thêm hồ sơ';

  @override
  String get createProfile => 'Tạo hồ sơ';

  @override
  String get editProfile => 'Sửa hồ sơ';

  @override
  String get renameProfile => 'Đổi tên';

  @override
  String get deleteProfile => 'Xóa hồ sơ';

  @override
  String get deleteProfileTitle => 'Xóa hồ sơ?';

  @override
  String deleteProfileBody(String name) {
    return 'Toàn bộ buổi tập, số đo và tiến độ của \"$name\" sẽ bị xóa. Không thể hoàn tác.';
  }

  @override
  String get cannotDeleteLastProfile => 'Phải giữ ít nhất một hồ sơ';

  @override
  String get profileNameHint => 'Ví dụ: Anh A, Chị B';

  @override
  String get profileCreated => 'Đã tạo hồ sơ';

  @override
  String profileSwitched(String name) {
    return 'Đã chuyển sang $name';
  }

  @override
  String get profileDeleted => 'Đã xóa hồ sơ';

  @override
  String get switchWhileWorkoutTitle => 'Đang có buổi tập?';

  @override
  String get switchWhileWorkoutBody =>
      'Buổi tập đang mở sẽ được giữ trong hồ sơ hiện tại. Bạn vẫn muốn chuyển?';

  @override
  String get activeBadge => 'Đang dùng';

  @override
  String get selectProfile => 'Chọn hồ sơ';
}
