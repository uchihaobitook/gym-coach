import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:ota_update/ota_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../constants/update_config.dart';

/// Describes an available update from GitHub Releases.
class AppUpdateInfo {
  const AppUpdateInfo({
    required this.versionName,
    required this.buildNumber,
    required this.apkUrl,
    this.releaseNotes,
  });

  final String versionName;
  final int buildNumber;
  final String apkUrl;
  final String? releaseNotes;
}

/// Checks GitHub Releases and installs APK updates on Android.
class AppUpdateService {
  static const _userAgent = 'GymCoach-OTA/1.0';

  Future<PackageInfo> currentPackage() => PackageInfo.fromPlatform();

  /// Returns update info when a newer [buildNumber] exists on GitHub.
  Future<AppUpdateInfo?> checkForUpdate() async {
    final package = await currentPackage();
    final currentBuild = int.tryParse(package.buildNumber) ?? 0;

    final response = await http
        .get(
          Uri.parse(UpdateConfig.latestReleaseApi),
          headers: const {
            'Accept': 'application/vnd.github+json',
            'User-Agent': _userAgent,
          },
        )
        .timeout(const Duration(seconds: 15));

    if (response.statusCode == 404) {
      // No releases yet.
      return null;
    }
    if (response.statusCode != 200) {
      throw AppUpdateException('HTTP ${response.statusCode}');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final tag = (data['tag_name'] as String?)?.trim() ?? '';
    final remoteBuild = _parseBuildNumber(tag);
    if (remoteBuild <= currentBuild) return null;

    final apkUrl = _findApkUrl(data['assets']);
    if (apkUrl == null) {
      throw AppUpdateException('missing_apk');
    }

    return AppUpdateInfo(
      versionName: _parseVersionName(tag),
      buildNumber: remoteBuild,
      apkUrl: apkUrl,
      releaseNotes: data['body'] as String?,
    );
  }

  /// Downloads [apkUrl] and opens the Android package installer.
  Stream<OtaEvent> installUpdate(String apkUrl) {
    return OtaUpdate()
        .execute(
          apkUrl,
          destinationFilename: 'gym_coach_update.apk',
        )
        .asBroadcastStream();
  }

  int _parseBuildNumber(String tag) {
    final cleaned = tag.startsWith('v') ? tag.substring(1) : tag;
    final plus = cleaned.indexOf('+');
    if (plus != -1) {
      return int.tryParse(cleaned.substring(plus + 1)) ?? 0;
    }
    // Fallback: treat whole tag as build if numeric.
    return int.tryParse(cleaned.replaceAll('.', '')) ?? 0;
  }

  String _parseVersionName(String tag) {
    final cleaned = tag.startsWith('v') ? tag.substring(1) : tag;
    final plus = cleaned.indexOf('+');
    if (plus != -1) return cleaned.substring(0, plus);
    return cleaned;
  }

  String? _findApkUrl(dynamic assetsJson) {
    if (assetsJson is! List) return null;
    for (final item in assetsJson) {
      if (item is! Map) continue;
      final name = item['name'] as String? ?? '';
      final url = item['browser_download_url'] as String?;
      if (url != null && name.toLowerCase().endsWith('.apk')) {
        return url;
      }
    }
    return null;
  }
}

class AppUpdateException implements Exception {
  AppUpdateException(this.code);
  final String code;

  @override
  String toString() => 'AppUpdateException($code)';
}
