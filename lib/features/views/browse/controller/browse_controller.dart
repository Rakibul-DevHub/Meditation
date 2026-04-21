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
  Future<void> fetchCategories() async {
    isCategoriesLoading.value = true;
    categoriesError.value = '';

    try {
      final NetworkResponseDio response = await _networkCaller.getRequest(AppUrl.categories);

      if (response.isSuccess && response.jsonResponse != null) {
        final categoryResponse = CategoryListResponse.fromJson(response.jsonResponse!);
        categories.value = categoryResponse.data?.results ?? [];
        filteredCategories.value = categories;
      } else {
        categoriesError.value = response.errorMessage ?? 'Failed to load categories';
      }
    } catch (e) {
      categoriesError.value = 'An unexpected error occurred';
      debugPrint('Error fetching categories: $e');
    } finally {
      isCategoriesLoading.value = false;
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
  Future<void> fetchCategoryDetails(String categoryId) async {
    isDetailsLoading.value = true;
    detailsError.value = '';
    selectedCategory.value = null;

    try {
      final NetworkResponseDio response = await _networkCaller.getRequest(
        AppUrl.categoryDetails(categoryId),
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final detailResponse = CategoryDetailResponse.fromJson(response.jsonResponse!);
        selectedCategory.value = detailResponse.data;
      } else {
        detailsError.value = response.errorMessage ?? 'Failed to load tracks';
      }
    } catch (e) {
      detailsError.value = 'An unexpected error occurred';
      debugPrint('Error fetching category details: $e');
    } finally {
      isDetailsLoading.value = false;
    }
  }
}
