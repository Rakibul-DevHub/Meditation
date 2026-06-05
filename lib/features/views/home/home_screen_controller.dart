// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../../../core/network/app_url.dart';
// import '../../../core/network/network_caller_dio.dart';
// import '../../../core/network/secure_storage_service.dart';
// import '../../../model/category_model.dart';
//
// class HomeScreenController extends GetxController {
//   final NetworkCallerDio _networkCaller = NetworkCallerDio();
//
//   // Data states
//   final RxList<TrackModel> featuredTracks = <TrackModel>[].obs;
//   final RxList<TrackModel> sleepTonightTracks = <TrackModel>[].obs;
//   final RxList<TrackModel> popularTracks = <TrackModel>[].obs;
//
//   // Loading states
//   final RxBool isLoadingFeatured = false.obs;
//   final RxBool isLoadingSleep = false.obs;
//   final RxBool isLoadingPopular = false.obs;
//   final RxBool isPaginatingPopular = false.obs;
//
//   // Pagination states
//   int _popularPage = 1;
//   final int _popularLimit = 10;
//   final RxBool hasMorePopular = true.obs;
//
//   // Refresh states (to show shimmer during pull-to-refresh)
//   final RxBool isRefreshingFeatured = false.obs;
//   final RxBool isRefreshingSleep = false.obs;
//   final RxBool isRefreshingPopular = false.obs;
//
//   // Error states
//   final RxString featuredError = ''.obs;
//   final RxString sleepError = ''.obs;
//   final RxString popularError = ''.obs;
//
//   @override
//   void onInit() {
//     super.onInit();
//     fetchAllData();
//   }
//
//   Future<void> fetchAllData() async {
//     await Future.wait([
//       fetchFeaturedSounds(),
//       fetchSleepTonight(),
//       fetchPopularSounds(),
//     ]);
//   }
//
//   // Fetch Featured Sounds
//   Future<void> fetchFeaturedSounds({bool showLoading = true, bool isRefresh = false}) async {
//     if (showLoading && featuredTracks.isEmpty) {
//       isLoadingFeatured.value = true;
//       featuredError.value = '';
//     }
//
//     if (isRefresh) {
//       isRefreshingFeatured.value = true;
//     }
//
//     try {
//       final token = await SecureStorageService.instance.getAccessToken();
//       final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
//
//       final response = await _networkCaller.getRequest(
//         AppUrl.featuredSounds,
//         headers: headers,
//       );
//
//       debugPrint('📡 Featured Response Status: ${response.statusCode}');
//       debugPrint('📡 Featured Response Success: ${response.isSuccess}');
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         final data = response.jsonResponse!['data'];
//         if (data != null && data['results'] != null) {
//           final tracks = (data['results'] as List)
//               .map((e) => TrackModel.fromJson(e))
//               .where((track) => track.isFeatured == true)
//               .toList();
//           featuredTracks.assignAll(tracks);
//           featuredError.value = '';
//           debugPrint('✅ Loaded ${featuredTracks.length} featured tracks');
//         } else {
//           featuredTracks.clear();
//         }
//       } else {
//         if (featuredTracks.isEmpty) {
//           featuredError.value = response.errorMessage ?? 'Failed to load featured sounds';
//         }
//         debugPrint('❌ Featured Error: ${response.errorMessage}');
//       }
//     } catch (e) {
//       if (featuredTracks.isEmpty) {
//         featuredError.value = 'An unexpected error occurred';
//       }
//       debugPrint('❌ Error fetching featured: $e');
//     } finally {
//       if (showLoading) isLoadingFeatured.value = false;
//       if (isRefresh) isRefreshingFeatured.value = false;
//     }
//   }
//
//   // Fetch Sleep Tonight Tracks
//   Future<void> fetchSleepTonight({bool showLoading = true, bool isRefresh = false}) async {
//     if (showLoading && sleepTonightTracks.isEmpty) {
//       isLoadingSleep.value = true;
//       sleepError.value = '';
//     }
//
//     if (isRefresh) {
//       isRefreshingSleep.value = true;
//     }
//
//     try {
//       final token = await SecureStorageService.instance.getAccessToken();
//       final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
//
//       final response = await _networkCaller.getRequest(
//         AppUrl.sleepTonight,
//         headers: headers,
//       );
//
//       debugPrint('📡 Sleep Response Status: ${response.statusCode}');
//       debugPrint('📡 Sleep Response Success: ${response.isSuccess}');
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         final data = response.jsonResponse!['data'];
//         if (data != null && data['results'] != null) {
//           final tracks = (data['results'] as List)
//               .map((e) => TrackModel.fromJson(e))
//               .where((track) => track.isSleepTonight == true)
//               .toList();
//           sleepTonightTracks.assignAll(tracks);
//           sleepError.value = '';
//           debugPrint('✅ Loaded ${sleepTonightTracks.length} sleep tonight tracks');
//         } else {
//           sleepTonightTracks.clear();
//         }
//       } else {
//         if (sleepTonightTracks.isEmpty) {
//           sleepError.value = response.errorMessage ?? 'Failed to load sleep sounds';
//         }
//         debugPrint('❌ Sleep Error: ${response.errorMessage}');
//       }
//     } catch (e) {
//       if (sleepTonightTracks.isEmpty) {
//         sleepError.value = 'An unexpected error occurred';
//       }
//       debugPrint('❌ Error fetching sleep tracks: $e');
//     } finally {
//       if (showLoading) isLoadingSleep.value = false;
//       if (isRefresh) isRefreshingSleep.value = false;
//     }
//   }
//
//   // Fetch Popular Sounds - Using the specific popular endpoint with pagination
//   Future<void> fetchPopularSounds({bool showLoading = true, bool isRefresh = false, bool isLoadMore = false}) async {
//     if (isLoadMore) {
//       if (isPaginatingPopular.value || !hasMorePopular.value) return;
//       isPaginatingPopular.value = true;
//     } else {
//       if (showLoading && popularTracks.isEmpty) {
//         isLoadingPopular.value = true;
//         popularError.value = '';
//       }
//       if (isRefresh) {
//         isRefreshingPopular.value = true;
//       }
//       _popularPage = 1;
//       hasMorePopular.value = true;
//     }
//
//     try {
//       final token = await SecureStorageService.instance.getAccessToken();
//       final headers = token != null ? {'Authorization': 'Bearer $token'} : null;
//
//       // Note: Assuming the API supports page and limit parameters
//       final String url = "${AppUrl.popularListening}?page=$_popularPage&limit=$_popularLimit";
//
//       final response = await _networkCaller.getRequest(
//         url,
//         headers: headers,
//       );
//
//       debugPrint('📡 Popular Response Status: ${response.statusCode}');
//       debugPrint('📡 Popular Response Success: ${response.isSuccess}');
//
//       if (response.isSuccess && response.jsonResponse != null) {
//         final jsonResponse = response.jsonResponse!;
//         List<TrackModel> newTracks = [];
//
//         if (jsonResponse['data'] != null && jsonResponse['data'] is List) {
//           newTracks = (jsonResponse['data'] as List)
//               .map((e) => TrackModel.fromJson(e))
//               .toList();
//         } else if (jsonResponse['data'] != null && jsonResponse['data']['results'] != null) {
//           // Alternative structure if backend uses results inside data
//           newTracks = (jsonResponse['data']['results'] as List)
//               .map((e) => TrackModel.fromJson(e))
//               .toList();
//         }
//
//         if (newTracks.isEmpty) {
//           hasMorePopular.value = false;
//         } else {
//           if (isLoadMore) {
//             popularTracks.addAll(newTracks);
//           } else {
//             popularTracks.assignAll(newTracks);
//           }
//           _popularPage++;
//
//           // If we received fewer items than the limit, it's likely the last page
//           if (newTracks.length < _popularLimit) {
//             hasMorePopular.value = false;
//           }
//         }
//         popularError.value = '';
//         debugPrint('✅ Loaded ${newTracks.length} popular tracks. Total: ${popularTracks.length}');
//       } else {
//         if (popularTracks.isEmpty) {
//           popularError.value = response.errorMessage ?? 'Failed to load popular sounds';
//         }
//         debugPrint('❌ Popular Error: ${response.errorMessage}');
//       }
//     } catch (e) {
//       if (popularTracks.isEmpty) {
//         popularError.value = 'An unexpected error occurred';
//       }
//       debugPrint('❌ Error fetching popular tracks: $e');
//     } finally {
//       if (showLoading) isLoadingPopular.value = false;
//       if (isRefresh) isRefreshingPopular.value = false;
//       if (isLoadMore) isPaginatingPopular.value = false;
//     }
//   }
//
//   // Refresh all data with shimmer effect
//   Future<void> refreshAllData() async {
//     await Future.wait([
//       fetchFeaturedSounds(showLoading: false, isRefresh: true),
//       fetchSleepTonight(showLoading: false, isRefresh: true),
//       fetchPopularSounds(showLoading: false, isRefresh: true),
//     ]);
//   }
//
//   // Format duration from seconds to readable string
//   String formatDuration(int? seconds) {
//     if (seconds == null || seconds == 0) return '0:00';
//     final minutes = (seconds / 60).floor();
//     final remainingSeconds = seconds % 60;
//     return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
//   }
//
//   // Get category name
//   String getCategoryName(TrackModel track) {
//     return track.categoryName ?? 'Music';
//   }
// }













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
  final RxBool isPaginatingPopular = false.obs;

  // Pagination states
  int _popularPage = 1;
  final int _popularLimit = 20; // Increased for better scrolling
  final RxBool hasMorePopular = true.obs;

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

  // Fetch Featured Sounds - Optimized
  Future<void> fetchFeaturedSounds({bool isRefresh = false}) async {
    // Prevent multiple simultaneous requests
    if (isLoadingFeatured.value && !isRefresh) return;

    if (featuredTracks.isEmpty || isRefresh) {
      isLoadingFeatured.value = true;
      if (isRefresh) isRefreshingFeatured.value = true;
      featuredError.value = '';
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
      isLoadingFeatured.value = false;
      if (isRefresh) isRefreshingFeatured.value = false;
    }
  }

  // Fetch Sleep Tonight Tracks - Optimized
  Future<void> fetchSleepTonight({bool isRefresh = false}) async {
    // Prevent multiple simultaneous requests
    if (isLoadingSleep.value && !isRefresh) return;

    if (sleepTonightTracks.isEmpty || isRefresh) {
      isLoadingSleep.value = true;
      if (isRefresh) isRefreshingSleep.value = true;
      sleepError.value = '';
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
      isLoadingSleep.value = false;
      if (isRefresh) isRefreshingSleep.value = false;
    }
  }

  // Fetch Popular Sounds - Optimized pagination
  Future<void> fetchPopularSounds({bool isRefresh = false, bool isLoadMore = false}) async {
    // Prevent duplicate requests
    if (isLoadMore) {
      if (isPaginatingPopular.value || !hasMorePopular.value) return;
      isPaginatingPopular.value = true;
    } else {
      if (isLoadingPopular.value && popularTracks.isNotEmpty && !isRefresh) return;

      isLoadingPopular.value = true;
      if (isRefresh) {
        isRefreshingPopular.value = true;
        popularError.value = '';
      }

      if (isRefresh) {
        _popularPage = 1;
        hasMorePopular.value = true;
      }
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final String url = "${AppUrl.popularListening}?page=$_popularPage&limit=$_popularLimit";

      final response = await _networkCaller.getRequest(url, headers: headers);

      debugPrint('📡 Popular Response Status: ${response.statusCode}');
      debugPrint('📡 Popular Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;
        List<TrackModel> newTracks = [];

        // Parse response - support both formats
        if (jsonResponse['data'] != null) {
          if (jsonResponse['data'] is List) {
            newTracks = (jsonResponse['data'] as List)
                .map((e) => TrackModel.fromJson(e))
                .toList();
          } else if (jsonResponse['data']['results'] != null) {
            newTracks = (jsonResponse['data']['results'] as List)
                .map((e) => TrackModel.fromJson(e))
                .toList();
          }
        }

        // Update pagination state
        if (newTracks.isEmpty || newTracks.length < _popularLimit) {
          hasMorePopular.value = false;
        }

        if (isLoadMore && !isRefresh) {
          popularTracks.addAll(newTracks);
        } else {
          popularTracks.assignAll(newTracks);
        }

        // Only increment page if we got data
        if (newTracks.isNotEmpty) {
          _popularPage++;
        }

        if (popularTracks.isNotEmpty) {
          popularError.value = '';
        }

        debugPrint('✅ Loaded ${newTracks.length} popular tracks. Total: ${popularTracks.length}');
      } else {
        if (!isLoadMore && popularTracks.isEmpty) {
          popularError.value = response.errorMessage ?? 'Failed to load popular sounds';
        }
        debugPrint('❌ Popular Error: ${response.errorMessage}');
      }
    } catch (e) {
      if (!isLoadMore && popularTracks.isEmpty) {
        popularError.value = 'An unexpected error occurred';
      }
      debugPrint('❌ Error fetching popular tracks: $e');
    } finally {
      if (!isLoadMore) {
        isLoadingPopular.value = false;
      }
      if (isLoadMore) {
        isPaginatingPopular.value = false;
      }
      if (isRefresh) {
        isRefreshingPopular.value = false;
      }
    }
  }

  // Refresh all data with shimmer effect
  Future<void> refreshAllData() async {
    // Reset pagination state
    _popularPage = 1;
    hasMorePopular.value = true;
    popularError.value = '';

    await Future.wait([
      fetchFeaturedSounds(isRefresh: true),
      fetchSleepTonight(isRefresh: true),
      fetchPopularSounds(isRefresh: true),
    ]);
  }

  // Format duration from seconds to readable string
  String formatDuration(int? seconds) {
    if (seconds == null || seconds <= 0) return '0:00';
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Get category name
  String getCategoryName(TrackModel track) {
    return track.categoryName ?? 'Music';
  }
}