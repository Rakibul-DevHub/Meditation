import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import 'package:outdoor_therapy/features/views/now_playing/player_controller.dart';
import '../../../core/download_service.dart';
import '../../../model/category_model.dart';
import '../../../features/views/now_playing/now_playing_screen.dart';
import 'download_controller.dart';

class DownloadScreen extends StatelessWidget {
  const DownloadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final DownloadController controller = Get.put(DownloadController());
    final DownloadService downloadService = Get.find<DownloadService>();
    final PlayerController playerController = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Obx(() {
          final activeDownloads = downloadService.activeDownloads.values.toList();
          final completedDownloadsFromApi = controller.downloadedTracks;

          final hasActiveDownloads = activeDownloads.isNotEmpty;
          final hasCompletedDownloads = completedDownloadsFromApi.isNotEmpty;

          return RefreshIndicator(
            onRefresh: () async {
              await controller.refresh();
              downloadService.refreshActiveDownloads();
            },
            color: const Color(0xFF7B61FF),
            backgroundColor: const Color(0xFF151932),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Downloads',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${completedDownloadsFromApi.length + activeDownloads.length} sounds downloaded',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.45),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),

                // Loading state
                if (controller.isLoading.value &&
                    completedDownloadsFromApi.isEmpty &&
                    activeDownloads.isEmpty) ...[
                  const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                      ),
                    ),
                  ),
                ],

                // Error state
                if (controller.errorMessage.isNotEmpty &&
                    completedDownloadsFromApi.isEmpty &&
                    activeDownloads.isEmpty) ...[
                  SliverFillRemaining(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                color: Color(0xFF9AA4B2), size: 48),
                            const SizedBox(height: 12),
                            Text(
                              controller.errorMessage.value,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Color(0xFF9AA4B2), fontSize: 14),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                await controller.refresh();
                                downloadService.refreshActiveDownloads();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF7B61FF),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],

                // Empty state
                if (!hasActiveDownloads &&
                    !hasCompletedDownloads &&
                    !controller.isLoading.value &&
                    controller.errorMessage.isEmpty) ...[
                  const SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cloud_download_outlined,
                              size: 64, color: Color(0xFF9AA4B2)),
                          SizedBox(height: 16),
                          Text(
                            'No downloads yet',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w600),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Download your favorite sounds to listen offline',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Color(0xFF9AA4B2), fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Active Downloads Section
                if (activeDownloads.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        'Downloading',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final download = activeDownloads[index];
                        return _ActiveDownloadCard(
                          downloadState: download,
                          onCancel: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF151932),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text('Cancel Download',
                                    style: TextStyle(color: Colors.white)),
                                content: Text(
                                  'Are you sure you want to cancel downloading "${download.trackTitle}"?',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('No',
                                        style: TextStyle(
                                            color: Colors.white54)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Yes, Cancel',
                                        style: TextStyle(
                                            color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              downloadService.cancelDownload(download.trackId);
                              Get.snackbar(
                                'Cancelled',
                                '${download.trackTitle} download cancelled',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 2),
                              );
                            }
                          },
                        );
                      },
                      childCount: activeDownloads.length,
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 28)),
                ],

                // Completed Downloads Section
                if (completedDownloadsFromApi.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: Text(
                        'Downloaded',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.3),
                      ),
                    ),
                  ),
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final track = completedDownloadsFromApi[index];
                        return _CompletedDownloadCard(
                          track: track,
                          onTap: () async {
                            // Try to play from local file first
                            final localFilePath =
                            await track.getLocalFilePath();

                            if (localFilePath != null) {
                              // ✅ Play from local file (works offline)
                              debugPrint(
                                  '▶️ Playing from local file: $localFilePath');
                              final trackModel = TrackModel(
                                id: track.trackId,
                                title: track.title,
                                description: track.description,
                                coverImageUrl: track.coverImageUrl,
                                audioUrl: localFilePath, // local file:// path
                                durationSeconds: track.durationSeconds,
                                categoryName: track.categoryName,
                              );
                              playerController.setPlaylist([trackModel],
                                  initialIndex: 0);
                              Get.to(() => const NowPlayingScreen());
                            } else {
                              // File not found on disk
                              Get.snackbar(
                                'File Not Found',
                                'The downloaded file is missing. Please download it again.',
                                backgroundColor: Colors.orange,
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 4),
                              );
                              // Optionally delete from API list too
                              // await controller.deleteDownload(track.id, track.trackId);
                            }
                          },
                          onDelete: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF151932),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16)),
                                title: const Text('Delete Download',
                                    style: TextStyle(color: Colors.white)),
                                content: Text(
                                  'Are you sure you want to delete "${track.title}"?',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel',
                                        style: TextStyle(
                                            color: Colors.white54)),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    child: const Text('Delete',
                                        style: TextStyle(
                                            color: Colors.redAccent)),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await controller.deleteDownload(
                                  track.id, track.trackId);
                            }
                          },
                        );
                      },
                      childCount: completedDownloadsFromApi.length,
                    ),
                  ),
                ],

                // Loading indicator at bottom
                if (controller.isLoading.value &&
                    completedDownloadsFromApi.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF7B61FF)),
                        ),
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 160)),
              ],
            ),
          );
        }),
      ),
    );
  }
}

// Active Download Card
class _ActiveDownloadCard extends StatelessWidget {
  final DownloadState downloadState;
  final VoidCallback onCancel;

  const _ActiveDownloadCard({
    required this.downloadState,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: CachedNetworkImage(
                  imageUrl: downloadState.coverImageUrl,
                  width: 72,
                  height: 72,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF1E2340),
                    child: const Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF7B61FF)),
                      ),
                    ),
                  ),
                  errorWidget: (_, __, ___) => Container(
                    width: 72,
                    height: 72,
                    color: const Color(0xFF1E2340),
                    child: const Icon(Icons.music_note,
                        color: Color(0xFF9AA4B2), size: 32),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                downloadState.trackTitle,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                downloadState.categoryName,
                                style: const TextStyle(
                                    color: Color(0xFF7B61FF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                downloadState.formattedDuration,
                                style: TextStyle(
                                    color: Colors.white.withOpacity(0.45),
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        GestureDetector(
                          onTap: onCancel,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Icon(Icons.close,
                                size: 18,
                                color: Colors.white.withOpacity(0.55)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: downloadState.progressPercent > 0
                      ? downloadState.progressPercent / 100
                      : null, // indeterminate when 0%
                  minHeight: 4,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF6C5ECF)),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                downloadState.progressPercent > 0
                    ? '${downloadState.progressPercent}% Complete'
                    : 'Starting...',
                style: TextStyle(
                    color: Colors.white.withOpacity(0.4), fontSize: 11),
              ),
            ],
          ),
        ),
        const _RowDivider(),
      ],
    );
  }
}

// Completed Download Card
class _CompletedDownloadCard extends StatelessWidget {
  final DownloadedTrack track;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _CompletedDownloadCard({
    required this.track,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: CachedNetworkImage(
                    imageUrl: track.coverImageUrl,
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFF1E2340),
                      child: const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Color(0xFF7B61FF)),
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 72,
                      height: 72,
                      color: const Color(0xFF1E2340),
                      child: const Icon(Icons.music_note,
                          color: Color(0xFF9AA4B2), size: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        track.title,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        track.categoryName,
                        style: const TextStyle(
                            color: Color(0xFF7B61FF),
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            track.formattedDuration,
                            style: TextStyle(
                                color: Colors.white.withOpacity(0.45),
                                fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          // Offline badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.offline_pin,
                                    size: 10, color: Colors.green),
                                SizedBox(width: 3),
                                Text(
                                  'Offline',
                                  style: TextStyle(
                                      color: Colors.green, fontSize: 10),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: onDelete,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: Icon(Icons.delete_outline_rounded,
                        size: 22, color: Colors.red[400]),
                  ),
                ),
              ],
            ),
          ),
          const _RowDivider(),
        ],
      ),
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.white.withOpacity(0.08),
      indent: 20,
      endIndent: 20,
    );
  }
}