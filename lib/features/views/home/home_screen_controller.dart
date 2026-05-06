/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../model/category_model.dart';

class HomeScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Data states
  final RxList<TrackModel> featuredTracks = <TrackModel>[].obs;
  final RxList<TrackModel> sleepTonightTracks = <TrackModel>[].obs;
  final RxList<TrackModel> popularTracks = <TrackModel>[].obs;

  // Loading states
  final RxBool isLoadingFeatured = false.obs;
  final RxBool isLoadingSleep = false.obs;
  final RxBool isLoadingPopular = false.obs;

  // Refresh states (to show shimmer during pull-to-refresh)
  final RxBool isRefreshingFeatured = false.obs;
  final RxBool isRefreshingSleep = false.obs;
  final RxBool isRefreshingPopular = false.obs;

  // Error states
  final RxString featuredError = ''.obs;
  final RxString sleepError = ''.obs;
  final RxString popularError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchFeaturedSounds(),
      fetchSleepTonight(),
      fetchPopularSounds(),
    ]);
  }

  // Fetch Featured Sounds
  Future<void> fetchFeaturedSounds({bool showLoading = true, bool isRefresh = false}) async {
    if (showLoading && featuredTracks.isEmpty) {
      isLoadingFeatured.value = true;
      featuredError.value = '';
    }

    if (isRefresh) {
      isRefreshingFeatured.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _networkCaller.getRequest(
        AppUrl.featuredSounds,
        headers: headers,
      );

      debugPrint('📡 Featured Response Status: ${response.statusCode}');
      debugPrint('📡 Featured Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];
        if (data != null && data['results'] != null) {
          final tracks = (data['results'] as List)
              .map((e) => TrackModel.fromJson(e))
              .where((track) => track.isFeatured == true)
              .toList();
          featuredTracks.assignAll(tracks);
          featuredError.value = '';
          debugPrint('✅ Loaded ${featuredTracks.length} featured tracks');
        } else {
          featuredTracks.clear();
        }
      } else {
        if (featuredTracks.isEmpty) {
          featuredError.value = response.errorMessage ?? 'Failed to load featured sounds';
        }
        debugPrint('❌ Featured Error: ${response.errorMessage}');
      }
    } catch (e) {
      if (featuredTracks.isEmpty) {
        featuredError.value = 'An unexpected error occurred';
      }
      debugPrint('❌ Error fetching featured: $e');
    } finally {
      if (showLoading) isLoadingFeatured.value = false;
      if (isRefresh) isRefreshingFeatured.value = false;
    }
  }

  // Fetch Sleep Tonight Tracks
  Future<void> fetchSleepTonight({bool showLoading = true, bool isRefresh = false}) async {
    if (showLoading && sleepTonightTracks.isEmpty) {
      isLoadingSleep.value = true;
      sleepError.value = '';
    }

    if (isRefresh) {
      isRefreshingSleep.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _networkCaller.getRequest(
        AppUrl.sleepTonight,
        headers: headers,
      );

      debugPrint('📡 Sleep Response Status: ${response.statusCode}');
      debugPrint('📡 Sleep Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];
        if (data != null && data['results'] != null) {
          final tracks = (data['results'] as List)
              .map((e) => TrackModel.fromJson(e))
              .where((track) => track.isSleepTonight == true)
              .toList();
          sleepTonightTracks.assignAll(tracks);
          sleepError.value = '';
          debugPrint('✅ Loaded ${sleepTonightTracks.length} sleep tonight tracks');
        } else {
          sleepTonightTracks.clear();
        }
      } else {
        if (sleepTonightTracks.isEmpty) {
          sleepError.value = response.errorMessage ?? 'Failed to load sleep sounds';
        }
        debugPrint('❌ Sleep Error: ${response.errorMessage}');
      }
    } catch (e) {
      if (sleepTonightTracks.isEmpty) {
        sleepError.value = 'An unexpected error occurred';
      }
      debugPrint('❌ Error fetching sleep tracks: $e');
    } finally {
      if (showLoading) isLoadingSleep.value = false;
      if (isRefresh) isRefreshingSleep.value = false;
    }
  }

  // Fetch Popular Sounds - Using the specific popular endpoint
  Future<void> fetchPopularSounds({bool showLoading = true, bool isRefresh = false}) async {
    if (showLoading && popularTracks.isEmpty) {
      isLoadingPopular.value = true;
      popularError.value = '';
    }

    if (isRefresh) {
      isRefreshingPopular.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _networkCaller.getRequest(
        AppUrl.popularListening,
        headers: headers,
      );

      debugPrint('📡 Popular Response Status: ${response.statusCode}');
      debugPrint('📡 Popular Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // The API returns data as an array directly
        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          final tracks = (jsonResponse['data'] as List)
              .map((e) => TrackModel.fromJson(e))
              .toList();
          popularTracks.assignAll(tracks);
          popularError.value = '';
          debugPrint('✅ Loaded ${popularTracks.length} popular tracks');
        } else {
          popularTracks.clear();
          debugPrint('⚠️ No popular tracks found in response');
        }
      } else {
        if (popularTracks.isEmpty) {
          popularError.value = response.errorMessage ?? 'Failed to load popular sounds';
        }
        debugPrint('❌ Popular Error: ${response.errorMessage}');
      }
    } catch (e) {
      if (popularTracks.isEmpty) {
        popularError.value = 'An unexpected error occurred';
      }
      debugPrint('❌ Error fetching popular tracks: $e');
    } finally {
      if (showLoading) isLoadingPopular.value = false;
      if (isRefresh) isRefreshingPopular.value = false;
    }
  }

  // Refresh all data with shimmer effect
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchFeaturedSounds(showLoading: false, isRefresh: true),
      fetchSleepTonight(showLoading: false, isRefresh: true),
      fetchPopularSounds(showLoading: false, isRefresh: true),
    ]);
  }

  // Format duration from seconds to readable string
  String formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '0:00';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get category name
  String getCategoryName(TrackModel track) {
    return track.categoryName ?? 'Music';
  }
}*/









///
///
///
///todo:: updating for popular fav
///
///
///










import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../model/category_model.dart';

class HomeScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Data states
  final RxList<TrackModel> featuredTracks = <TrackModel>[].obs;
  final RxList<TrackModel> sleepTonightTracks = <TrackModel>[].obs;
  final RxList<TrackModel> popularTracks = <TrackModel>[].obs;

  // Loading states
  final RxBool isLoadingFeatured = false.obs;
  final RxBool isLoadingSleep = false.obs;
  final RxBool isLoadingPopular = false.obs;

  // Refresh states (to show shimmer during pull-to-refresh)
  final RxBool isRefreshingFeatured = false.obs;
  final RxBool isRefreshingSleep = false.obs;
  final RxBool isRefreshingPopular = false.obs;

  // Error states
  final RxString featuredError = ''.obs;
  final RxString sleepError = ''.obs;
  final RxString popularError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAllData();
  }

  Future<void> fetchAllData() async {
    await Future.wait([
      fetchFeaturedSounds(),
      fetchSleepTonight(),
      fetchPopularSounds(),
    ]);
  }

  // Fetch Featured Sounds
  Future<void> fetchFeaturedSounds({bool showLoading = true, bool isRefresh = false}) async {
    if (showLoading && featuredTracks.isEmpty) {
      isLoadingFeatured.value = true;
      featuredError.value = '';
    }

    if (isRefresh) {
      isRefreshingFeatured.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _networkCaller.getRequest(
        AppUrl.featuredSounds,
        headers: headers,
      );

      debugPrint('📡 Featured Response Status: ${response.statusCode}');
      debugPrint('📡 Featured Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];
        if (data != null && data['results'] != null) {
          final tracks = (data['results'] as List)
              .map((e) => TrackModel.fromJson(e))
              .where((track) => track.isFeatured == true)
              .toList();
          featuredTracks.assignAll(tracks);
          featuredError.value = '';
          debugPrint('✅ Loaded ${featuredTracks.length} featured tracks');
        } else {
          featuredTracks.clear();
        }
      } else {
        if (featuredTracks.isEmpty) {
          featuredError.value = response.errorMessage ?? 'Failed to load featured sounds';
        }
        debugPrint('❌ Featured Error: ${response.errorMessage}');
      }
    } catch (e) {
      if (featuredTracks.isEmpty) {
        featuredError.value = 'An unexpected error occurred';
      }
      debugPrint('❌ Error fetching featured: $e');
    } finally {
      if (showLoading) isLoadingFeatured.value = false;
      if (isRefresh) isRefreshingFeatured.value = false;
    }
  }

  // Fetch Sleep Tonight Tracks
  Future<void> fetchSleepTonight({bool showLoading = true, bool isRefresh = false}) async {
    if (showLoading && sleepTonightTracks.isEmpty) {
      isLoadingSleep.value = true;
      sleepError.value = '';
    }

    if (isRefresh) {
      isRefreshingSleep.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _networkCaller.getRequest(
        AppUrl.sleepTonight,
        headers: headers,
      );

      debugPrint('📡 Sleep Response Status: ${response.statusCode}');
      debugPrint('📡 Sleep Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];
        if (data != null && data['results'] != null) {
          final tracks = (data['results'] as List)
              .map((e) => TrackModel.fromJson(e))
              .where((track) => track.isSleepTonight == true)
              .toList();
          sleepTonightTracks.assignAll(tracks);
          sleepError.value = '';
          debugPrint('✅ Loaded ${sleepTonightTracks.length} sleep tonight tracks');
        } else {
          sleepTonightTracks.clear();
        }
      } else {
        if (sleepTonightTracks.isEmpty) {
          sleepError.value = response.errorMessage ?? 'Failed to load sleep sounds';
        }
        debugPrint('❌ Sleep Error: ${response.errorMessage}');
      }
    } catch (e) {
      if (sleepTonightTracks.isEmpty) {
        sleepError.value = 'An unexpected error occurred';
      }
      debugPrint('❌ Error fetching sleep tracks: $e');
    } finally {
      if (showLoading) isLoadingSleep.value = false;
      if (isRefresh) isRefreshingSleep.value = false;
    }
  }

  // Fetch Popular Sounds - Using the specific popular endpoint
  Future<void> fetchPopularSounds({bool showLoading = true, bool isRefresh = false}) async {
    if (showLoading && popularTracks.isEmpty) {
      isLoadingPopular.value = true;
      popularError.value = '';
    }

    if (isRefresh) {
      isRefreshingPopular.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _networkCaller.getRequest(
        AppUrl.popularListening,
        headers: headers,
      );

      debugPrint('📡 Popular Response Status: ${response.statusCode}');
      debugPrint('📡 Popular Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
          final tracks = (jsonResponse['data'] as List)
              .map((e) => TrackModel.fromJson(e))
              .toList();
          popularTracks.assignAll(tracks);
          popularError.value = '';
          debugPrint('✅ Loaded ${popularTracks.length} popular tracks');
        } else {
          popularTracks.clear();
          debugPrint('⚠️ No popular tracks found in response');
        }
      } else {
        if (popularTracks.isEmpty) {
          popularError.value = response.errorMessage ?? 'Failed to load popular sounds';
        }
        debugPrint('❌ Popular Error: ${response.errorMessage}');
      }
    } catch (e) {
      if (popularTracks.isEmpty) {
        popularError.value = 'An unexpected error occurred';
      }
      debugPrint('❌ Error fetching popular tracks: $e');
    } finally {
      if (showLoading) isLoadingPopular.value = false;
      if (isRefresh) isRefreshingPopular.value = false;
    }
  }

  // Refresh all data with shimmer effect
  Future<void> refreshAllData() async {
    await Future.wait([
      fetchFeaturedSounds(showLoading: false, isRefresh: true),
      fetchSleepTonight(showLoading: false, isRefresh: true),
      fetchPopularSounds(showLoading: false, isRefresh: true),
    ]);
  }

  // Format duration from seconds to readable string
  String formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return '0:00';
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get category name
  String getCategoryName(TrackModel track) {
    return track.categoryName ?? 'Music';
  }
}