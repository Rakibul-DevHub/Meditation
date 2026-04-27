/**
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

import '../../../core/app_colors.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/network_response_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../core/widget/player_controller.dart';
import '../../../model/category_model.dart';

// Download state enum
enum DownloadStatus { idle, downloading, completed, failed, alreadyDownloaded }

// Download state model
class DownloadState {
  final DownloadStatus status;
  final int progressPercent;
  final String? errorMessage;
  final String? downloadId; // Store the download ID from API response

  DownloadState({
    required this.status,
    this.progressPercent = 0,
    this.errorMessage,
    this.downloadId,
  });

  DownloadState copyWith({
    DownloadStatus? status,
    int? progressPercent,
    String? errorMessage,
    String? downloadId,
  }) {
    return DownloadState(
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadId: downloadId ?? this.downloadId,
    );
  }
}

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final RxBool isFavorite = false.obs;

  // Track download states: key = trackId, value = DownloadState
  final RxMap<String, DownloadState> _downloadStates = <String, DownloadState>{}.obs;

  String? selectedSleepTimer = "Off";
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Standalone Dio instance for file downloads
  final Dio _downloadDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    followRedirects: true,
    validateStatus: (status) => status != null && status < 500,
  ));

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  void _showSleepTimerSheet() {
    final List<String> timers = ["Off", "15 min", "30 min", "45 min", "1 hour"];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bedtime, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text(
                    "Sleep timer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xff1E293B)),
              ...timers.map((timer) => ListTile(
                title: Text(
                  timer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedSleepTimer == timer ? const Color(0xff6366F1) : Colors.white70,
                    fontSize: 16,
                    fontWeight: selectedSleepTimer == timer ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedSleepTimer = timer;
                  });
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Check if track is already downloaded locally
  Future<bool> _isTrackDownloadedLocally(String trackId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tracks/$trackId.mp3');
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  // Request storage permissions (Android 13+)
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.mediaLibrary.isGranted ||
          await Permission.photos.isGranted ||
          await Permission.storage.isGranted) {
        return true;
      }
      final status = await Permission.mediaLibrary.request();
      if (status.isGranted) return true;
      return await Permission.storage.request().isGranted;
    }
    return true;
  }

  // Update download status to COMPLETED on backend
  Future<void> _updateDownloadStatusOnBackend(String downloadId) async {
    try {
      debugPrint('📤 Updating download status on backend for ID: $downloadId');

      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        debugPrint('❌ No token found, skipping status update');
        return;
      }

      final response = await _networkCaller.patchRequest(
        AppUrl.completeDownloadSoundsStatus(downloadId),
        body: {
          "status": "COMPLETED",
          "progressPercent": 100
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        debugPrint('✅ Download status updated successfully on backend');
      } else {
        debugPrint('⚠️ Failed to update download status: ${response.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Error updating download status: $e');
    }
  }

  // Start download flow
  Future<void> _startDownload(String trackId, String trackTitle) async {
    // Check if already downloaded
    final isDownloaded = await _isTrackDownloadedLocally(trackId);
    if (isDownloaded) {
      _downloadStates[trackId] = DownloadState(status: DownloadStatus.alreadyDownloaded);
      Get.snackbar(
        'Already Downloaded',
        '$trackTitle is already saved offline.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );
      return;
    }

    // Check permissions
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      _downloadStates[trackId] = DownloadState(
          status: DownloadStatus.failed,
          errorMessage: 'Storage permission denied'
      );
      Get.snackbar(
        'Permission Denied',
        'Please allow media access to download tracks.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Set to downloading state
    _downloadStates[trackId] = DownloadState(status: DownloadStatus.downloading, progressPercent: 0);

    try {
      // Get auth token
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }

      // Step 1: Call backend to initiate download (returns downloadUrl and downloadId)
      final initResponse = await _networkCaller.postRequest(
        AppUrl.downloadSounds(trackId),
        body: {},
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!initResponse.isSuccess || initResponse.jsonResponse?['data']?['downloadUrl'] == null) {
        throw Exception(initResponse.errorMessage ?? 'Failed to start download');
      }

      final downloadUrl = initResponse.jsonResponse!['data']['downloadUrl'] as String;
      final downloadId = initResponse.jsonResponse!['data']['id'] as String?;

      debugPrint('📥 Download URL: $downloadUrl');
      debugPrint('📥 Download ID: $downloadId');

      // Store download ID in state
      if (downloadId != null) {
        final currentState = _downloadStates[trackId];
        _downloadStates[trackId] = currentState?.copyWith(downloadId: downloadId) ??
            DownloadState(status: DownloadStatus.downloading, downloadId: downloadId);
      }

      // Step 2: Download the actual file
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/tracks';
      await Directory(savePath).create(recursive: true);

      final filePath = '$savePath/$trackId.mp3';

      // Download with progress tracking
      await _downloadDio.download(
        downloadUrl,
        filePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final percent = ((received / total) * 100).toInt();
            _downloadStates[trackId] = DownloadState(
              status: DownloadStatus.downloading,
              progressPercent: percent,
              downloadId: downloadId,
            );
          }
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // ✅ Download completed successfully
      _downloadStates[trackId] = DownloadState(
        status: DownloadStatus.completed,
        progressPercent: 100,
        downloadId: downloadId,
      );

      // ✅ Update download status on backend (PATCH API)
      if (downloadId != null) {
        await _updateDownloadStatusOnBackend(downloadId);
      }

      Get.snackbar(
        'Download Complete',
        '$trackTitle saved for offline listening.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

    } catch (e, stack) {
      debugPrint('❌ Download error: $e');
      debugPrint('🧵 Stack: $stack');

      _downloadStates[trackId] = DownloadState(
        status: DownloadStatus.failed,
        errorMessage: e.toString(),
      );

      Get.snackbar(
        'Download Failed',
        'Could not download $trackTitle. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
    }
  }

  // Build download button with dynamic state
  Widget _buildDownloadButton(String trackId, String trackTitle) {
    return Obx(() {
      final state = _downloadStates[trackId];

      if (state == null || state.status == DownloadStatus.idle) {
        return IconButton(
          icon: const Icon(Icons.cloud_download_outlined, color: AppColors.lightGreyColor),
          onPressed: () => _startDownload(trackId, trackTitle),
          tooltip: 'Download for offline',
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
        );
      }

      switch (state.status) {
        case DownloadStatus.downloading:
          return SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: state.progressPercent / 100,
                  strokeWidth: 2.5,
                  color: const Color(0xff6366F1),
                  backgroundColor: Colors.white24,
                ),
                Text(
                  '${state.progressPercent}%',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
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
            onPressed: () => _startDownload(trackId, trackTitle),
            tooltip: 'Tap to retry',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          );

        default:
          return IconButton(
            icon: const Icon(Icons.cloud_download_outlined, color: AppColors.lightGreyColor),
            onPressed: () => _startDownload(trackId, trackTitle),
            tooltip: 'Download for offline',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          );
      }
    });
  }

  IconData _getPlaybackIcon() {
    switch (_playerController.playbackMode.value) {
      case PlaybackMode.shuffle:
        return Icons.shuffle_rounded;
      case PlaybackMode.repeatOne:
        return Icons.repeat_one_rounded;
      case PlaybackMode.continuous:
      default:
        return Icons.repeat_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      appBar: AppBar(
        backgroundColor: const Color(0xff020617),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final track = _playerController.currentTrack.value;
        if (track == null) {
          return const Center(child: Text("No track selected", style: TextStyle(color: Colors.white)));
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                /// Album Art
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

                /// Title + icons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title ?? 'Unknown Track',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track.categoryName ?? '',
                            style: const TextStyle(
                              color: Color(0xff94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Favorite Button
                    Obx(() => IconButton(
                      icon: Icon(
                        isFavorite.value ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite.value ? const Color(0xFF7B61FF) : AppColors.lightGreyColor,
                      ),
                      onPressed: () async {
                        final currentTrack = _playerController.currentTrack.value;
                        if (currentTrack == null) return;

                        final token = await SecureStorageService.instance.getAccessToken();
                        if (token == null) {
                          Get.snackbar(
                            'Error',
                            'Please login again.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                          return;
                        }

                        final response = await NetworkCallerDio().postRequest(
                          AppUrl.addFavorites(currentTrack.id ?? ''),
                          body: {},
                          headers: {'Authorization': 'Bearer $token'},
                        );

                        if (response.isSuccess) {
                          isFavorite.value = true;
                          Get.snackbar(
                            'Added to Favorites',
                            '${currentTrack.title} added to your favorites.',
                            backgroundColor: const Color(0xFF7B61FF),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Failed',
                            response.errorMessage ?? 'Could not add to favorites.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    )),

                    // Download Button with full logic
                    _buildDownloadButton(track.id ?? '', track.title ?? 'Track'),
                  ],
                ),

                const SizedBox(height: 30),

                /// Progress bar
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
                    value: _playerController.position.value.inSeconds.toDouble()
                        .clamp(0, _playerController.duration.value.inSeconds.toDouble()),
                    max: _playerController.duration.value.inSeconds.toDouble() > 0
                        ? _playerController.duration.value.inSeconds.toDouble()
                        : 100,
                    onChanged: (value) {
                      _playerController.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                /// Time labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_playerController.position.value),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_playerController.duration.value),
                      style: const TextStyle(color: Color(0xff94A3B8), fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Playback Mode Toggle
                    IconButton(
                      icon: Icon(
                        _getPlaybackIcon(),
                        color: _playerController.playbackMode.value == PlaybackMode.continuous
                            ? AppColors.lightGreyColor
                            : const Color(0xff6366F1),
                        size: 26,
                      ),
                      onPressed: _playerController.cyclePlaybackMode,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),

                    // Previous Button
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
                      onPressed: _playerController.playPrevious,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),

                    /// Play/Pause button
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: _playerController.isLoading.value
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                      )
                          : IconButton(
                        icon: Icon(
                          _playerController.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 34,
                        ),
                        onPressed: _playerController.togglePlayPause,
                        padding: EdgeInsets.zero,
                      ),
                    ),

                    // Next Button
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
                      onPressed: _playerController.playNext,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),

                    // Sleep Timer Icon Button
                    IconButton(
                      icon: Icon(
                          Icons.timer_outlined,
                          color: selectedSleepTimer != "Off" ? const Color(0xff6366F1) : AppColors.lightGreyColor,
                          size: 26
                      ),
                      onPressed: _showSleepTimerSheet,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
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
}*/










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
import '../../../core/network/network_response_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../core/widget/player_controller.dart';
import '../../../model/category_model.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  final DownloadService _downloadService = Get.find<DownloadService>();
  final RxBool isFavorite = false.obs;

  // Local download states for the button UI
  final RxMap<String, DownloadState> _localDownloadStates = <String, DownloadState>{}.obs;

  String? selectedSleepTimer = "Off";
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Standalone Dio instance for file downloads
  final Dio _downloadDio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 60),
    followRedirects: true,
    validateStatus: (status) => status != null && status < 500,
  ));

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  void _showSleepTimerSheet() {
    final List<String> timers = ["Off", "15 min", "30 min", "45 min", "1 hour"];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bedtime, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text(
                    "Sleep timer",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xff1E293B)),
              ...timers.map((timer) => ListTile(
                title: Text(
                  timer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedSleepTimer == timer ? const Color(0xff6366F1) : Colors.white70,
                    fontSize: 16,
                    fontWeight: selectedSleepTimer == timer ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedSleepTimer = timer;
                  });
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // Check if track is already downloaded locally
  Future<bool> _isTrackDownloadedLocally(String trackId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tracks/$trackId.mp3');
      return await file.exists();
    } catch (_) {
      return false;
    }
  }

  // Request storage permissions (Android 13+)
  Future<bool> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      if (await Permission.mediaLibrary.isGranted ||
          await Permission.photos.isGranted ||
          await Permission.storage.isGranted) {
        return true;
      }
      final status = await Permission.mediaLibrary.request();
      if (status.isGranted) return true;
      return await Permission.storage.request().isGranted;
    }
    return true;
  }

  // Update download status to COMPLETED on backend
  Future<void> _updateDownloadStatusOnBackend(String downloadId) async {
    try {
      debugPrint('📤 Updating download status on backend for ID: $downloadId');

      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        debugPrint('❌ No token found, skipping status update');
        return;
      }

      final response = await _networkCaller.patchRequest(
        AppUrl.completeDownloadSoundsStatus(downloadId),
        body: {
          "status": "COMPLETED",
          "progressPercent": 100
        },
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        debugPrint('✅ Download status updated successfully on backend');
      } else {
        debugPrint('⚠️ Failed to update download status: ${response.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Error updating download status: $e');
    }
  }

  // Start download flow
// In NowPlayingScreen, update the _startDownload method
  Future<void> _startDownload(String trackId, TrackModel track) async {
    // Check if already downloaded locally
    final isDownloaded = await _isTrackDownloadedLocally(trackId);
    if (isDownloaded) {
      _localDownloadStates[trackId] = DownloadState(
        trackId: trackId,
        trackTitle: track.title ?? 'Unknown',
        coverImageUrl: track.coverImageUrl ?? '',
        categoryName: track.categoryName ?? 'Music',
        durationSeconds: track.durationSeconds ?? 0,
        status: DownloadStatus.alreadyDownloaded,
      );
      Get.snackbar(
        'Already Downloaded',
        '${track.title} is already saved offline.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
      return;
    }

    // Check permissions
    final hasPermission = await _requestStoragePermission();
    if (!hasPermission) {
      _localDownloadStates[trackId] = DownloadState(
        trackId: trackId,
        trackTitle: track.title ?? 'Unknown',
        coverImageUrl: track.coverImageUrl ?? '',
        categoryName: track.categoryName ?? 'Music',
        durationSeconds: track.durationSeconds ?? 0,
        status: DownloadStatus.failed,
        errorMessage: 'Storage permission denied',
      );
      Get.snackbar(
        'Permission Denied',
        'Please allow media access to download tracks.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 4),
      );
      return;
    }

    // Create cancel token for this download
    final cancelToken = CancelToken();

    // Create download state with cancel token
    final downloadState = DownloadState(
      trackId: trackId,
      trackTitle: track.title ?? 'Unknown Track',
      coverImageUrl: track.coverImageUrl ?? '',
      categoryName: track.categoryName ?? 'Music',
      durationSeconds: track.durationSeconds ?? 0,
      status: DownloadStatus.downloading,
      progressPercent: 0,
      cancelToken: cancelToken,
    );

    // Add to both local and global service
    _localDownloadStates[trackId] = downloadState;
    _downloadService.addOrUpdateDownload(downloadState);

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        throw Exception('Authentication required. Please login again.');
      }

      // Step 1: Call backend to initiate download
      final initResponse = await _networkCaller.postRequest(
        AppUrl.downloadSounds(trackId),
        body: {},
        headers: {'Authorization': 'Bearer $token'},
      );

      if (!initResponse.isSuccess || initResponse.jsonResponse?['data']?['downloadUrl'] == null) {
        throw Exception(initResponse.errorMessage ?? 'Failed to start download');
      }

      final downloadUrl = initResponse.jsonResponse!['data']['downloadUrl'] as String;
      final downloadId = initResponse.jsonResponse!['data']['id'] as String?;

      debugPrint('📥 Download URL: $downloadUrl');
      debugPrint('📥 Download ID: $downloadId');

      // Step 2: Download the actual file
      final dir = await getApplicationDocumentsDirectory();
      final savePath = '${dir.path}/tracks';
      await Directory(savePath).create(recursive: true);
      final filePath = '$savePath/$trackId.mp3';

      // Download with progress tracking and cancel token
      await _downloadDio.download(
        downloadUrl,
        filePath,
        cancelToken: cancelToken, // Pass the cancel token
        onReceiveProgress: (received, total) {
          if (total != -1) {
            final percent = ((received / total) * 100).toInt();

            // Update local state
            final updatedState = downloadState.copyWith(
              progressPercent: percent,
              status: DownloadStatus.downloading,
              downloadId: downloadId,
            );
            _localDownloadStates[trackId] = updatedState;

            // Update global service
            _downloadService.addOrUpdateDownload(updatedState);
          }
        },
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
          followRedirects: true,
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      // Download completed successfully
      final completedState = downloadState.copyWith(
        status: DownloadStatus.completed,
        progressPercent: 100,
        downloadId: downloadId,
      );
      _localDownloadStates[trackId] = completedState;
      _downloadService.addOrUpdateDownload(completedState);
      _downloadService.markAsCompleted(trackId);

      // Update download status on backend ONLY if not cancelled
      if (downloadId != null && !cancelToken.isCancelled) {
        await _updateDownloadStatusOnBackend(downloadId);
      }

      Get.snackbar(
        'Download Complete',
        '${track.title} saved for offline listening.',
        backgroundColor: Colors.green,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );

    } catch (e) {
      // Check if error was due to cancellation
      if (e is DioException && e.type == DioExceptionType.cancel) {
        debugPrint('Download cancelled by user');
        // Don't show error snackbar for cancellation
        final cancelledState = downloadState.copyWith(
          status: DownloadStatus.cancelled,
          errorMessage: 'Download cancelled',
        );
        _localDownloadStates[trackId] = cancelledState;
        _downloadService.addOrUpdateDownload(cancelledState);

        // Remove from active after delay
        Future.delayed(const Duration(milliseconds: 500), () {
          _downloadService.removeFromActive(trackId);
          _localDownloadStates.remove(trackId);
        });
      } else {
        debugPrint('❌ Download error: $e');

        final failedState = downloadState.copyWith(
          status: DownloadStatus.failed,
          errorMessage: e.toString(),
        );
        _localDownloadStates[trackId] = failedState;
        _downloadService.addOrUpdateDownload(failedState);

        Get.snackbar(
          'Download Failed',
          'Could not download ${track.title}. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 4),
        );
      }
    }
  }

  // Build download button with dynamic state
  Widget _buildDownloadButton(String trackId, TrackModel track) {
    return Obx(() {
      // Check if already downloaded locally first
      final isDownloadedLocally = _localDownloadStates[trackId]?.status == DownloadStatus.completed ||
          _localDownloadStates[trackId]?.status == DownloadStatus.alreadyDownloaded;

      // Check global service state
      final globalState = _downloadService.getDownloadState(trackId);
      final state = _localDownloadStates[trackId] ?? globalState;

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
          return SizedBox(
            width: 40,
            height: 40,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: state.progressPercent / 100,
                  strokeWidth: 2.5,
                  color: const Color(0xff6366F1),
                  backgroundColor: Colors.white24,
                ),
                Text(
                  '${state.progressPercent}%',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                ),
              ],
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
            tooltip: 'Download for offline',
            constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          );
      }
    });
  }

  IconData _getPlaybackIcon() {
    switch (_playerController.playbackMode.value) {
      case PlaybackMode.shuffle:
        return Icons.shuffle_rounded;
      case PlaybackMode.repeatOne:
        return Icons.repeat_one_rounded;
      case PlaybackMode.continuous:
      default:
        return Icons.repeat_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      appBar: AppBar(
        backgroundColor: const Color(0xff020617),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final track = _playerController.currentTrack.value;
        if (track == null) {
          return const Center(child: Text("No track selected", style: TextStyle(color: Colors.white)));
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                /// Album Art
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

                /// Title + icons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            track.title ?? 'Unknown Track',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            track.categoryName ?? '',
                            style: const TextStyle(
                              color: Color(0xff94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Favorite Button
                    Obx(() => IconButton(
                      icon: Icon(
                        isFavorite.value ? Icons.favorite : Icons.favorite_border,
                        color: isFavorite.value ? const Color(0xFF7B61FF) : AppColors.lightGreyColor,
                      ),
                      onPressed: () async {
                        final currentTrack = _playerController.currentTrack.value;
                        if (currentTrack == null) return;

                        final token = await SecureStorageService.instance.getAccessToken();
                        if (token == null) {
                          Get.snackbar(
                            'Error',
                            'Please login again.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                          return;
                        }

                        final response = await NetworkCallerDio().postRequest(
                          AppUrl.addFavorites(currentTrack.id ?? ''),
                          body: {},
                          headers: {'Authorization': 'Bearer $token'},
                        );

                        if (response.isSuccess) {
                          isFavorite.value = true;
                          Get.snackbar(
                            'Added to Favorites',
                            '${currentTrack.title} added to your favorites.',
                            backgroundColor: const Color(0xFF7B61FF),
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                            duration: const Duration(seconds: 2),
                          );
                        } else {
                          Get.snackbar(
                            'Failed',
                            response.errorMessage ?? 'Could not add to favorites.',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.TOP,
                          );
                        }
                      },
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    )),

                    // Download Button
                    _buildDownloadButton(track.id ?? '', track),
                  ],
                ),

                const SizedBox(height: 30),

                /// Progress bar
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
                    value: _playerController.position.value.inSeconds.toDouble()
                        .clamp(0, _playerController.duration.value.inSeconds.toDouble()),
                    max: _playerController.duration.value.inSeconds.toDouble() > 0
                        ? _playerController.duration.value.inSeconds.toDouble()
                        : 100,
                    onChanged: (value) {
                      _playerController.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                /// Time labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_playerController.position.value),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_playerController.duration.value),
                      style: const TextStyle(color: Color(0xff94A3B8), fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Playback Mode Toggle
                    IconButton(
                      icon: Icon(
                        _getPlaybackIcon(),
                        color: _playerController.playbackMode.value == PlaybackMode.continuous
                            ? AppColors.lightGreyColor
                            : const Color(0xff6366F1),
                        size: 26,
                      ),
                      onPressed: _playerController.cyclePlaybackMode,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),

                    // Previous Button
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
                      onPressed: _playerController.playPrevious,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),

                    /// Play/Pause button
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: _playerController.isLoading.value
                          ? const Padding(
                        padding: EdgeInsets.all(20),
                        child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                      )
                          : IconButton(
                        icon: Icon(
                          _playerController.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          color: Colors.black,
                          size: 34,
                        ),
                        onPressed: _playerController.togglePlayPause,
                        padding: EdgeInsets.zero,
                      ),
                    ),

                    // Next Button
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
                      onPressed: _playerController.playNext,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),

                    // Sleep Timer Icon Button
                    IconButton(
                      icon: Icon(
                          Icons.timer_outlined,
                          color: selectedSleepTimer != "Off" ? const Color(0xff6366F1) : AppColors.lightGreyColor,
                          size: 26
                      ),
                      onPressed: _showSleepTimerSheet,
                      constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                    ),
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