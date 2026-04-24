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

  var tracks       = <FavoriteTrack>[].obs;
  var isLoading    = false.obs;
  var errorMessage = RxString('');
  var pagination   = Rx<PaginationMeta?>(null);

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
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();

      debugPrint('🔑 Token: ${token != null ? "EXISTS (${token.length} chars)" : "NULL"}');

      if (token == null) {
        errorMessage.value = 'No access token found. Please login again.';
        isLoading.value = false;
        return;
      }

      final url = '${AppUrl.getFavorites}?page=$_currentPage&limit=$_limit';
      debugPrint('📤 GET Favorites: $url');

      final NetworkResponseDio response = await _networkCaller.getRequest(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Status : ${response.statusCode}');
      debugPrint('📡 Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final data = response.jsonResponse!['data'];

        if (data != null) {
          final rawTracks = data['tracks'] as List<dynamic>? ?? [];
          final parsed = rawTracks
              .map((t) => FavoriteTrack.fromJson(Map<String, dynamic>.from(t)))
              .toList();

          if (refresh || _currentPage == 1) {
            tracks.assignAll(parsed);
          } else {
            tracks.addAll(parsed);
          }

          if (data['pagination'] != null) {
            pagination.value = PaginationMeta.fromJson(
              Map<String, dynamic>.from(data['pagination']),
            );
          }

          debugPrint('✅ Fetched ${parsed.length} favorites '
              '(total: ${pagination.value?.total ?? 0})');
        } else {
          errorMessage.value = 'No data found.';
        }
      } else {
        errorMessage.value =
            response.errorMessage ?? 'Failed to load favorites.';
        debugPrint('❌ Error: ${response.errorMessage}');
      }
    } catch (e) {
      errorMessage.value = 'An error occurred. Please try again.';
      debugPrint('❌ fetchFavorites exception: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadNextPage() async {
    final meta = pagination.value;
    if (meta == null || _currentPage >= meta.totalPages) return;
    if (isLoading.value) return;
    _currentPage++;
    await fetchFavorites();
  }

  void removeFromFavorites(String trackId) {
    tracks.removeWhere((t) => t.id == trackId);
    debugPrint('🗑️ Removed track $trackId from favorites list');
  }

  Future<void> refresh() => fetchFavorites(refresh: true);
}*/











///
///
///
/// todo::adding hte remove functioanlity
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
}