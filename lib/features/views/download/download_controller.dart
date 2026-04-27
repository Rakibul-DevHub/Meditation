/**
// download_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
              .where((track) => track.status == 'COMPLETED') // Only show completed downloads
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









// download_controller.dart
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
}