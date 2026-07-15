/// GitHub Releases OTA configuration.
abstract final class UpdateConfig {
  static const String githubOwner = 'uchihaobitook';
  static const String githubRepo = 'gym-coach';

  static String get latestReleaseApi =>
      'https://api.github.com/repos/$githubOwner/$githubRepo/releases/latest';
}
