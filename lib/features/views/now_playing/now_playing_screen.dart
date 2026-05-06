import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import '../../../core/app_colors.dart';
import '../../../core/download_service.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../model/favorite_response_model.dart';
import 'player_controller.dart';
import '../../../model/category_model.dart';
import '../menu/controller/menu_screen_controller.dart';
import '../download/download_controller.dart';
import '../favorite/favorite_screen_controller.dart'; // Import FavoriteScreenController

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final DownloadService _downloadService = Get.find<DownloadService>();
  final FavoriteScreenController _favoriteController = Get.find<FavoriteScreenController>();

  late final MenuScreenController _menuController;
  late final DownloadController _downloadController;

  final RxBool isFavorite = false.obs;
  final RxBool isLoading = true.obs;
  final RxMap<String, DownloadState> _localDownloadStates = <String, DownloadState>{}.obs;

  String? _currentTrackId;
  bool _isInitialLoad = true;

  Timer? _sleepTimer;

  final Dio _downloadDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(minutes: 10),
    followRedirects: true,
    validateStatus: (status) => status != null && status < 500,
  ));

  @override
  void initState() {
    super.initState();

    if (Get.isRegistered<MenuScreenController>()) {
      _menuController = Get.find<MenuScreenController>();
    } else {
      _menuController = Get.put(MenuScreenController());
    }

    if (Get.isRegistered<DownloadController>()) {
      _downloadController = Get.find<DownloadController>();
    } else {
      _downloadController = Get.put(DownloadController());
    }

    // Listen to track changes
    _listenToTrackChanges();
  }

  // Listen to track changes and refresh data
  void _listenToTrackChanges() {
    ever(_playerController.currentTrack, (TrackModel? track) async {
      if (track != null && track.id != _currentTrackId) {
        debugPrint('🔄 Track changed to: ${track.title}');
        _currentTrackId = track.id;
        await _refreshAllData();
      }
    });
  }

  // Refresh all data (favorite status + download status)
  Future<void> _refreshAllData() async {
    final track = _playerController.currentTrack.value;
    if (track == null) return;

    // Run both checks in parallel
    await Future.wait([
      _checkFavoriteStatusFromController(),
      _checkDownloadStatus(),
    ]);

    debugPrint('✅ Data refreshed for: ${track.title}');
  }

  // Load initial data
  Future<void> _loadInitialData() async {
    isLoading.value = true;

    final track = _playerController.currentTrack.value;
    if (track != null) {
      _currentTrackId = track.id;
      await Future.wait([
        _checkFavoriteStatusFromController(),
        _checkDownloadStatus(),
      ]);
      _applySleepTimerFromController();
    }

    isLoading.value = false;
    _isInitialLoad = false;
  }

  // Check favorite status using FavoriteScreenController
  Future<void> _checkFavoriteStatusFromController() async {
    final track = _playerController.currentTrack.value;
    if (track?.id == null) return;

    // Check if track exists in FavoriteScreenController's tracks list
    final isFav = _favoriteController.tracks.any((favTrack) => favTrack.id == track!.id);
    isFavorite.value = isFav;
    debugPrint('✅ Favorite status from controller for ${track?.title}: ${isFavorite.value}');
  }

  // Check download status
  Future<void> _checkDownloadStatus() async {
    final track = _playerController.currentTrack.value;
    if (track?.id == null) return;

    final isDownloaded = await _isTrackDownloadedLocally(track!.id!);

    if (isDownloaded) {
      final existingState = _localDownloadStates[track.id!];
      if (existingState?.status != DownloadStatus.alreadyDownloaded) {
        _localDownloadStates[track.id!] = DownloadState(
          trackId: track.id!,
          trackTitle: track.title ?? 'Unknown',
          coverImageUrl: track.coverImageUrl ?? '',
          categoryName: track.categoryName ?? 'Music',
          durationSeconds: track.durationSeconds ?? 0,
          status: DownloadStatus.alreadyDownloaded,
          progressPercent: 100,
        );
      }
      debugPrint('✅ Download status for ${track.title}: Downloaded');
    } else {
      if (_localDownloadStates.containsKey(track.id!)) {
        _localDownloadStates.remove(track.id!);
      }
      debugPrint('✅ Download status for ${track.title}: Not downloaded');
    }
  }

  // Toggle favorite using FavoriteScreenController
  Future<void> _toggleFavorite() async {
    final track = _playerController.currentTrack.value;
    if (track == null) return;

    final previousState = isFavorite.value;
    final newState = !previousState;

    // ✅ INSTANT UI UPDATE - Change icon immediately
    isFavorite.value = newState;

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        // Rollback on error
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
        // Adding to favorites
        final response = await networkCaller.postRequest(
          AppUrl.addFavorites(track.id ?? ''),
          body: {},
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.isSuccess) {
          debugPrint('✅ Added to favorites: ${track.title}');

          // Create a FavoriteTrack object and add to controller's list
          final favoriteTrack = FavoriteTrack(
            id: track.id!,
            // trackId: track.id!,
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

          // Add to FavoriteScreenController's list for instant sync
          _favoriteController.tracks.insert(0, favoriteTrack);

          Get.snackbar(
            'Added to Favorites',
            '${track.title} added to your favorites.',
            backgroundColor: const Color(0xFF7B61FF),
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        } else {
          // API failed - rollback UI change
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
        // Removing from favorites
        final response = await networkCaller.postRequest(
          AppUrl.removeFavorites(track.id ?? ''),
          body: {},
          headers: {'Authorization': 'Bearer $token'},
        );

        if (response.isSuccess) {
          debugPrint('✅ Removed from favorites: ${track.title}');

          // Remove from FavoriteScreenController's list for instant sync
          _favoriteController.tracks.removeWhere((t) => t.id == track.id);

          Get.snackbar(
            'Removed from Favorites',
            '${track.title} removed from your favorites.',
            backgroundColor: Colors.orange,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
            duration: const Duration(seconds: 2),
          );
        } else {
          // API failed - rollback UI change
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
      // Error occurred - rollback UI change
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

  // Sleep Timer Methods
  void _applySleepTimerFromController() {
    final label = _menuController.sleepTimer.value;
    final minutes = _labelToMinutes(label);
    _applySleepTimer(minutes);
  }

  int _labelToMinutes(String label) {
    if (label == 'Off') return 0;
    if (label == '15 min') return 15;
    if (label == '30 min') return 30;
    if (label == '45 min') return 45;
    if (label == '60 min') return 60;
    if (label == '1 hour') return 60;
    return 0;
  }

  void _applySleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes > 0) {
      _sleepTimer = Timer(Duration(minutes: minutes), () {
        if (_playerController.isPlaying.value) {
          _playerController.togglePlayPause();
          Get.snackbar(
            'Sleep Timer',
            'Audio stopped automatically',
            backgroundColor: const Color(0xFF6C5ECF),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 3),
          );
        }
      });
      debugPrint('⏰ Sleep timer set for $minutes minutes');
    }
  }

  // Helpers
  String _formatDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}';
  }

  Future<String?> _getLocalFilePath(String trackId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tracks/$trackId.mp3');
      if (await file.exists() && (await file.stat()).size > 1024) return file.path;
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

  // Download flow
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
      Get.snackbar('Already Downloaded', '${track.title} is already saved for offline.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2));
      return;
    }

    if (!await _requestStoragePermission()) {
      Get.snackbar('Permission Denied', 'Please allow storage access to download tracks.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4));
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
      if (token == null) throw Exception('Not authenticated. Please log in again.');

      final networkCaller = NetworkCallerDio();

      final initResponse = await networkCaller.postRequest(
        AppUrl.downloadSounds(trackId),
        body: {},
        headers: {'Authorization': 'Bearer $token'},
      );
      if (cancelToken.isCancelled) return;

      final downloadUrl = initResponse.jsonResponse?['data']?['downloadUrl'] as String?;
      final downloadId = initResponse.jsonResponse?['data']?['id'] as String?;

      if (!initResponse.isSuccess || downloadUrl == null) {
        throw Exception(initResponse.errorMessage ?? 'Server did not return a download URL');
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
      if (!await savedFile.exists()) throw Exception('File was not saved. Please try again.');
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

      Get.snackbar('Download Complete', '${track.title} saved for offline listening.',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));

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
    final failed = base.copyWith(status: DownloadStatus.failed, errorMessage: e.toString());
    _localDownloadStates[trackId] = failed;
    _downloadService.addOrUpdateDownload(failed);
    Get.snackbar('Download Failed', 'Could not save track. Tap to retry.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4));
  }

  // Download button widget
  Widget _buildDownloadButton(String trackId, TrackModel track) {
    return Obx(() {
      final state = _localDownloadStates[trackId] ?? _downloadService.getDownloadState(trackId);

      if (state == null || state.status == DownloadStatus.idle) {
        return IconButton(
          icon: const Icon(Icons.cloud_download_outlined, color: AppColors.lightGreyColor),
          onPressed: () => _startDownload(trackId, track),
          tooltip: 'Download for offline',
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
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
                    value: state.progressPercent > 0 ? state.progressPercent / 100 : null,
                    strokeWidth: 2.5,
                    color: const Color(0xff6366F1),
                    backgroundColor: Colors.white24,
                  ),
                  state.progressPercent > 0
                      ? Text('${state.progressPercent}%',
                      style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))
                      : const Icon(Icons.close, size: 12, color: Colors.white70),
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
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          );

        case DownloadStatus.failed:
          return IconButton(
            icon: const Icon(Icons.error_outline, color: Colors.red),
            onPressed: () => _startDownload(trackId, track),
            tooltip: 'Tap to retry',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          );

        default:
          return IconButton(
            icon: const Icon(Icons.cloud_download_outlined, color: AppColors.lightGreyColor),
            onPressed: () => _startDownload(trackId, track),
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          );
      }
    });
  }

  void _showSleepTimerSheet() {
    _menuController.showSleepTimerPicker(context);
    _menuController.sleepTimer.listen((newValue) {
      _applySleepTimer(_labelToMinutes(newValue));
    });
  }

  IconData _getPlaybackIcon() {
    switch (_playerController.playbackMode.value) {
      case PlaybackMode.shuffle: return Icons.shuffle_rounded;
      case PlaybackMode.repeatOne: return Icons.repeat_one_rounded;
      default: return Icons.repeat_rounded;
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Load initial data when screen first appears
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_isInitialLoad) {
        _loadInitialData();
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xff020617),
      appBar: AppBar(
        backgroundColor: const Color(0xff020617),
        elevation: 0,
        centerTitle: true,
        title: const Text('Now Playing',
            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final track = _playerController.currentTrack.value;

        // Show loading indicator on initial load only
        if (isLoading.value && _isInitialLoad) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          );
        }

        if (track == null) {
          return const Center(
              child: Text('No track selected', style: TextStyle(color: Colors.white)));
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                Hero(
                  tag: 'track-image-${track.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: CachedNetworkImage(
                      imageUrl: track.coverImageUrl ?? '',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.fill,
                      placeholder: (_, __) => Container(color: Colors.white10),
                      errorWidget: (_, __, ___) => Container(
                        color: Colors.white10,
                        child: const Icon(Icons.music_note, color: Colors.white54, size: 50),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.title ?? 'Unknown Track',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 24, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 6),
                          Text(track.categoryName ?? '',
                              style: const TextStyle(color: Color(0xff94A3B8), fontSize: 14)),
                        ],
                      ),
                    ),

                    // Favorite Button - Instant UI change using FavoriteScreenController
                    Obx(() => IconButton(
                      icon: Icon(
                        isFavorite.value ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite.value ? const Color(0xFF7B61FF) : AppColors.lightGreyColor,
                      ),
                      onPressed: _toggleFavorite,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    )),

                    _buildDownloadButton(track.id ?? '', track),
                  ],
                ),

                const SizedBox(height: 80),

                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: const Color(0xff6366F1),
                    inactiveTrackColor: const Color(0xff1E293B),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: _playerController.position.value.inSeconds
                        .toDouble()
                        .clamp(0, _playerController.duration.value.inSeconds.toDouble()),
                    max: _playerController.duration.value.inSeconds.toDouble() > 0
                        ? _playerController.duration.value.inSeconds.toDouble()
                        : 100,
                    onChanged: (v) => _playerController.seek(Duration(seconds: v.toInt())),
                  ),
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_playerController.position.value),
                        style: const TextStyle(color: Colors.white, fontSize: 12)),
                    Text(_formatDuration(_playerController.duration.value),
                        style: const TextStyle(color: Color(0xff94A3B8), fontSize: 12)),
                  ],
                ),

                const SizedBox(height: 40),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(_getPlaybackIcon(),
                          color: _playerController.playbackMode.value == PlaybackMode.continuous
                              ? AppColors.lightGreyColor
                              : const Color(0xff6366F1),
                          size: 26),
                      onPressed: _playerController.cyclePlaybackMode,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
                      onPressed: _playerController.playPrevious,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: _playerController.isLoading.value
                          ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                          : IconButton(
                        icon: Icon(
                          _playerController.isPlaying.value
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 34,
                        ),
                        onPressed: _playerController.togglePlayPause,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
                      onPressed: _playerController.playNext,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
                    Obx(() => IconButton(
                      icon: Icon(Icons.timer_outlined,
                          color: _menuController.sleepTimer.value != 'Off'
                              ? const Color(0xff6366F1)
                              : AppColors.lightGreyColor,
                          size: 26),
                      onPressed: _showSleepTimerSheet,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    )),
                  ],
                ),

                const Spacer(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}