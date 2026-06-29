import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/network_response_dio.dart';
import '../../../../model/category_model.dart';

class BrowseController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // State for Browse Screen (Categories)
  final RxBool isCategoriesLoading = false.obs;
  final RxList<CategoryModel> categories = <CategoryModel>[].obs;
  final RxList<CategoryModel> filteredCategories = <CategoryModel>[].obs;
  final RxString categoriesError = ''.obs;

  // State for Browse Details Screen (Tracks)
  final RxBool isDetailsLoading = false.obs;
  final Rxn<CategoryModel> selectedCategory = Rxn<CategoryModel>();
  final RxString detailsError = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
  }

  // Fetch all categories
  Future<void> fetchCategories({bool showLoading = true}) async {
    if (showLoading) {
      isCategoriesLoading.value = true;
      categoriesError.value = '';

      // IMPORTANT: Clear filtered list immediately so UI shows Shimmer
      // We keep 'categories' intact until new data arrives to prevent empty screen glitch if API fails
      filteredCategories.clear();
    }

    try {
      final NetworkResponseDio response = await _networkCaller.getRequest(AppUrl.categories);

      if (response.isSuccess && response.jsonResponse != null) {
        final categoryResponse = CategoryListResponse.fromJson(response.jsonResponse!);
        final newCategories = categoryResponse.data?.results ?? [];

        categories.value = newCategories;

        // Re-apply filter if there was text in search bar, otherwise show all
        // Note: You might want to store the current search query in a variable if you want
        // the search text to persist across refreshes. For now, we reset to full list.
        filteredCategories.value = categories;

        categoriesError.value = '';
      } else {
        if (categories.isEmpty) {
          categoriesError.value = response.errorMessage ?? 'Failed to load categories';
        } else {
          // If we already had data, just keep showing old data and maybe show a subtle snackbar?
          // For now, we just leave the old data visible.
        }
      }
    } catch (e) {
      if (categories.isEmpty) {
        categoriesError.value = 'An unexpected error occurred';
      }
      debugPrint('Error fetching categories: $e');
    } finally {
      if (showLoading) isCategoriesLoading.value = false;
    }
  }

  // Search/Filter categories
  void filterCategories(String query) {
    if (query.isEmpty) {
      filteredCategories.value = categories;
    } else {
      filteredCategories.value = categories
          .where((cat) => cat.name?.toLowerCase().contains(query.toLowerCase()) ?? false)
          .toList();
    }
  }

  // Fetch tracks for a specific category
  Future<void> fetchCategoryDetails(String categoryId, {bool showLoading = true}) async {
    if (showLoading) {
      isDetailsLoading.value = true;
      detailsError.value = '';
    }

    try {
      final NetworkResponseDio response = await _networkCaller.getRequest(
        AppUrl.categoryDetails(categoryId),
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final detailResponse = CategoryDetailResponse.fromJson(response.jsonResponse!);
        selectedCategory.value = detailResponse.data;
        detailsError.value = '';
      } else {
        if (selectedCategory.value == null) {
          detailsError.value = response.errorMessage ?? 'Failed to load tracks';
        }
      }
    } catch (e) {
      if (selectedCategory.value == null) {
        detailsError.value = 'An unexpected error occurred';
      }
      debugPrint('Error fetching category details: $e');
    } finally {
      if (showLoading) isDetailsLoading.value = false;
    }
  }
}