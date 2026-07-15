import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/services/app_update_service.dart';

final appUpdateServiceProvider = Provider<AppUpdateService>(
  (ref) => AppUpdateService(),
);
