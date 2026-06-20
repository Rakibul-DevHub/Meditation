import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
import 'package:image_picker/image_picker.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/secure_storage_service.dart';

class ProfileController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final ImagePicker _picker = ImagePicker();

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

  // Track locally chosen image path
  final RxString selectedImagePath = ''.obs;

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

  // Method to pick image from gallery or camera source
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Slightly compress image quality to save bandwidth
      );

      if (pickedFile != null) {
        selectedImagePath.value = pickedFile.path;
      }
    } catch (e) {
      errorMessage.value = 'Failed to pick image';
      debugPrint('❌ Error picking image: $e');
    }
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

  // Update user profile using PATCH API (Supports JSON & fresh FormData generation)
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

      // Check if we need to send multipart form-data or standard json
      bool useMultipart = selectedImagePath.isNotEmpty;

      debugPrint('📤 Updating profile...');

      final response = await _networkCaller.patchRequest(
        AppUrl.updateMyProfile,
        headers: {'Authorization': 'Bearer $token'},
        // Case A: Send plain JSON body if NO local image is selected
        body: useMultipart
            ? null
            : {
          'firstName': firstNameController.text.trim(),
          'lastName': lastNameController.text.trim(),
          'phoneNumber': phoneController.text.trim(),
        },
        // Case B: Send fresh dynamic FormData factory if an image IS selected
        formDataFactory: useMultipart
            ? () {
          final dio.FormData formData = dio.FormData();

          // Add textual data fields
          formData.fields.addAll([
            MapEntry('firstName', firstNameController.text.trim()),
            MapEntry('lastName', lastNameController.text.trim()),
            MapEntry('phoneNumber', phoneController.text.trim()),
          ]);

          // Append the multipart file using the correct backend 'image' key
          File file = File(selectedImagePath.value);
          String fileName = file.path.split('/').last;
          formData.files.add(MapEntry(
            'image', // Changed from 'profileImage' to 'image' to fix backend mismatch
            dio.MultipartFile.fromFileSync(file.path, filename: fileName),
          ));

          return formData;
        }
            : null,
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
          profileImage.value = data['profileImage']?.toString() ?? profileImage.value;

          // Update controllers with new values
          firstNameController.text = firstName.value;
          lastNameController.text = lastName.value;
          phoneController.text = phoneNumber.value;

          debugPrint('✅ Profile updated successfully');
        } else {
          // If response doesn't have data object, update manually
          firstName.value = firstNameController.text.trim();
          lastName.value = lastNameController.text.trim();
          phoneNumber.value = phoneController.text.trim();

          debugPrint('✅ Profile updated successfully (manual update)');
        }

        selectedImagePath.value = ''; // Safely clear local selection on success
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