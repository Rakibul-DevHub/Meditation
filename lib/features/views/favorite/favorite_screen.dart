import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import 'package:outdoor_therapy/core/app_text_style.dart';
import '../../../model/favorite_response_model.dart';
import 'favorite_screen_controller.dart';
import '../now_playing/player_controller.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize controller if not registered
    final controller = Get.isRegistered<FavoriteScreenController>()
        ? Get.find<FavoriteScreenController>()
        : Get.put(FavoriteScreenController());

    // Get the PlayerController
    final PlayerController playerController = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ///
          /// ------------ Header ------------
          ///
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Favorites',
                  style: AppTextStyle.ARIAL_White.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Obx(() => Text(
                  '${controller.tracks.length} saved sounds',
                  style: AppTextStyle.ARIAL_Grey.copyWith(
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
                                style: AppTextStyle.ARIAL_Grey.copyWith(
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
                                child: Text(
                                  'Retry',
                                  style: AppTextStyle.ARIAL_White.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
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
                  child: Obx(() {
                    // ✅ Reactive padding based on mini player visibility
                    final bool showMiniPlayer = playerController.showMiniPlayer.value;
                    final double bottomPadding = showMiniPlayer ? 170.0 : 90.0;

                    return ListView.separated(
                      padding: EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: bottomPadding,
                      ),
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: controller.tracks.length +
                          (controller.isLoading.value && controller.tracks.isNotEmpty ? 1 : 0),
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        if (index == controller.tracks.length &&
                            controller.isLoading.value &&
                            controller.tracks.isNotEmpty) {
                          return Center(
                            child: const CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
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
                                backgroundColor: AppColors.backGroundColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: Text(
                                  'Remove from Favorites',
                                  style: AppTextStyle.ARIAL_White.copyWith(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                content: Text(
                                  'Are you sure you want to remove "${track.title}" from your favorites?',
                                  style: AppTextStyle.ARIAL_Grey.copyWith(
                                    fontSize: 14,
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text(
                                      'Cancel',
                                      style: AppTextStyle.ARIAL_Grey.copyWith(
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text(
                                      'Remove',
                                      style: AppTextStyle.ARIAL_White.copyWith(
                                        fontSize: 14,
                                        color: AppColors.primaryColor,
                                      ),
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
                    );
                  }),
                ),
              );
            }),
          ),
        ],
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
                    style: AppTextStyle.ARIAL_White.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    track.categoryName ?? 'Unknown Category',
                    style: AppTextStyle.ARIAL_White.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (track.formattedDuration.isNotEmpty)
                    Text(
                      track.formattedDuration,
                      style: AppTextStyle.ARIAL_Grey.copyWith(
                        fontSize: 12,
                      ),
                    ),
                  if (track.description != null && track.description!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      track.description!,
                      style: AppTextStyle.ARIAL_Grey.copyWith(
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
              icon: Icon(
                Icons.favorite,
                color: AppColors.favoriteColor,
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