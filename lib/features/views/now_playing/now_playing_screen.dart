
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
import '../../../core/widget/player_controller.dart';
import '../../../model/category_model.dart';
import '../menu/controller/menu_screen_controller.dart'; // Import MenuScreenController
import '../download/download_controller.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final DownloadService _downloadService = Get.find<DownloadService>();

  // Use MenuScreenController for sleep timer
  late final MenuScreenController _menuController;

  // DownloadController might not be initialised yet if the user never visited
  // the downloads tab — use Get.put so it is created lazily if needed.
  DownloadController get _downloadController =>
      Get.isRegistered<DownloadController>()
          ? Get.find<DownloadController>()
          : Get.put(DownloadController());

  final RxBool isFavorite = false.obs;
  final RxMap<String, DownloadState> _localDownloadStates =
      <String, DownloadState>{}.obs;

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
    // Initialize MenuScreenController if not already registered
    if (Get.isRegistered<MenuScreenController>()) {
      _menuController = Get.find<MenuScreenController>();
    } else {
      _menuController = Get.put(MenuScreenController());
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initDownloadState();
      _applySleepTimerFromController(); // Apply sleep timer from controller
    });
  }

  /// Restore green-tick state if the file is already on disk.
  Future<void> _initDownloadState() async {
    final track = _playerController.currentTrack.value;
    if (track?.id == null) return;
    if (await _isTrackDownloadedLocally(track!.id!)) {
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
  }

  // ── Sleep Timer Methods using MenuScreenController ───────────────────────

  /// Apply sleep timer from controller value
  void _applySleepTimerFromController() {
    final label = _menuController.sleepTimer.value;
    final minutes = _labelToMinutes(label);
    _applySleepTimer(minutes);
  }

  /// Convert label to minutes
  int _labelToMinutes(String label) {
    if (label == 'Off') return 0;
    if (label == '15 min') return 15;
    if (label == '30 min') return 30;
    if (label == '45 min') return 45;
    if (label == '60 min') return 60;
    if (label == '1 hour') return 60;
    return 0;
  }

  /// Apply the sleep timer functionality (stop audio after specified minutes)
  void _applySleepTimer(int minutes) {
    // Cancel any existing timer
    _sleepTimer?.cancel();

    if (minutes > 0) {
      // Start new timer
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
    } else {
      debugPrint('⏰ Sleep timer turned off');
    }
  }

  // ── Helpers ──────────────────────────────────────────────────────────────

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

  // ── Download flow ─────────────────────────────────────────────────────────

  Future<void> _startDownload(String trackId, TrackModel track) async {
    // 1 — Already on disk?
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

    // 2 — Permission
    if (!await _requestStoragePermission()) {
      Get.snackbar('Permission Denied', 'Please allow storage access to download tracks.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4));
      return;
    }

    // 3 — Init download state
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

      // 4 — Get signed URL from backend
      final initResponse = await networkCaller.postRequest(
        AppUrl.downloadSounds(trackId),
        body: {},
        headers: {'Authorization': 'Bearer $token'},
      );
      if (cancelToken.isCancelled) return;

      final downloadUrl = initResponse.jsonResponse?['data']?['downloadUrl'] as String?;
      final downloadId  = initResponse.jsonResponse?['data']?['id'] as String?;

      if (!initResponse.isSuccess || downloadUrl == null) {
        throw Exception(initResponse.errorMessage ?? 'Server did not return a download URL');
      }

      // 5 — Download file to app documents directory
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

      // 6 — Verify file
      final savedFile = File(filePath);
      if (!await savedFile.exists()) throw Exception('File was not saved. Please try again.');
      final size = await savedFile.length();
      if (size < 1024) {
        await savedFile.delete();
        throw Exception('Downloaded file appears corrupted. Please retry.');
      }
      debugPrint('Saved $filePath (${(size / 1024 / 1024).toStringAsFixed(2)} MB)');

      // 7 — Mark complete in UI state
      final completedState = downloadingState.copyWith(
        status: DownloadStatus.completed,
        progressPercent: 100,
        downloadId: downloadId,
      );
      _localDownloadStates[trackId] = completedState;
      _downloadService.addOrUpdateDownload(completedState);
      _downloadService.markAsCompleted(trackId);

      // 8 — PERSIST METADATA TO LOCAL CACHE so Downloads screen shows it offline
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

      // 9 — Notify backend (fire-and-forget)
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

  // ── Download button ───────────────────────────────────────────────────────

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

  // ── Sleep timer bottom sheet using MenuScreenController ───────────────────

  void _showSleepTimerSheet() {
    // Use the MenuScreenController's bottom sheet
    _menuController.showSleepTimerPicker(context);

    // Listen for changes in sleep timer and apply them
    // Using a listener that will be triggered when sleep timer value changes
    _menuController.sleepTimer.listen((newValue) {
      _applySleepTimer(_labelToMinutes(newValue));
    });
  }

  IconData _getPlaybackIcon() {
    switch (_playerController.playbackMode.value) {
      case PlaybackMode.shuffle:   return Icons.shuffle_rounded;
      case PlaybackMode.repeatOne: return Icons.repeat_one_rounded;
      default:                     return Icons.repeat_rounded;
    }
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    super.dispose();
  }

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
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
        if (track == null) {
          return const Center(
              child: Text('No track selected', style: TextStyle(color: Colors.white)));
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
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
                    Obx(() => IconButton(
                      icon: Icon(
                        isFavorite.value ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite.value ? const Color(0xFF7B61FF) : AppColors.lightGreyColor,
                      ),
                      onPressed: () async {
                        final t = _playerController.currentTrack.value;
                        if (t == null) return;
                        final token = await SecureStorageService.instance.getAccessToken();
                        if (token == null) return;
                        final networkCaller = NetworkCallerDio();
                        final res = await networkCaller.postRequest(
                          AppUrl.addFavorites(t.id ?? ''),
                          body: {},
                          headers: {'Authorization': 'Bearer $token'},
                        );
                      },
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    )),
                    _buildDownloadButton(track.id ?? '', track),
                  ],
                ),

                const SizedBox(height: 30),

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


