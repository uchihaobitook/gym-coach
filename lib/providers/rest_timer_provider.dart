import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/rest_timer_service.dart';

final restTimerServiceProvider = Provider<RestTimerService>((ref) {
  final service = RestTimerService();
  ref.onDispose(service.dispose);
  return service;
});
