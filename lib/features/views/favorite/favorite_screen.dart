/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import '../../../model/favorite_response_model.dart';
import 'favorite_screen_controller.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(FavoriteScreenController());

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
                    '${controller.pagination.value?.total ?? controller.tracks.length} saved sounds',
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
                // Loading — first fetch
                if (controller.isLoading.value && controller.tracks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(color: Color(0xFF7B61FF)),
                  );
                }

                // Error — nothing loaded yet
                if (controller.errorMessage.value.isNotEmpty &&
                    controller.tracks.isEmpty) {
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
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
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
                        Icon(Icons.favorite_border,
                            color: Color(0xFF9AA4B2), size: 64),
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
                          'Sounds you save will appear here.',
                          style: TextStyle(
                            color: Color(0xFF9AA4B2),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                // List
                return RefreshIndicator(
                  color: const Color(0xFF7B61FF),
                  backgroundColor: const Color(0xFF151932),
                  onRefresh: controller.refresh,
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollEndNotification &&
                          notification.metrics.pixels >=
                              notification.metrics.maxScrollExtent - 200) {
                        controller.loadNextPage();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: controller.tracks.length +
                          (controller.isLoading.value ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index == controller.tracks.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(
                                  color: Color(0xFF7B61FF)),
                            ),
                          );
                        }
                        final track = controller.tracks[index];
                        return _FavoriteCard(
                          track: track,
                          onRemove: () =>
                              controller.removeFromFavorites(track.id),
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

// ── Card ───────────────────────────────────────────────────────────────────────

class _FavoriteCard extends StatelessWidget {
  final FavoriteTrack track;
  final VoidCallback onRemove;

  const _FavoriteCard({required this.track, required this.onRemove});

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
            // ── Thumbnail ──────────────────────────────────────────
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF1E2340),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: track.coverImageUrl != null &&
                    track.coverImageUrl!.isNotEmpty
                    ? Image.network(
                  track.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholderIcon(),
                )
                    : _placeholderIcon(),
              ),
            ),

            const SizedBox(width: 14),

            // ── Info ───────────────────────────────────────────────
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
                    track.formattedDuration.isNotEmpty
                        ? track.formattedDuration
                        : track.categoryName ?? '',
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 13,
                    ),
                  ),
                  if (track.description != null &&
                      track.description!.isNotEmpty) ...[
                    const SizedBox(height: 6),
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

            // ── Heart icon ─────────────────────────────────────────
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

  Widget _placeholderIcon() {
    return const Center(
      child: Icon(Icons.music_note, color: Color(0xFF9AA4B2), size: 32),
    );
  }
}*/






















import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import '../../../model/favorite_response_model.dart';
import 'favorite_screen_controller.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    /// ✅ FIX: use existing controller (DON'T create new)
    final controller = Get.find<FavoriteScreenController>();

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
                    '${controller.pagination.value?.total ?? controller.tracks.length} saved sounds',
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
                if (controller.isLoading.value &&
                    controller.tracks.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF7B61FF)),
                  );
                }

                if (controller.errorMessage.value.isNotEmpty &&
                    controller.tracks.isEmpty) {
                  return Center(
                    child: Padding(
                      padding:
                      const EdgeInsets.symmetric(horizontal: 32),
                      child: Column(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
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
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                if (controller.tracks.isEmpty) {
                  return const Center(
                    child: Text(
                      'No favorites yet',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: controller.refresh,
                  child: ListView.separated(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: controller.tracks.length,
                    separatorBuilder: (_, __) =>
                    const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final track = controller.tracks[index];

                      return _FavoriteCard(
                        track: track,

                        /// ✅ FIX: call API remove
                        onRemove: () =>
                            controller.removeFromFavoritesApi(
                                track.id),
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
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color(0xFF1E2340),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: track.coverImageUrl != null &&
                    track.coverImageUrl!.isNotEmpty
                    ? Image.network(
                  track.coverImageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      _placeholderIcon(),
                )
                    : _placeholderIcon(),
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
                    track.formattedDuration.isNotEmpty
                        ? track.formattedDuration
                        : track.categoryName ?? '',
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 13,
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
              ),
              onPressed: onRemove,
            ),
          ],
        ),
      ),
    );
  }

  Widget _placeholderIcon() {
    return const Center(
      child: Icon(Icons.music_note,
          color: Color(0xFF9AA4B2), size: 32),
    );
  }
}