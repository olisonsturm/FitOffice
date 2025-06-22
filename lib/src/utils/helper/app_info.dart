import 'package:package_info_plus/package_info_plus.dart';

/// Utility class to fetch application version information.
class AppInfo {

  /// Returns the short version number of the application.
  /// @returns A [String] representing the version number.
  static Future<String> getVersionNumber() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return packageInfo.version;
  }

  /// Returns the build number of the application.
  /// @returns A [String] representing the build number.
  static Future<String> getFullVersionInfo() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    return '${packageInfo.version}+${packageInfo.buildNumber}';
  }
}