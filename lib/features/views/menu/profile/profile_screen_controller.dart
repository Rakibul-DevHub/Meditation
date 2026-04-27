
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/secure_storage_service.dart';

class ProfileController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Loading states
  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;

  // Error state
  final RxString errorMessage = ''.obs;

  // User data
  final RxString userId = ''.obs;
  final RxString firstName = ''.obs;
  final RxString lastName = ''.obs;
  final RxString fullName = ''.obs;
  final RxString email = ''.obs;
  final RxString phoneNumber = ''.obs;
  final RxString profileImage = ''.obs;
  final RxString userType = ''.obs;
  final RxString createdAt = ''.obs;

  // Form controllers
  late TextEditingController firstNameController;
  late TextEditingController lastNameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;

  @override
  void onInit() {
    super.onInit();
    // Initialize controllers
    firstNameController = TextEditingController();
    lastNameController = TextEditingController();
    emailController = TextEditingController();
    phoneController = TextEditingController();

    fetchUserProfile();
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }

  // Fetch user profile from API
  Future<void> fetchUserProfile({bool showLoading = true}) async {
    if (showLoading) {
      isLoading.value = true;
      errorMessage.value = '';
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to view profile';
        isLoading.value = false;
        return;
      }

      debugPrint('🔑 Fetching user profile...');

      final response = await _networkCaller.getRequest(
        AppUrl.getMyProfile,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Profile Response Status: ${response.statusCode}');
      debugPrint('📡 Profile Response Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // Extract data from response
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          // Update reactive variables
          userId.value = data['id']?.toString() ?? '';
          firstName.value = data['firstName']?.toString() ?? '';
          lastName.value = data['lastName']?.toString() ?? '';
          fullName.value = data['fullName']?.toString() ?? '';
          email.value = data['email']?.toString() ?? '';
          phoneNumber.value = data['phoneNumber']?.toString() ?? '';
          profileImage.value = data['profileImage']?.toString() ?? '';
          userType.value = data['userType']?.toString() ?? 'FREE';
          createdAt.value = data['createdAt']?.toString() ?? '';

          // Update text controllers
          firstNameController.text = firstName.value;
          lastNameController.text = lastName.value;
          emailController.text = email.value;
          phoneController.text = phoneNumber.value;

          errorMessage.value = '';
          debugPrint('✅ Profile loaded successfully for: ${email.value}');
        } else {
          errorMessage.value = 'Invalid response format';
        }
      } else {
        if (response.statusCode == 401) {
          errorMessage.value = 'Session expired. Please login again.';
        } else {
          errorMessage.value = response.errorMessage ?? 'Failed to load profile';
        }
        debugPrint('❌ Profile Error: ${response.errorMessage}');
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      debugPrint('❌ Exception fetching profile: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  // Update user profile using PATCH API
  Future<bool> updateProfile() async {
    isSaving.value = true;
    errorMessage.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null || token.isEmpty) {
        errorMessage.value = 'Please login to update profile';
        isSaving.value = false;
        return false;
      }

      // Prepare update data (only send fields that can be updated)
      final Map<String, dynamic> updateData = {};

      // Only add fields that have changed
      if (firstNameController.text.trim() != firstName.value) {
        updateData['firstName'] = firstNameController.text.trim();
      }

      if (lastNameController.text.trim() != lastName.value) {
        updateData['lastName'] = lastNameController.text.trim();
      }

      if (phoneController.text.trim() != phoneNumber.value) {
        updateData['phoneNumber'] = phoneController.text.trim();
      }

      // If no changes, return early
      if (updateData.isEmpty) {
        debugPrint('📝 No changes to update');
        isSaving.value = false;
        return true;
      }

      debugPrint('📤 Updating profile with PATCH: $updateData');

      final response = await _networkCaller.patchRequest(
        AppUrl.updateMyProfile,
        body: updateData,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Update Response Status: ${response.statusCode}');
      debugPrint('📡 Update Response Success: ${response.isSuccess}');
      debugPrint('📡 Update Response Data: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // Extract updated data from response
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];

          // Update local values with the response data
          firstName.value = data['firstName']?.toString() ?? firstName.value;
          lastName.value = data['lastName']?.toString() ?? lastName.value;
          phoneNumber.value = data['phoneNumber']?.toString() ?? phoneNumber.value;
          fullName.value = data['fullName']?.toString() ?? fullName.value;

          // Update controllers with new values
          firstNameController.text = firstName.value;
          lastNameController.text = lastName.value;
          phoneController.text = phoneNumber.value;

          debugPrint('✅ Profile updated successfully');
          debugPrint('📝 Updated firstName: ${firstName.value}');
          debugPrint('📝 Updated lastName: ${lastName.value}');
          debugPrint('📝 Updated phoneNumber: ${phoneNumber.value}');
        } else {
          // If response doesn't have data object, update manually
          firstName.value = firstNameController.text.trim();
          lastName.value = lastNameController.text.trim();
          phoneNumber.value = phoneController.text.trim();

          debugPrint('✅ Profile updated successfully (manual update)');
        }

        return true;
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to update profile';
        debugPrint('❌ Update Error: ${response.errorMessage}');
        return false;
      }
    } catch (e) {
      errorMessage.value = 'An unexpected error occurred';
      debugPrint('❌ Exception updating profile: $e');
      return false;
    } finally {
      isSaving.value = false;
    }
  }

  // Get formatted member since date
  String getMemberSince() {
    if (createdAt.value.isEmpty) return '';
    try {
      final date = DateTime.parse(createdAt.value);
      return 'Member since ${date.year}';
    } catch (e) {
      return '';
    }
  }

  // Get user type with styling
  String getUserTypeDisplay() {
    return userType.value == 'PREMIUM' ? 'Premium Member' : 'Free Member';
  }

  // Check if user is premium
  bool isPremium() {
    return userType.value == 'PREMIUM';
  }

  // Get profile image URL or return null
  String? getProfileImageUrl() {
    return profileImage.value.isNotEmpty ? profileImage.value : null;
  }

  // Refresh profile data
  Future<void> refreshProfile() async {
    await fetchUserProfile(showLoading: false);
  }
}