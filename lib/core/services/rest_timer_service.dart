import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:vibration/vibration.dart';

import '../constants/app_constants.dart';

/// Countdown rest timer with optional sound and vibration on completion.
class RestTimerService extends ChangeNotifier {
  RestTimerService({AudioPlayer? audioPlayer})
      : _audioPlayer = audioPlayer ?? AudioPlayer();

  final AudioPlayer _audioPlayer;

  Timer? _timer;
  int _remaining = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isPaused = false;
  bool _soundEnabled = true;
  bool _vibrateEnabled = true;

  int get remaining => _remaining;
  int get totalSeconds => _totalSeconds;
  bool get isRunning => _isRunning;
  bool get isPaused => _isPaused;

  double get progress =>
      _totalSeconds == 0 ? 0 : 1 - (_remaining / _totalSeconds);

  /// Starts a new countdown for [seconds].
  void start(
    int seconds, {
    bool soundEnabled = true,
    bool vibrateEnabled = true,
  }) {
    cancel();
    _totalSeconds = seconds;
    _remaining = seconds;
    _soundEnabled = soundEnabled;
    _vibrateEnabled = vibrateEnabled;
    _isRunning = true;
    _isPaused = false;
    _startTicker();
    notifyListeners();
  }

  /// Pauses the active countdown.
  void pause() {
    if (!_isRunning || _isPaused) return;
    _timer?.cancel();
    _isPaused = true;
    notifyListeners();
  }

  /// Resumes a paused countdown.
  void resume() {
    if (!_isRunning || !_isPaused) return;
    _isPaused = false;
    _startTicker();
    notifyListeners();
  }

  /// Cancels the timer and resets state.
  void cancel() {
    _timer?.cancel();
    _timer = null;
    _remaining = 0;
    _totalSeconds = 0;
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  void _tick() {
    if (_remaining <= 0) {
      _onComplete();
      return;
    }
    _remaining--;
    notifyListeners();
    if (_remaining <= 0) {
      _onComplete();
    }
  }

  Future<void> _onComplete() async {
    _timer?.cancel();
    _timer = null;
    _isRunning = false;
    _isPaused = false;
    notifyListeners();
    await _playCompletionFeedback();
  }

  Future<void> _playCompletionFeedback() async {
    if (_soundEnabled) {
      try {
        await _audioPlayer.play(AssetSource(
          AppConstants.timerSoundAsset.replaceFirst('assets/', ''),
        ));
      } catch (_) {
        // Asset or platform playback may be unavailable in tests.
      }
    }

    if (_vibrateEnabled) {
      try {
        final hasVibrator = await Vibration.hasVibrator();
        if (hasVibrator == true) {
          await Vibration.vibrate(duration: 500);
        }
      } catch (_) {
        // Vibration not supported on this platform.
      }
    }
  }

  @override
  void dispose() {
    cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
