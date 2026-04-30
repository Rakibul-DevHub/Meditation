
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/secure_storage_service.dart';

class MenuScreenController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  // Profile data
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxMap<String, dynamic> userData = RxMap<String, dynamic>();

  // Settings
  final RxBool notificationsEnabled = false.obs;
  final RxString sleepTimer = 'Off'.obs;

  final List<String> sleepTimerOptions = [
    'Off', '15 min', '30 min', '45 min', '60 min',
  ];

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  // Fetch user profile from API
  Future<void> fetchUserProfile({bool showLoading = true}) async {
    if (showLoading && userData.isEmpty) {
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
      debugPrint('📡 Profile Response Body: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        // ✅ FIX: Extract the data object from the response
        final jsonResponse = response.jsonResponse!;

        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          userData.value = Map<String, dynamic>.from(jsonResponse['data']);
          debugPrint('✅ Profile data loaded: ${userData['email']}');
        } else {
          userData.value = jsonResponse;
          debugPrint('⚠️ No data wrapper found, using full response');
        }

        errorMessage.value = '';
      } else {
        if (userData.isEmpty) {
          errorMessage.value = response.errorMessage ?? 'Failed to load profile';
        }
        debugPrint('❌ Profile Error: ${response.errorMessage}');
      }
    } catch (e) {
      if (userData.isEmpty) {
        errorMessage.value = 'An unexpected error occurred';
      }
      debugPrint('❌ Exception fetching profile: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  // Refresh profile (for pull-to-refresh)
  Future<void> refreshProfile() async {
    await fetchUserProfile(showLoading: false);
  }

  // Get full name from user data
  String getFullName() {
    final firstName = userData['firstName'] ?? '';
    final lastName = userData['lastName'] ?? '';
    final fullName = userData['fullName'] ?? '';

    if (fullName.isNotEmpty && fullName != "") return fullName;
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    // If no name, use email username or show "User"
    final email = userData['email'] ?? '';
    if (email.isNotEmpty) {
      return email.split('@').first;
    }
    return 'User';
  }

  // Get email from user data
  String getEmail() {
    return userData['email'] ?? '';
  }

  // Get user type (PREMIUM/FREE)
  String getUserType() {
    final userType = userData['userType'] ?? 'FREE';
    return userType == 'PREMIUM' ? 'Premium Member' : 'Free Member';
  }

  // Get profile image URL
  String getProfileImage() {
    return userData['profileImage'] ?? '';
  }

  // Check if user is premium
  bool isPremium() {
    return userData['userType'] == 'PREMIUM';
  }

  // Get member since year
  String getMemberSince() {
    final createdAt = userData['createdAt'];
    if (createdAt != null && createdAt is String && createdAt.isNotEmpty) {
      try {
        final date = DateTime.parse(createdAt);
        return 'Member since ${date.year}';
      } catch (e) {
        return '';
      }
    }
    return '';
  }

  // Update sleep timer
  void updateSleepTimer(String value) {
    sleepTimer.value = value;
    // TODO: Save to API if needed
  }

  // Toggle notifications
  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    // TODO: Save to API if needed
  }

  // Logout user
  Future<void> logout() async {
    await SecureStorageService.instance.clearAll();
    Get.offAllNamed('/login'); // Adjust to your login route
  }

  // Show sleep timer picker
  void showSleepTimerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36, height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sleep Timer',
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...sleepTimerOptions.map((opt) => ListTile(
            title: Text(opt, style: const TextStyle(color: Colors.white, fontSize: 15)),
            trailing: sleepTimer.value == opt
                ? const Icon(Icons.check, color: Color(0xFF6C5ECF))
                : null,
            onTap: () {
              updateSleepTimer(opt);
              Navigator.pop(context);
            },
          )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}