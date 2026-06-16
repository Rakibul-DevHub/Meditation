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
  final RxBool isSavingSleepTimer = false.obs;

  /// Maps display label → integer minutes sent to the API.
  /// 'Off' → 0, '15 min' → 15, etc.
  final List<String> sleepTimerOptions = [
    'Off',
    '15 min',
    '30 min',
    '45 min',
    '60 min',
  ];

  int _labelToMinutes(String label) {
    if (label == 'Off') return 00;
    // Extract the number from strings like '15 min'
    final match = RegExp(r'\d+').firstMatch(label);
    return match != null ? int.parse(match.group(0)!) : 0;
  }

  String _minutesToLabel(int minutes) {
    if (minutes == 0) return 'Off';
    return '$minutes min';
  }

  @override
  void onInit() {
    super.onInit();
    fetchUserProfile();
  }

  // ── Profile ────────────────────────────────────────────────────────────────

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

      final response = await _networkCaller.getRequest(
        AppUrl.getMyProfile,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;
        final data = jsonResponse.containsKey('data') && jsonResponse['data'] != null
            ? Map<String, dynamic>.from(jsonResponse['data'])
            : jsonResponse;

        userData.value = data;
        errorMessage.value = '';

        // Restore sleep timer value from profile if the API returns it
        final serverMinutes = data['sleepTimer'];
        if (serverMinutes != null) {
          final minutes = serverMinutes is int
              ? serverMinutes
              : int.tryParse(serverMinutes.toString()) ?? 0;
          sleepTimer.value = _minutesToLabel(minutes);
        }
      } else {
        if (userData.isEmpty) {
          errorMessage.value = response.errorMessage ?? 'Failed to load profile';
        }
      }
    } catch (e) {
      if (userData.isEmpty) errorMessage.value = 'An unexpected error occurred';
      debugPrint('Exception fetching profile: $e');
    } finally {
      if (showLoading) isLoading.value = false;
    }
  }

  Future<void> refreshProfile() async => fetchUserProfile(showLoading: false);

  // ── Sleep timer ───────────────────────────────────────────────────────────

  /// Called when the user picks a new timer option.
  /// Updates UI immediately, then patches the server.
  Future<void> updateSleepTimer(String label) async {
    sleepTimer.value = label;
    final minutes = _labelToMinutes(label); // 'Off' → 0, '15 min' → 15, etc.

    isSavingSleepTimer.value = true;
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null || token.isEmpty) return;

      debugPrint('Patching sleepTimer → $minutes');

      // Build body this way so 0 is never dropped by any null/falsy filtering
      // in the network layer — it is an explicit int, not a nullable value.
      final Map<String, dynamic> body = <String, dynamic>{};
      body['sleepTimer'] = minutes.toString(); // always an int: 0, 15, 30, 45, 60

      final response = await _networkCaller.patchRequest(
        AppUrl.updateMyProfile,
        body: body,
        headers: {'Authorization': 'Bearer $token'},
      );
    } catch (e) {
      debugPrint('Sleep timer patch error: $e');
      Get.snackbar(
        'Error',
        'Could not save sleep timer. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } finally {
      isSavingSleepTimer.value = false;
    }
  }

  // ── Notifications ─────────────────────────────────────────────────────────

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
    // TODO: Save to API if needed
  }

  // ── Logout ────────────────────────────────────────────────────────────────

  Future<void> logout() async {
    await SecureStorageService.instance.clearAll();
    Get.offAllNamed('/login');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String getFullName() {
    final firstName = userData['firstName'] ?? '';
    final lastName  = userData['lastName']  ?? '';
    final fullName  = userData['fullName']  ?? '';
    if (fullName.toString().isNotEmpty) return fullName.toString();
    if (firstName.toString().isNotEmpty || lastName.toString().isNotEmpty) {
      return '$firstName $lastName'.trim();
    }
    final email = userData['email'] ?? '';
    return email.toString().isNotEmpty ? email.toString().split('@').first : 'User';
  }

  String getEmail() => userData['email']?.toString() ?? '';

  String getUserType() =>
      (userData['userType'] ?? 'FREE') == 'PREMIUM' ? 'Premium Member' : 'Free Member';

  String getProfileImage() => userData['profileImage']?.toString() ?? '';

  bool isPremium() => userData['userType'] == 'PREMIUM';

  String getMemberSince() {
    final createdAt = userData['createdAt'];
    if (createdAt != null && createdAt.toString().isNotEmpty) {
      try {
        return 'Member since ${DateTime.parse(createdAt.toString()).year}';
      } catch (_) {}
    }
    return '';
  }

  // ── Sleep timer bottom sheet ──────────────────────────────────────────────

  void showSleepTimerPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF151B2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Obx(() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white24,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Sleep Timer',
            style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          ...sleepTimerOptions.map(
                (opt) => ListTile(
              title: Text(opt,
                  style: const TextStyle(color: Colors.white, fontSize: 15)),
              trailing: sleepTimer.value == opt
                  ? const Icon(Icons.check, color: Color(0xFF6C5ECF))
                  : null,
              onTap: () {
                // Close the sheet first, THEN fire the async save.
                Navigator.pop(context);
                Future.microtask(() => updateSleepTimer(opt));
              },
            ),
          ),
          const SizedBox(height: 16),
        ],
      )),
    );
  }
}