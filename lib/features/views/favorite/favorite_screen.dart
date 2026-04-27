/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import '../../../model/favorite_response_model.dart';
import 'favorite_screen_controller.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not registered
    final controller = Get.isRegistered<FavoriteScreenController>()
        ? Get.find<FavoriteScreenController>()
        : Get.put(FavoriteScreenController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favorites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    '${controller.tracks.length} saved sounds',
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 14,
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                // Loading state
                if (controller.isLoading.value && controller.tracks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                    ),
                  );
                }

                // Error state
                if (controller.errorMessage.value.isNotEmpty && controller.tracks.isEmpty) {
                  return Center(
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
                              color: Color(0xFF9AA4B2),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: controller.refresh,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF7B61FF),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                // Empty state
                if (controller.tracks.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.favorite_border,
                          size: 64,
                          color: Color(0xFF9AA4B2),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No favorites yet',
                          style: TextStyle(color: Colors.white54),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Start adding sounds you love!',
                          style: TextStyle(color: Colors.white38, fontSize: 12),
                        ),
                      ],
                    ),
                  );
                }

                // Favorites list
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    itemCount: controller.tracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final track = controller.tracks[index];
                      return _FavoriteCard(
                        track: track,
                        onRemove: () async {
                          // Show confirmation dialog
                          final confirm = await showDialog<bool>(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: const Color(0xFF151932),
                              title: const Text(
                                'Remove from Favorites',
                                style: TextStyle(color: Colors.white),
                              ),
                              content: const Text(
                                'Are you sure you want to remove this track from your favorites?',
                                style: TextStyle(color: Colors.white70),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text(
                                    'Remove',
                                    style: TextStyle(color: Color(0xFF7B61FF)),
                                  ),
                                ),
                              ],
                            ),
                          );

                          if (confirm == true) {
                            await controller.removeFromFavoritesApi(track.id);
                          }
                        },
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteTrack track;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.track,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151932),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            /// Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: track.coverImageUrl ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFF1E2340),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFF1E2340),
                  child: const Icon(
                    Icons.music_note,
                    color: Color(0xFF9AA4B2),
                    size: 32,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.categoryName ?? 'Unknown Category',
                    style: const TextStyle(
                      color: Color(0xFF7B61FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (track.formattedDuration.isNotEmpty)
                    Text(
                      track.formattedDuration,
                      style: const TextStyle(
                        color: Color(0xFF9AA4B2),
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            /// ❤️ Remove Button
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Color(0xFF7B61FF),
                size: 24,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}*/







///
///
/// todo:: fething dat with refresher
///
///



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import '../../../model/favorite_response_model.dart';
import 'favorite_screen_controller.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not registered
    final controller = Get.isRegistered<FavoriteScreenController>()
        ? Get.find<FavoriteScreenController>()
        : Get.put(FavoriteScreenController());

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ──────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favorites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Text(
                    '${controller.tracks.length} saved sounds',
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 14,
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // ── Body ─────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                // Loading state (initial load)
                if (controller.isLoading.value && controller.tracks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                    ),
                  );
                }

                // Error state
                if (controller.errorMessage.isNotEmpty && controller.tracks.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    color: const Color(0xFF7B61FF),
                    backgroundColor: const Color(0xFF151932),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
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
                                    color: Color(0xFF9AA4B2),
                                    fontSize: 14,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                ElevatedButton(
                                  onPressed: controller.refresh,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF7B61FF),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Empty state
                if (controller.tracks.isEmpty) {
                  return RefreshIndicator(
                    onRefresh: controller.refresh,
                    color: const Color(0xFF7B61FF),
                    backgroundColor: const Color(0xFF151932),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: SizedBox(
                        height: MediaQuery.of(context).size.height * 0.7,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.favorite_border,
                                size: 64,
                                color: Color(0xFF9AA4B2),
                              ),
                              SizedBox(height: 16),
                              Text(
                                'No favorites yet',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Start adding sounds you love!',
                                style: TextStyle(
                                  color: Color(0xFF9AA4B2),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }

                // Favorites list with pull-to-refresh and pagination
                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  color: const Color(0xFF7B61FF),
                  backgroundColor: const Color(0xFF151932),
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollEndNotification &&
                          notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 200) {
                        controller.loadNextPage();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.tracks.length +
                          (controller.isLoading.value && controller.tracks.isNotEmpty ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index == controller.tracks.length &&
                            controller.isLoading.value &&
                            controller.tracks.isNotEmpty) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                              ),
                            ),
                          );
                        }

                        final track = controller.tracks[index];
                        return _FavoriteCard(
                          track: track,
                          onRemove: () async {
                            // Show confirmation dialog
                            final confirm = await showDialog<bool>(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => AlertDialog(
                                backgroundColor: const Color(0xFF151932),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  'Remove from Favorites',
                                  style: TextStyle(color: Colors.white),
                                ),
                                content: Text(
                                  'Are you sure you want to remove "${track.title}" from your favorites?',
                                  style: const TextStyle(color: Colors.white70),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: const Text(
                                      'Cancel',
                                      style: TextStyle(color: Colors.white54),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: const Text(
                                      'Remove',
                                      style: TextStyle(color: Color(0xFF7B61FF)),
                                    ),
                                  ),
                                ],
                              ),
                            );

                            if (confirm == true) {
                              await controller.removeFromFavoritesApi(track.id);
                            }
                          },
                        );
                      },
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final FavoriteTrack track;
  final VoidCallback onRemove;

  const _FavoriteCard({
    required this.track,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151932),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            /// Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: CachedNetworkImage(
                imageUrl: track.coverImageUrl ?? '',
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFF1E2340),
                  child: const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                    ),
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 70,
                  color: const Color(0xFF1E2340),
                  child: const Icon(
                    Icons.music_note,
                    color: Color(0xFF9AA4B2),
                    size: 32,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 14),

            /// Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    track.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.categoryName ?? 'Unknown Category',
                    style: const TextStyle(
                      color: Color(0xFF7B61FF),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (track.formattedDuration.isNotEmpty)
                    Text(
                      track.formattedDuration,
                      style: const TextStyle(
                        color: Color(0xFF9AA4B2),
                        fontSize: 12,
                      ),
                    ),
                  if (track.description != null && track.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      track.description!,
                      style: const TextStyle(
                        color: Color(0xFF9AA4B2),
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(width: 8),

            /// ❤️ Remove Button
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Color(0xFF7B61FF),
                size: 24,
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }
}