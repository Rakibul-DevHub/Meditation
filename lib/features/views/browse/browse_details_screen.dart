import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:outdoor_therapy/features/views/browse/controller/browse_controller.dart';
import 'package:outdoor_therapy/model/category_model.dart';
import 'package:outdoor_therapy/core/widget/player_controller.dart';
import 'package:outdoor_therapy/features/views/now_playing/now_playing_screen.dart';
import 'package:outdoor_therapy/core/widget/custom_play_card.dart';

class BrowseDetailsScreen extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final int soundCount;
  final IconData icon;
  final List<Color> gradient;
  final String imagePath;

  const BrowseDetailsScreen({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.soundCount,
    required this.icon,
    required this.gradient,
    required this.imagePath,
  });

  @override
  State<BrowseDetailsScreen> createState() => _BrowseDetailsScreenState();
}

class _BrowseDetailsScreenState extends State<BrowseDetailsScreen> {
  final BrowseController _controller = Get.find<BrowseController>();
  final PlayerController _playerController = Get.find<PlayerController>();

  @override
  void initState() {
    super.initState();
    // Fetch details for this specific category
    _controller.fetchCategoryDetails(widget.categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      bottomNavigationBar: Obx(() {
        final track = _playerController.currentTrack.value;
        final showPlayer = _playerController.showMiniPlayer.value;

        if (!showPlayer || track == null) return const SizedBox.shrink();

        return CustomPlayCard(
          track: track,
          isPlaying: _playerController.isPlaying.value,
          onPlayPause: _playerController.togglePlayPause,
          onClose: _playerController.stopAndHidePlayer,
        );
      }),
      body: Obx(() {
        if (_controller.isDetailsLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF117A65)),
          );
        }

        if (_controller.detailsError.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _controller.detailsError.value,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _controller.fetchCategoryDetails(widget.categoryId),
                  child: const Text('Try Again'),
                ),
              ],
            ),
          );
        }

        final category = _controller.selectedCategory.value;
        final tracks = category?.tracks ?? [];

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── App Bar with Back Button and Title ───────────────────
            SliverAppBar(
              expandedHeight: 280,
              pinned: true,
              backgroundColor: const Color(0xFF0A0E1A),
              elevation: 0,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8, top: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Background image with gradient fallback
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: widget.gradient,
                        ),
                      ),
                      child: CachedNetworkImage(
                        imageUrl: widget.imagePath,
                        fit: BoxFit.cover,
                        errorWidget: (_, __, ___) => const SizedBox.expand(),
                      ),
                    ),
                    // Dark overlay
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            const Color(0xFF0A0E1A).withOpacity(0.9),
                          ],
                        ),
                      ),
                    ),
                    // Category info
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: 30,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? widget.categoryName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 0,
                              vertical: 6,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '${category?.totalTracks ?? widget.soundCount} sounds',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── Sound Tracks List ────────────────────────────────────
            if (tracks.isEmpty)
              const SliverFillRemaining(
                child: Center(
                  child: Text(
                    'No tracks available in this category',
                    style: TextStyle(color: Colors.white54),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120), // Increased bottom padding for mini-player
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _SoundTrackCard(
                      track: tracks[index],
                      fullList: tracks,
                      index: index,
                      isLast: index == tracks.length - 1,
                    ),
                    childCount: tracks.length,
                  ),
                ),
              ),
          ],
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sound Track Card
// ─────────────────────────────────────────────────────────────────────────────
class _SoundTrackCard extends StatefulWidget {
  final TrackModel track;
  final List<TrackModel> fullList;
  final int index;
  final bool isLast;

  const _SoundTrackCard({
    required this.track,
    required this.fullList,
    required this.index,
    required this.isLast,
  });

  @override
  State<_SoundTrackCard> createState() => _SoundTrackCardState();
}

class _SoundTrackCardState extends State<_SoundTrackCard> {
  final PlayerController _playerController = Get.find<PlayerController>();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              // Play button
              GestureDetector(
                onTap: () {
                  _playerController.setPlaylist(widget.fullList, initialIndex: widget.index);
                  Get.to(() => const NowPlayingScreen());
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF1A5276),
                        Color(0xFF117A65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF117A65).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Obx(() {
                    final isCurrentTrack = _playerController.currentTrack.value?.id == widget.track.id;
                    final isPlaying = _playerController.isPlaying.value;

                    return Icon(
                      (isCurrentTrack && isPlaying) ? Icons.pause_rounded : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 28,
                    );
                  }),
                ),
              ),
              const SizedBox(width: 16),

              // Track info (Tap anywhere on info to also play)
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _playerController.setPlaylist(widget.fullList, initialIndex: widget.index);
                    Get.to(() => const NowPlayingScreen());
                  },
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.track.title ?? 'Untitled',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (widget.track.durationSeconds != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _formatDuration(widget.track.durationSeconds!),
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.6),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.track.description ?? widget.track.tagline ?? 'No description available',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.45),
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),

              // More options
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      // TODO: Toggle Favorite API
                    },
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      // TODO: Download API
                    },
                    icon: Icon(
                      Icons.file_download_outlined,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!widget.isLast)
          Divider(
            height: 0,
            color: Colors.white.withOpacity(0.08),
            thickness: 0.5,
          ),
      ],
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
