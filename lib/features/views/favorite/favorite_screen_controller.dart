/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/core/network/network_caller_dio.dart';
import 'package:outdoor_therapy/core/network/network_response_dio.dart';
import 'package:outdoor_therapy/core/network/secure_storage_service.dart';
import '../../../core/network/app_url.dart';
import '../../../model/favorite_response_model.dart';

class FavoriteScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var tracks = <FavoriteTrack>[].obs;
  var isLoading = false.obs;
  var errorMessage = RxString('');
  var pagination = Rx<PaginationMeta?>(null);

  int _currentPage = 1;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      tracks.clear();
      errorMessage.value = '';
    }

    isLoading.value = true;

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        errorMessage.value = 'Please login to view favorites';
        isLoading.value = false;
        return;
      }

      debugPrint('🔑 Fetching favorites with token');

      final response = await _networkCaller.getRequest(
        '${AppUrl.getFavorite}?page=$_currentPage&limit=$_limit',
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response success: ${response.isSuccess}');
      debugPrint('📡 Response body: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // Check if data exists
        if (jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          // Parse tracks
          if (data['tracks'] != null && data['tracks'] is List) {
            final parsedTracks = (data['tracks'] as List)
                .map((e) => FavoriteTrack.fromJson(e))
                .toList();

            debugPrint('✅ Parsed ${parsedTracks.length} tracks');

            if (_currentPage == 1) {
              tracks.assignAll(parsedTracks);
            } else {
              tracks.addAll(parsedTracks);
            }
          } else {
            debugPrint('⚠️ No tracks found in response');
            if (_currentPage == 1) {
              tracks.clear();
            }
          }

          // Parse pagination
          if (data['pagination'] != null) {
            pagination.value = PaginationMeta.fromJson(data['pagination']);
            debugPrint('📄 Pagination: total=${pagination.value?.total}, page=${pagination.value?.page}');
          }
        } else {
          debugPrint('⚠️ No data field in response');
          if (_currentPage == 1) {
            tracks.clear();
          }
        }

        errorMessage.value = '';
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load favorites';
        debugPrint('❌ Error: ${response.errorMessage}');
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      errorMessage.value = 'An unexpected error occurred';
    } finally {
      isLoading.value = false;
    }
  }

  /// Remove from favorites (toggle endpoint)
  Future<void> removeFromFavoritesApi(String trackId) async {
    final token = await SecureStorageService.instance.getAccessToken();
    if (token == null) return;

    final response = await _networkCaller.postRequest(
      AppUrl.addFavorites(trackId),
      body: {},
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.isSuccess) {
      tracks.removeWhere((t) => t.id == trackId);
      Get.snackbar(
        'Removed',
        'Track removed from favorites',
        backgroundColor: const Color(0xFF7B61FF),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadNextPage() async {
    if (pagination.value == null ||
        _currentPage >= pagination.value!.totalPages) return;

    _currentPage++;
    await fetchFavorites();
  }

  Future<void> refresh() => fetchFavorites(refresh: true);
}*/




///
///
///
/// todo:: fetching data with refresh
///
///



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/core/network/network_caller_dio.dart';
import 'package:outdoor_therapy/core/network/network_response_dio.dart';
import 'package:outdoor_therapy/core/network/secure_storage_service.dart';
import '../../../core/network/app_url.dart';
import '../../../model/favorite_response_model.dart';

class FavoriteScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  var tracks = <FavoriteTrack>[].obs;
  var isLoading = false.obs;
  var isRefreshing = false.obs;
  var errorMessage = RxString('');
  var pagination = Rx<PaginationMeta?>(null);

  int _currentPage = 1;
  final int _limit = 10;

  @override
  void onInit() {
    super.onInit();
    fetchFavorites();
  }

  Future<void> fetchFavorites({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
      _currentPage = 1;
      tracks.clear();
      errorMessage.value = '';
    } else if (tracks.isEmpty) {
      isLoading.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        errorMessage.value = 'Please login to view favorites';
        if (refresh) isRefreshing.value = false;
        isLoading.value = false;
        return;
      }

      debugPrint('🔑 Fetching favorites with token');

      final response = await _networkCaller.getRequest(
        '${AppUrl.getFavorite}?page=$_currentPage&limit=$_limit',
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        if (jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          if (data['tracks'] != null && data['tracks'] is List) {
            final parsedTracks = (data['tracks'] as List)
                .map((e) => FavoriteTrack.fromJson(e))
                .toList();

            debugPrint('✅ Parsed ${parsedTracks.length} tracks');

            if (_currentPage == 1) {
              tracks.assignAll(parsedTracks);
            } else {
              tracks.addAll(parsedTracks);
            }
          } else {
            debugPrint('⚠️ No tracks found in response');
            if (_currentPage == 1) {
              tracks.clear();
            }
          }

          if (data['pagination'] != null) {
            pagination.value = PaginationMeta.fromJson(data['pagination']);
            debugPrint('📄 Pagination: total=${pagination.value?.total}, page=${pagination.value?.page}');
          }
        } else {
          debugPrint('⚠️ No data field in response');
          if (_currentPage == 1) {
            tracks.clear();
          }
        }

        errorMessage.value = '';
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load favorites';
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

  /// Remove from favorites using POST method
  Future<void> removeFromFavoritesApi(String trackId) async {
    if (trackId.isEmpty) {
      debugPrint('❌ Invalid track ID');
      return;
    }

    final token = await SecureStorageService.instance.getAccessToken();
    if (token == null) {
      Get.snackbar(
        'Error',
        'Please login to remove favorites',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Store the track for feedback before removing
    final removedTrack = tracks.firstWhereOrNull((t) => t.id == trackId);

    // Optimistically remove from UI for better UX
    tracks.removeWhere((t) => t.id == trackId);

    debugPrint('🗑️ Removing track from favorites (POST): $trackId');
    debugPrint('🌐 POST URL: ${AppUrl.removeFavorites(trackId)}');

    try {
      final response = await _networkCaller.postRequest(
        AppUrl.removeFavorites(trackId),
        body: {},
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Remove Response Status: ${response.statusCode}');
      debugPrint('📡 Remove Response Success: ${response.isSuccess}');
      debugPrint('📡 Remove Response Body: ${response.jsonResponse}');

      if (response.isSuccess) {
        debugPrint('✅ Track removed successfully. Remaining: ${tracks.length}');

        Get.snackbar(
          'Removed',
          '${removedTrack?.title ?? 'Track'} removed from favorites',
          backgroundColor: const Color(0xFF7B61FF),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 2),
        );
      } else {
        // If removal failed, add the track back
        if (removedTrack != null && !tracks.any((t) => t.id == trackId)) {
          tracks.add(removedTrack);
        }

        String errorMsg = response.errorMessage ?? 'Failed to remove from favorites';

        Get.snackbar(
          'Failed',
          errorMsg,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );
        debugPrint('❌ Remove Error: ${response.errorMessage}');
      }
    } catch (e) {
      // If request failed, add the track back
      if (removedTrack != null && !tracks.any((t) => t.id == trackId)) {
        tracks.add(removedTrack);
      }

      debugPrint('❌ Exception removing favorite: $e');
      Get.snackbar(
        'Error',
        'Network error. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> loadNextPage() async {
    if (pagination.value == null ||
        _currentPage >= pagination.value!.totalPages) return;
    if (isLoading.value) return;

    _currentPage++;
    await fetchFavorites();
  }

  Future<void> refresh() async {
    await fetchFavorites(refresh: true);
  }
}