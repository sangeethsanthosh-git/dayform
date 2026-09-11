import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/app_constants.dart';

class ReleaseAsset {
  final String name;
  final int size;
  final String downloadUrl;
  final String contentType;

  const ReleaseAsset({
    required this.name,
    required this.size,
    required this.downloadUrl,
    required this.contentType,
  });

  factory ReleaseAsset.fromJson(Map<String, dynamic> json) {
    return ReleaseAsset(
      name: json['name'] as String? ?? '',
      size: json['size'] as int? ?? 0,
      downloadUrl: json['browser_download_url'] as String? ?? '',
      contentType: json['content_type'] as String? ?? '',
    );
  }

  String get formattedSize {
    if (size <= 0) return '';
    final mb = size / (1024 * 1024);
    return '${mb.toStringAsFixed(1)} MB';
  }
}

class AppUpdateInfo {
  final String currentVersion;
  final String latestVersion;
  final String releaseName;
  final String releaseNotes;
  final String releaseUrl;
  final String publishedAt;
  final List<ReleaseAsset> apkAssets;
  final bool isUpdateAvailable;

  const AppUpdateInfo({
    required this.currentVersion,
    required this.latestVersion,
    required this.releaseName,
    required this.releaseNotes,
    required this.releaseUrl,
    required this.publishedAt,
    required this.apkAssets,
    required this.isUpdateAvailable,
  });

  /// Get the best APK asset for user's device.
  /// Prefers arm64-v8a for modern phones, falls back to universal, or first available APK.
  ReleaseAsset? get recommendedAsset {
    if (apkAssets.isEmpty) return null;

    final arm64 = apkAssets
        .where((a) => a.name.toLowerCase().contains('arm64-v8a'))
        .firstOrNull;
    if (arm64 != null) return arm64;

    final universal = apkAssets
        .where((a) =>
            a.name.toLowerCase().contains('universal') ||
            a.name.toLowerCase().contains('release'))
        .firstOrNull;
    if (universal != null) return universal;

    return apkAssets.first;
  }
}

class UpdateService {
  UpdateService._();
  static final UpdateService instance = UpdateService._();

  static const String _dismissedTagKey = 'dayform_dismissed_update_tag';

  /// Compare two semantic versions (e.g. '1.0.0' and 'v1.0.1')
  /// Returns:
  /// > 0 if remote is strictly newer than current
  /// = 0 if same
  /// < 0 if remote is older
  static int compareVersions(String current, String remote) {
    String clean(String v) {
      return v
          .trim()
          .toLowerCase()
          .replaceAll(RegExp(r'^v'), '')
          .split('+')
          .first;
    }

    final curParts =
        clean(current).split('.').map((e) => int.tryParse(e) ?? 0).toList();
    final remParts =
        clean(remote).split('.').map((e) => int.tryParse(e) ?? 0).toList();

    final maxLen = curParts.length > remParts.length
        ? curParts.length
        : remParts.length;
    while (curParts.length < maxLen) {
      curParts.add(0);
    }
    while (remParts.length < maxLen) {
      remParts.add(0);
    }

    for (int i = 0; i < maxLen; i++) {
      if (remParts[i] > curParts[i]) return 1;
      if (remParts[i] < curParts[i]) return -1;
    }
    return 0;
  }

  /// Check GitHub for the latest release
  Future<AppUpdateInfo?> checkForUpdate({
    String currentVersion = AppConstants.appVersion,
  }) async {
    try {
      final client = HttpClient();
      client.connectionTimeout = const Duration(seconds: 10);
      final request =
          await client.getUrl(Uri.parse(AppConstants.githubReleasesApiUrl));
      request.headers.set('User-Agent', 'Dayform-App');
      request.headers.set('Accept', 'application/vnd.github.v3+json');

      final response = await request.close();
      if (response.statusCode != 200) {
        client.close();
        debugPrint(
            '[UpdateService] GitHub API responded with status: ${response.statusCode}');
        return null;
      }

      final responseBody = await response.transform(utf8.decoder).join();
      client.close();

      final json = jsonDecode(responseBody) as Map<String, dynamic>;
      final tagName = json['tag_name'] as String? ?? '';
      final releaseName = json['name'] as String? ?? tagName;
      final releaseNotes = json['body'] as String? ?? '';
      final releaseUrl =
          json['html_url'] as String? ?? AppConstants.githubReleasesUrl;
      final publishedAt = json['published_at'] as String? ?? '';

      final rawAssets = json['assets'] as List<dynamic>? ?? [];
      final apkAssets = rawAssets
          .map((a) => ReleaseAsset.fromJson(a as Map<String, dynamic>))
          .where((a) => a.name.toLowerCase().endsWith('.apk'))
          .toList();

      final isNewer = compareVersions(currentVersion, tagName) > 0;

      return AppUpdateInfo(
        currentVersion: currentVersion,
        latestVersion: tagName,
        releaseName: releaseName,
        releaseNotes: releaseNotes,
        releaseUrl: releaseUrl,
        publishedAt: publishedAt,
        apkAssets: apkAssets,
        isUpdateAvailable: isNewer,
      );
    } catch (e, stack) {
      debugPrint('[UpdateService] Error checking for updates: $e\n$stack');
      return null;
    }
  }

  /// Has the user dismissed the notification for this specific release tag?
  Future<bool> isTagDismissed(String tagName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final dismissed = prefs.getString(_dismissedTagKey);
      return dismissed == tagName;
    } catch (_) {
      return false;
    }
  }

  /// Dismiss this release so user is not prompted again until a newer tag is published
  Future<void> dismissTag(String tagName) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_dismissedTagKey, tagName);
    } catch (_) {}
  }

  /// Open release webpage or direct APK download link in browser
  Future<bool> launchDownloadUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('[UpdateService] Failed to launch URL $url: $e');
      return false;
    }
  }
}
