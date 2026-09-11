import 'package:flutter/material.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/services/update_service.dart';
import '../../../core/state/app_state.dart';
import '../../../core/theme/app_colors.dart';

class UpdateBanner extends StatelessWidget {
  final AppState appState;
  final AppUpdateInfo updateInfo;

  const UpdateBanner({
    super.key,
    required this.appState,
    required this.updateInfo,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.warmAmber;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: isDark
            ? accent.withOpacity(0.12)
            : const Color(0xFFFFF7ED), // warm cream amber tint
        borderRadius: BorderRadius.circular(AppConstants.cardRadiusMedium),
        border: Border.all(
          color: accent.withOpacity(isDark ? 0.35 : 0.4),
          width: 1.2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.system_update_alt_rounded,
                    size: 18,
                    color: accent,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Update Available',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? AppColors.primaryLightText
                                  : AppColors.primaryDarkText,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              updateInfo.latestVersion,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'A newer version of Dayform is available on GitHub.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.secondaryLightText
                              : AppColors.secondaryDarkText,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                  tooltip: 'Dismiss update notice',
                  onPressed: () => appState.dismissUpdateBanner(),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _showUpdateDialog(context),
                    icon: const Icon(Icons.info_outline_rounded, size: 16),
                    label: const Text('View Release'),
                    style: OutlinedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      foregroundColor: isDark ? Colors.white : Colors.black87,
                      side: BorderSide(
                        color: isDark
                            ? Colors.white24
                            : Colors.black12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _handleDirectInstall(context),
                    icon: const Icon(Icons.download_rounded, size: 16),
                    label: const Text('Install Update'),
                    style: ElevatedButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      backgroundColor: accent,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _handleDirectInstall(BuildContext context) {
    final asset = updateInfo.recommendedAsset;
    final downloadUrl = asset?.downloadUrl ?? updateInfo.releaseUrl;
    UpdateService.instance.launchDownloadUrl(downloadUrl);
  }

  void _showUpdateDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => UpdateDetailsSheet(updateInfo: updateInfo),
    );
  }
}

class UpdateDetailsSheet extends StatelessWidget {
  final AppUpdateInfo updateInfo;

  const UpdateDetailsSheet({super.key, required this.updateInfo});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accent = AppColors.warmAmber;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkCardSurface : AppColors.lightCardSurface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppConstants.cardRadiusLarge),
        ),
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
        ),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black12,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Release Available',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.primaryLightText
                              : AppColors.primaryDarkText,
                        ),
                      ),
                      Text(
                        'Installed: v${updateInfo.currentVersion} • Latest: ${updateInfo.latestVersion}',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? AppColors.secondaryLightText
                              : AppColors.secondaryDarkText,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (updateInfo.releaseName.isNotEmpty) ...[
              Text(
                updateInfo.releaseName,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: isDark
                      ? AppColors.primaryLightText
                      : AppColors.primaryDarkText,
                ),
              ),
              const SizedBox(height: 8),
            ],
            if (updateInfo.releaseNotes.isNotEmpty) ...[
              Text(
                "What's New",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: isDark ? Colors.grey[400] : Colors.grey[600],
                ),
              ),
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 180),
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppColors.darkSurfaceMuted
                      : AppColors.pillLight,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                  ),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    updateInfo.releaseNotes,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                      color: isDark
                          ? AppColors.primaryLightText
                          : AppColors.primaryDarkText,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              'Download APK',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (updateInfo.apkAssets.isNotEmpty)
              ...updateInfo.apkAssets.map((asset) {
                final isRecommended = asset == updateInfo.recommendedAsset;
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isRecommended
                        ? accent.withOpacity(0.08)
                        : (isDark
                            ? AppColors.darkSurfaceMuted
                            : AppColors.pillLight),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isRecommended
                          ? accent.withOpacity(0.4)
                          : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 2),
                    leading: Icon(
                      Icons.android_rounded,
                      color: isRecommended ? accent : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            asset.name,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isRecommended)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: accent,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'Recommended',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      asset.formattedSize.isNotEmpty
                          ? asset.formattedSize
                          : 'Download APK file',
                      style: const TextStyle(fontSize: 11),
                    ),
                    trailing: const Icon(Icons.download_rounded, size: 20),
                    onTap: () {
                      Navigator.pop(context);
                      UpdateService.instance.launchDownloadUrl(asset.downloadUrl);
                    },
                  ),
                );
              })
            else
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  UpdateService.instance.launchDownloadUrl(updateInfo.releaseUrl);
                },
                icon: const Icon(Icons.open_in_browser_rounded),
                label: const Text('Open GitHub Release Page'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                  backgroundColor: accent,
                  foregroundColor: Colors.white,
                ),
              ),
            const SizedBox(height: 8),
            Center(
              child: TextButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  UpdateService.instance.launchDownloadUrl(updateInfo.releaseUrl);
                },
                icon: const Icon(Icons.launch_rounded, size: 14),
                label: const Text(
                  'View complete release on GitHub',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

