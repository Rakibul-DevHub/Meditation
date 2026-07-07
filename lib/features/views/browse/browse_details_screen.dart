/**
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:outdoor_therapy/features/views/browse/controller/browse_controller.dart';
import 'package:outdoor_therapy/model/category_model.dart';
import 'package:outdoor_therapy/features/views/now_playing/player_controller.dart';
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
*/







import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

import 'package:outdoor_therapy/features/views/browse/controller/browse_controller.dart';
import 'package:outdoor_therapy/model/category_model.dart';
import 'package:outdoor_therapy/features/views/now_playing/player_controller.dart';
import 'package:outdoor_therapy/features/views/now_playing/now_playing_screen.dart';
import 'package:outdoor_therapy/core/widget/custom_play_card.dart';

import 'package:outdoor_therapy/core/app_colors.dart';
import 'package:outdoor_therapy/core/download_service.dart';
import 'package:outdoor_therapy/core/network/app_url.dart';
import 'package:outdoor_therapy/core/network/network_caller_dio.dart';
import 'package:outdoor_therapy/core/network/secure_storage_service.dart';
import 'package:outdoor_therapy/model/favorite_response_model.dart';
import 'package:outdoor_therapy/features/views/favorite/favorite_screen_controller.dart';
import 'package:outdoor_therapy/features/views/download/download_screen_controller.dart';

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
                  onPressed: () =>
                      _controller.fetchCategoryDetails(widget.categoryId),
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
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
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
// Sound Track Card  (with Favorite + Download logic)
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
  final DownloadService _downloadService = Get.find<DownloadService>();
  final FavoriteScreenController _favoriteController =
  Get.find<FavoriteScreenController>();

  late final DownloadController _downloadController;

  final RxBool isFavorite = false.obs;
  final RxMap<String, DownloadState> _localDownloadStates =
      <String, DownloadState>{}.obs;

  final Dio _downloadDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),
    followRedirects: true,
    validateStatus: (status) => status != null && status < 500,
  ));

  String get _trackId => widget.track.id ?? '';

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<DownloadController>()) {
      _downloadController = Get.find<DownloadController>();
    } else {
      _downloadController = Get.put(DownloadController());
    }

    _checkFavoriteStatusFromController();
    _checkDownloadStatus();
  }

  // ── Favorite ───────────────────────────────────────────────────────────────
  void _checkFavoriteStatusFromController() {
    if (_trackId.isEmpty) return;
    final isFav =
    _favoriteController.tracks.any((favTrack) => favTrack.id == _trackId);
    isFavorite.value = isFav;
  }

  Future<void> _toggleFavorite() async {
    final track = widget.track;
    if (_trackId.isEmpty) return;

    final previousState = isFavorite.value;
    final newState = !previousState;

    // INSTANT UI UPDATE
    isFavorite.value = newState;

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        isFavorite.value = previousState;
        Get.snackbar(
          'Error',
          'Please login again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        return;
      }

      final networkCaller = NetworkCallerDio();

      if (newState) {
        // Add to favorites
        final response = await networkCaller.postRequest(
          AppUrl.addFavorites(_trackId),
          body: {},
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.isSuccess) {
          final favoriteTrack = FavoriteTrack(
            id: _trackId,
            title: track.title ?? 'Unknown',
            description: track.description,
            coverImageUrl: track.coverImageUrl,
            durationSeconds: track.durationSeconds,
            categoryName: track.categoryName,
            playCount: track.playCount ?? 0,
            downloadCount: track.downloadCount ?? 0,
            isFeatured: track.isFeatured ?? false,
            isSleepTonight: track.isSleepTonight ?? false,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            categoryId: '',
            audioUrl: '',
          );

          // Avoid duplicates
          if (!_favoriteController.tracks.any((t) => t.id == _trackId)) {
            _favoriteController.tracks.insert(0, favoriteTrack);
          }

          Get.snackbar(
            'Added to Favorites',
            '${track.title} added to your favorites.',
            backgroundColor: const Color(0xFF7B61FF),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        } else {
          isFavorite.value = previousState;
          Get.snackbar(
            'Failed',
            response.errorMessage ?? 'Could not add to favorites.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        // Remove from favorites
        final response = await networkCaller.postRequest(
          AppUrl.removeFavorites(_trackId),
          body: {},
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.isSuccess) {
          _favoriteController.tracks.removeWhere((t) => t.id == _trackId);

          Get.snackbar(
            'Removed from Favorites',
            '${track.title} removed from your favorites.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        } else {
          isFavorite.value = previousState;
          Get.snackbar(
            'Failed',
            response.errorMessage ?? 'Could not remove from favorites.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      }
    } catch (e) {
      isFavorite.value = previousState;
      debugPrint('❌ Error toggling favorite: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    }
  }

  // ── Download helpers ─────────────────────────────────────────────────────────
  Future<void> _checkDownloadStatus() async {
    if (_trackId.isEmpty) return;
    final isDownloaded = await _isTrackDownloadedLocally(_trackId);

    if (isDownloaded) {
      final existingState = _localDownloadStates[_trackId];
      if (existingState?.status != DownloadStatus.alreadyDownloaded) {
        _localDownloadStates[_trackId] = DownloadState(
          trackId: _trackId,
          trackTitle: widget.track.title ?? 'Unknown',
          coverImageUrl: widget.track.coverImageUrl ?? '',
          categoryName: widget.track.categoryName ?? 'Music',
          durationSeconds: widget.track.durationSeconds ?? 0,
          status: DownloadStatus.alreadyDownloaded,
          progressPercent: 100,
        );
      }
    } else {
      if (_localDownloadStates.containsKey(_trackId)) {
        _localDownloadStates.remove(_trackId);
      }
    }
  }

  Future<String?> _getLocalFilePath(String trackId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tracks/$trackId.mp3');
      if (await file.exists() && (await file.stat()).size > 1024) {
        return file.path;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<bool> _isTrackDownloadedLocally(String trackId) async =>
      (await _getLocalFilePath(trackId)) != null;

  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.audio.isGranted) return true;
      final r = await Permission.audio.request();
      if (r.isGranted) return true;
      return (await Permission.storage.request()).isGranted;
    }
    return true;
  }

  Future<void> _updateDownloadStatusOnBackend(String downloadId) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) return;
      final networkCaller = NetworkCallerDio();
      await networkCaller.patchRequest(
        AppUrl.completeDownloadSoundsStatus(downloadId),
        body: {'status': 'COMPLETED', 'progressPercent': 100},
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      debugPrint('Backend status update error: $e');
    }
  }

  // ── Download flow ────────────────────────────────────────────────────────────
  Future<void> _startDownload(String trackId, TrackModel track) async {
    if (await _isTrackDownloadedLocally(trackId)) {
      _localDownloadStates[trackId] = DownloadState(
        trackId: trackId,
        trackTitle: track.title ?? 'Unknown',
        coverImageUrl: track.coverImageUrl ?? '',
        categoryName: track.categoryName ?? 'Music',
        durationSeconds: track.durationSeconds ?? 0,
        status: DownloadStatus.alreadyDownloaded,
        progressPercent: 100,
      );
      Get.snackbar(
        'Already Downloaded',
        '${track.title} is already saved for offline.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    if (!await _requestStoragePermission()) {
      Get.snackbar(
        'Permission Denied',
        'Please allow storage access to download tracks.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    final cancelToken = CancelToken();
    final downloadingState = DownloadState(
      trackId: trackId,
      trackTitle: track.title ?? 'Unknown Track',
      coverImageUrl: track.coverImageUrl ?? '',
      categoryName: track.categoryName ?? 'Music',
      durationSeconds: track.durationSeconds ?? 0,
      status: DownloadStatus.downloading,
      progressPercent: 0,
      cancelToken: cancelToken,
    );
    _localDownloadStates[trackId] = downloadingState;
    _downloadService.addOrUpdateDownload(downloadingState);

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        throw Exception('Not authenticated. Please log in again.');
      }

      final networkCaller = NetworkCallerDio();

      final initResponse = await networkCaller.postRequest(
        AppUrl.downloadSounds(trackId),
        body: {},
        headers: {'Authorization': 'Bearer $token'},
      );
      if (cancelToken.isCancelled) return;

      final downloadUrl =
      initResponse.jsonResponse?['data']?['downloadUrl'] as String?;
      final downloadId = initResponse.jsonResponse?['data']?['id'] as String?;

      if (!initResponse.isSuccess || downloadUrl == null) {
        throw Exception(
            initResponse.errorMessage ?? 'Server did not return a download URL');
      }

      final dir = await getApplicationDocumentsDirectory();
      final tracksDir = Directory('${dir.path}/tracks');
      if (!await tracksDir.exists()) await tracksDir.create(recursive: true);
      final filePath = '${tracksDir.path}/$trackId.mp3';

      await _downloadDio.download(
        downloadUrl,
        filePath,
        cancelToken: cancelToken,
        deleteOnError: true,
        onReceiveProgress: (received, total) {
          if (cancelToken.isCancelled) return;
          if (total > 0) {
            final pct = ((received / total) * 100).clamp(0, 100).toInt();
            final updated = downloadingState.copyWith(
              progressPercent: pct,
              status: DownloadStatus.downloading,
              downloadId: downloadId,
            );
            _localDownloadStates[trackId] = updated;
            _downloadService.addOrUpdateDownload(updated);
          }
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (s) => s != null && s < 500,
        ),
      );
      if (cancelToken.isCancelled) return;

      final savedFile = File(filePath);
      if (!await savedFile.exists()) {
        throw Exception('File was not saved. Please try again.');
      }
      final size = await savedFile.length();
      if (size < 1024) {
        await savedFile.delete();
        throw Exception('Downloaded file appears corrupted. Please retry.');
      }

      final completedState = downloadingState.copyWith(
        status: DownloadStatus.completed,
        progressPercent: 100,
        downloadId: downloadId,
      );
      _localDownloadStates[trackId] = completedState;
      _downloadService.addOrUpdateDownload(completedState);
      _downloadService.markAsCompleted(trackId);

      final cachedTrack = DownloadedTrack(
        id: downloadId ?? trackId,
        trackId: trackId,
        title: track.title ?? 'Unknown Track',
        description: track.description,
        coverImageUrl: track.coverImageUrl ?? '',
        durationSeconds: track.durationSeconds ?? 0,
        status: 'COMPLETED',
        progressPercent: 100,
        categoryName: track.categoryName ?? 'Unknown',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await _downloadController.saveTrackToCache(cachedTrack);

      if (downloadId != null) _updateDownloadStatusOnBackend(downloadId);

      Get.snackbar(
        'Download Complete',
        '${track.title} saved for offline listening.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
    } on DioException catch (e) {
      if (e.type == DioExceptionType.cancel || cancelToken.isCancelled) {
        final cancelled = downloadingState.copyWith(
            status: DownloadStatus.cancelled, errorMessage: 'Cancelled');
        _localDownloadStates[trackId] = cancelled;
        _downloadService.addOrUpdateDownload(cancelled);
        Future.delayed(const Duration(milliseconds: 500), () {
          _downloadService.removeFromActive(trackId);
          _localDownloadStates.remove(trackId);
        });
      } else {
        _handleError(trackId, downloadingState, e);
      }
    } catch (e) {
      _handleError(trackId, downloadingState, e);
    }
  }

  void _handleError(String trackId, DownloadState base, Object e) {
    debugPrint('Download error: $e');
    final failed =
    base.copyWith(status: DownloadStatus.failed, errorMessage: e.toString());
    _localDownloadStates[trackId] = failed;
    _downloadService.addOrUpdateDownload(failed);
    Get.snackbar(
      'Download Failed',
      'Could not save track. Download limit Full.',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 4),
    );
  }

  // ── Download button widget ───────────────────────────────────────────────────
  Widget _buildDownloadButton(String trackId, TrackModel track) {
    return Obx(() {
      final state = _localDownloadStates[trackId] ??
          _downloadService.getDownloadState(trackId);

      if (state == null || state.status == DownloadStatus.idle) {
        return IconButton(
          icon: Icon(Icons.file_download_outlined,
              color: Colors.white.withOpacity(0.5)),
          onPressed: () => _startDownload(trackId, track),
          tooltip: 'Download for offline',
        );
      }

      switch (state.status) {
        case DownloadStatus.downloading:
          return GestureDetector(
            onTap: () {
              _downloadService.cancelDownload(trackId);
              _localDownloadStates.remove(trackId);
            },
            child: SizedBox(
              width: 40,
              height: 40,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    value: state.progressPercent > 0
                        ? state.progressPercent / 100
                        : null,
                    strokeWidth: 2.5,
                    color: const Color(0xff6366F1),
                    backgroundColor: Colors.white24,
                  ),
                  state.progressPercent > 0
                      ? Text('${state.progressPercent}%',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold))
                      : const Icon(Icons.close,
                      size: 12, color: Colors.white70),
                ],
              ),
            ),
          );

        case DownloadStatus.completed:
        case DownloadStatus.alreadyDownloaded:
          return IconButton(
            icon: const Icon(Icons.check_circle, color: Colors.green),
            onPressed: null,
            tooltip: 'Downloaded',
          );

        case DownloadStatus.failed:
          return IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.red),
            onPressed: () => _startDownload(trackId, track),
            tooltip: 'Tap to retry',
          );

        default:
          return IconButton(
            icon: Icon(Icons.file_download_outlined,
                color: Colors.white.withOpacity(0.5)),
            onPressed: () => _startDownload(trackId, track),
          );
      }
    });
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

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
                  _playerController.setPlaylist(widget.fullList,
                      initialIndex: widget.index);
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
                    final isCurrentTrack =
                        _playerController.currentTrack.value?.id ==
                            widget.track.id;
                    final isPlaying = _playerController.isPlaying.value;

                    return Icon(
                      (isCurrentTrack && isPlaying)
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
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
                    _playerController.setPlaylist(widget.fullList,
                        initialIndex: widget.index);
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
                        widget.track.description ??
                            widget.track.tagline ??
                            'No description available',
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

              // Favorite + Download buttons
              Row(
                children: [
                  Obx(() => IconButton(
                    onPressed: _toggleFavorite,
                    icon: Icon(
                      isFavorite.value
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: isFavorite.value
                          ? const Color(0xFF7B61FF)
                          : Colors.white.withOpacity(0.5),
                    ),
                  )),
                  _buildDownloadButton(_trackId, widget.track),
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
}