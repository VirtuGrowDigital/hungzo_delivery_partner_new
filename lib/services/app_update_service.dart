import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:upgrader/upgrader.dart';

class AppUpdateDecision {
  const AppUpdateDecision({
    required this.currentVersion,
    required this.latestVersion,
    required this.minimumSupportedVersion,
    required this.title,
    required this.message,
    required this.releaseNotes,
    required this.storeUrl,
    required this.isMandatory,
  });

  final String currentVersion;
  final String latestVersion;
  final String minimumSupportedVersion;
  final String title;
  final String message;
  final List<String> releaseNotes;
  final String storeUrl;
  final bool isMandatory;

  bool get shouldPrompt => latestVersion.isNotEmpty && storeUrl.isNotEmpty;
}

class AppUpdateService {
  AppUpdateService._();

  static const String _dismissedVersionKey =
      'dismissed_optional_driver_app_update';
  static const String _playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.hungzoDelivery.app';
  static final AppUpdateService instance = AppUpdateService._();

  Future<AppUpdateDecision?> getUpdateDecision() async {
    try {
      final upgrader = Upgrader(countryCode: 'IN', debugLogging: kDebugMode);

      final initialized = await upgrader.initialize();
      if (!initialized) {
        return null;
      }

      final currentVersion =
          upgrader.currentInstalledVersion?.trim() ??
          (await PackageInfo.fromPlatform()).version.trim();
      final latestVersion = upgrader.currentAppStoreVersion?.trim() ?? '';
      final minimumSupportedVersion = upgrader.minAppVersion?.trim() ?? '';
      final storeUrl =
          upgrader.currentAppStoreListingURL?.trim() ?? _fallbackStoreUrl();
      final isMandatory = upgrader.blocked() || upgrader.belowMinAppVersion();
      final isUpdateAvailable = upgrader.isUpdateAvailable();

      if (!isMandatory && !isUpdateAvailable) {
        return null;
      }

      final decision = AppUpdateDecision(
        currentVersion: currentVersion,
        latestVersion: latestVersion,
        minimumSupportedVersion: minimumSupportedVersion,
        title: isMandatory ? 'Update required' : 'Update available',
        message: isMandatory
            ? 'Please update Hungzo Delivery Partner to continue. This version is no longer supported.'
            : 'A newer Hungzo Delivery Partner version is available with improvements and fixes.',
        releaseNotes: _extractReleaseNotes(upgrader.releaseNotes),
        storeUrl: storeUrl,
        isMandatory: isMandatory,
      );

      if (decision.isMandatory) {
        return decision;
      }

      final prefs = await SharedPreferences.getInstance();
      final dismissedVersion = prefs.getString(_dismissedVersionKey) ?? '';
      if (dismissedVersion == decision.latestVersion) {
        return null;
      }

      return decision.shouldPrompt ? decision : null;
    } catch (error) {
      debugPrint('Driver app update check failed: $error');
      return null;
    }
  }

  Future<void> markOptionalUpdateDismissed(String version) async {
    if (version.trim().isEmpty) {
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_dismissedVersionKey, version.trim());
  }

  List<String> _extractReleaseNotes(dynamic value) {
    if (value is String) {
      return value
          .split(RegExp(r'[\n\r]+'))
          .map((entry) => entry.replaceFirst(RegExp(r'^[•\-\s]+'), '').trim())
          .where((entry) => entry.isNotEmpty)
          .take(8)
          .toList();
    }

    if (value is! List) {
      return const [];
    }

    return value
        .map((entry) => entry?.toString().trim() ?? '')
        .where((entry) => entry.isNotEmpty)
        .take(8)
        .toList();
  }

  String _fallbackStoreUrl() {
    if (kIsWeb) {
      return _playStoreUrl;
    }

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return '';
    }

    return _playStoreUrl;
  }
}
