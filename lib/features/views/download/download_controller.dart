/**
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/network_response_dio.dart';
import '../../../core/network/secure_storage_service.dart';

// Download item model from API
class DownloadedTrack {
  final String id;
  final String trackId;
  final String title;
  final String? description;
  final String coverImageUrl;
  final int durationSeconds;
  final String status;
  final int progressPercent;
  final String categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;

  DownloadedTrack({
    required this.id,
    required this.trackId,
    required this.title,
    this.description,
    required this.coverImageUrl,
    required this.durationSeconds,
    required this.status,
    required this.progressPercent,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DownloadedTrack.fromJson(Map<String, dynamic> json) {
    final track = json['track'] ?? {};
    final category = track['category'] ?? {};

    return DownloadedTrack(
      id: json['id']?.toString() ?? '',
      trackId: track['id']?.toString() ?? '',
      title: track['title']?.toString() ?? 'Unknown Track',
      description: track['description']?.toString(),
      coverImageUrl: track['coverImageUrl']?.toString() ?? '',
      durationSeconds: track['durationSeconds'] as int? ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      progressPercent: json['progressPercent'] as int? ?? 0,
      categoryName: category['name']?.toString() ?? 'Unknown',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  // Get local file path for the downloaded track
  Future<String?> getLocalFilePath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/tracks/$trackId.mp3';
      final file = File(filePath);
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting local file path: $e');
      return null;
    }
  }
}

class DownloadController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  final RxList<DownloadedTrack> downloadedTracks = <DownloadedTrack>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isRefreshing = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchDownloadedTracks();
  }

  Future<void> fetchDownloadedTracks({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
      downloadedTracks.clear();
      errorMessage.value = '';
    } else if (downloadedTracks.isEmpty) {
      isLoading.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        errorMessage.value = 'Please login to view downloads';
        isLoading.value = false;
        isRefreshing.value = false;
        return;
      }

      debugPrint('🔑 Fetching downloaded tracks...');
      debugPrint('🌐 GET: ${AppUrl.downloadedSoundsList}');

      final response = await _networkCaller.getRequest(
        AppUrl.downloadedSoundsList,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          final tracks = (jsonResponse['data'] as List)
              .map((e) => DownloadedTrack.fromJson(e))
              .where((track) => track.status == 'COMPLETED')
              .toList();

          downloadedTracks.assignAll(tracks);
          errorMessage.value = '';
          debugPrint('✅ Loaded ${downloadedTracks.length} downloaded tracks');
        } else {
          downloadedTracks.clear();
          debugPrint('⚠️ No downloads found');
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load downloads';
        debugPrint('❌ Error: ${response.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      if (refresh) {
        isRefreshing.value = false;
      } else {
        isLoading.value = false;
      }
    }
  }

  // Delete downloaded track (from server and local)
  Future<void> deleteDownload(String downloadId, String trackId) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) return;

      // Delete from server
      final response = await _networkCaller.deleteRequest(
        AppUrl.deleteDownloadSounds(downloadId),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess) {
        // Delete local file if exists
        final dir = await getApplicationDocumentsDirectory();
        final filePath = '${dir.path}/tracks/$trackId.mp3';
        final file = File(filePath);
        if (await file.exists()) {
          await file.delete();
          debugPrint('🗑️ Local file deleted: $filePath');
        }

        // Remove from local list
        downloadedTracks.removeWhere((t) => t.id == downloadId);

        Get.snackbar(
          'Deleted',
          'Track removed from downloads',
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Failed',
          response.errorMessage ?? 'Could not delete download',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      debugPrint('❌ Error deleting download: $e');
      Get.snackbar(
        'Error',
        'Failed to delete download',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> refresh() async {
    await fetchDownloadedTracks(refresh: true);
  }
}*/








import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/secure_storage_service.dart';

// ─── Model ───────────────────────────────────────────────────────────────────

class DownloadedTrack {
  final String id;
  final String trackId;
  final String title;
  final String? description;
  final String coverImageUrl;
  final int durationSeconds;
  final String status;
  final int progressPercent;
  final String categoryName;
  final DateTime createdAt;
  final DateTime updatedAt;

  DownloadedTrack({
    required this.id,
    required this.trackId,
    required this.title,
    this.description,
    required this.coverImageUrl,
    required this.durationSeconds,
    required this.status,
    required this.progressPercent,
    required this.categoryName,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── From API JSON ──
  factory DownloadedTrack.fromJson(Map<String, dynamic> json) {
    final track = json['track'] as Map<String, dynamic>? ?? {};
    final category = track['category'] as Map<String, dynamic>? ?? {};

    return DownloadedTrack(
      id: json['id']?.toString() ?? '',
      trackId: track['id']?.toString() ?? '',
      title: track['title']?.toString() ?? 'Unknown Track',
      description: track['description']?.toString(),
      coverImageUrl: track['coverImageUrl']?.toString() ?? '',
      durationSeconds: track['durationSeconds'] as int? ?? 0,
      status: json['status']?.toString() ?? 'PENDING',
      progressPercent: json['progressPercent'] as int? ?? 0,
      categoryName: category['name']?.toString() ?? 'Unknown',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  // ── Serialise/deserialise for local SharedPreferences cache ──
  Map<String, dynamic> toMap() => {
    'id': id,
    'trackId': trackId,
    'title': title,
    'description': description,
    'coverImageUrl': coverImageUrl,
    'durationSeconds': durationSeconds,
    'status': status,
    'progressPercent': progressPercent,
    'categoryName': categoryName,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
  };

  factory DownloadedTrack.fromMap(Map<String, dynamic> map) => DownloadedTrack(
    id: map['id']?.toString() ?? '',
    trackId: map['trackId']?.toString() ?? '',
    title: map['title']?.toString() ?? 'Unknown Track',
    description: map['description']?.toString(),
    coverImageUrl: map['coverImageUrl']?.toString() ?? '',
    durationSeconds: map['durationSeconds'] as int? ?? 0,
    status: map['status']?.toString() ?? 'COMPLETED',
    progressPercent: map['progressPercent'] as int? ?? 100,
    categoryName: map['categoryName']?.toString() ?? 'Unknown',
    createdAt: DateTime.tryParse(map['createdAt']?.toString() ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(map['updatedAt']?.toString() ?? '') ?? DateTime.now(),
  );

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Returns the local .mp3 path if the file actually exists on disk.
  Future<String?> getLocalFilePath() async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final filePath = '${dir.path}/tracks/$trackId.mp3';
      final file = File(filePath);
      if (await file.exists() && (await file.stat()).size > 1024) {
        return filePath;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting local file path: $e');
      return null;
    }
  }
}

// ─── Controller ──────────────────────────────────────────────────────────────

class DownloadController extends GetxController {
  static const String _cacheKey = 'downloaded_tracks_cache';

  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  final RxList<DownloadedTrack> downloadedTracks = <DownloadedTrack>[].obs;
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxBool isRefreshing = false.obs;
  final RxBool isOffline = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Always load cache first so offline users see their tracks immediately,
    // then try to sync with the server in the background.
    _loadFromCacheThenSync();
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  Future<void> refresh() async => _fetchFromServer(isRefresh: true);

  /// Called by NowPlayingScreen / download flow after a successful download
  /// so the track appears in the list immediately without a server round-trip.
  Future<void> saveTrackToCache(DownloadedTrack track) async {
    // Add/update in the live list
    final idx = downloadedTracks.indexWhere((t) => t.trackId == track.trackId);
    if (idx >= 0) {
      downloadedTracks[idx] = track;
    } else {
      downloadedTracks.insert(0, track);
    }
    await _persistCache(downloadedTracks);
  }

  /// Remove a download from server + local file + cache.
  Future<void> deleteDownload(String downloadId, String trackId) async {
    try {
      final token = await SecureStorageService.instance.getAccessToken();

      // Try server delete (best-effort — works only online)
      if (token != null) {
        final response = await _networkCaller.deleteRequest(
          AppUrl.deleteDownloadSounds(downloadId),
          headers: {'Authorization': 'Bearer $token'},
        );
        if (!response.isSuccess) {
          debugPrint('⚠️ Server delete failed: ${response.errorMessage}');
        }
      }

      // Always delete local file
      await _deleteLocalFile(trackId);

      // Remove from in-memory list + cache
      downloadedTracks.removeWhere((t) => t.id == downloadId);
      await _persistCache(downloadedTracks);

      Get.snackbar(
        'Deleted',
        'Track removed from downloads',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      debugPrint('❌ Error deleting download: $e');
      Get.snackbar(
        'Error',
        'Failed to delete download',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // ── Private helpers ────────────────────────────────────────────────────────

  /// Step 1: Load cached metadata immediately so the UI shows something.
  /// Step 2: Validate each cached entry still has its file on disk.
  /// Step 3: Try to sync with server (silently, so offline users don't see an error).
  Future<void> _loadFromCacheThenSync() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      // 1 — Load from SharedPreferences
      final cached = await _loadCache();
      debugPrint('📦 Loaded ${cached.length} tracks from local cache');

      // 2 — Cross-check each cached entry against disk
      final verified = await _filterToExistingFiles(cached);
      debugPrint('✅ ${verified.length} tracks have files on disk');

      if (verified.isNotEmpty) {
        downloadedTracks.assignAll(verified);
        // Persist pruned list (removes stale entries)
        if (verified.length != cached.length) {
          await _persistCache(verified);
        }
      }
    } catch (e) {
      debugPrint('❌ Cache load error: $e');
    } finally {
      isLoading.value = false;
    }

    // 3 — Background sync (doesn't block UI or show error if offline)
    _fetchFromServer(isRefresh: false, silent: true);
  }

  /// Fetch completed downloads from the server.
  /// [silent] = true → errors don't update [errorMessage] (used for background sync).
  Future<void> _fetchFromServer({bool isRefresh = false, bool silent = false}) async {
    if (isRefresh) {
      isRefreshing.value = true;
      errorMessage.value = '';
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        if (!silent) errorMessage.value = 'Please login to view downloads';
        return;
      }

      debugPrint('🌐 Syncing downloads from server…');
      final response = await _networkCaller.getRequest(
        AppUrl.downloadedSoundsList,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse?['data'] is List) {
        final serverTracks = (response.jsonResponse!['data'] as List)
            .map((e) => DownloadedTrack.fromJson(e as Map<String, dynamic>))
            .where((t) => t.status == 'COMPLETED')
            .toList();

        debugPrint('☁️  Server returned ${serverTracks.length} completed tracks');

        // Merge: keep server list, but only include entries whose file is on disk.
        // This handles the case where the server knows about a download but the
        // user deleted the app's data, etc.
        final verified = await _filterToExistingFiles(serverTracks);

        // Also keep any locally-cached tracks not yet on the server
        // (e.g. downloaded but backend status not yet updated).
        final serverTrackIds = verified.map((t) => t.trackId).toSet();
        final localOnly = downloadedTracks
            .where((t) => !serverTrackIds.contains(t.trackId))
            .toList();
        final merged = [...verified, ...localOnly];

        downloadedTracks.assignAll(merged);
        await _persistCache(merged);
        isOffline.value = false;
        errorMessage.value = '';
        debugPrint('✅ Merged list: ${merged.length} tracks');
      } else {
        // Server call failed — keep whatever is already showing from cache
        isOffline.value = true;
        if (!silent && downloadedTracks.isEmpty) {
          errorMessage.value = response.errorMessage ?? 'Could not reach server';
        }
        debugPrint('⚠️ Server sync failed: ${response.errorMessage}');
      }
    } catch (e) {
      isOffline.value = true;
      if (!silent && downloadedTracks.isEmpty) {
        errorMessage.value = 'No internet connection';
      }
      debugPrint('❌ Server sync exception: $e');
    } finally {
      isRefreshing.value = false;
    }
  }

  /// Remove entries whose .mp3 file no longer exists on device storage.
  Future<List<DownloadedTrack>> _filterToExistingFiles(
      List<DownloadedTrack> tracks) async {
    final result = <DownloadedTrack>[];
    for (final track in tracks) {
      final path = await track.getLocalFilePath();
      if (path != null) result.add(track);
    }
    return result;
  }

  /// Persist track list to SharedPreferences as JSON.
  Future<void> _persistCache(List<DownloadedTrack> tracks) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = jsonEncode(tracks.map((t) => t.toMap()).toList());
      await prefs.setString(_cacheKey, json);
      debugPrint('💾 Cache saved: ${tracks.length} tracks');
    } catch (e) {
      debugPrint('❌ Failed to persist cache: $e');
    }
  }

  /// Load track list from SharedPreferences.
  Future<List<DownloadedTrack>> _loadCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>;
      return list
          .map((e) => DownloadedTrack.fromMap(e as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('❌ Failed to load cache: $e');
      return [];
    }
  }

  Future<void> _deleteLocalFile(String trackId) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/tracks/$trackId.mp3');
      if (await file.exists()) {
        await file.delete();
        debugPrint('🗑️ Deleted local file for trackId: $trackId');
      }
    } catch (e) {
      debugPrint('❌ Error deleting local file: $e');
    }
  }
}