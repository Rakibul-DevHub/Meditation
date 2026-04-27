// settings_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/secure_storage_service.dart';

class SettingsController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  final RxBool isLoading = false.obs;
  final RxString content = ''.obs;
  final RxString errorMessage = ''.obs;

  // Fetch privacy policy
  Future<void> fetchPrivacyPolicy() async {
    isLoading.value = true;
    errorMessage.value = '';
    content.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _networkCaller.getRequest(
        AppUrl.privacyPolicy,
        headers: headers,
      );

      debugPrint('📡 Privacy Policy Response Status: ${response.statusCode}');
      debugPrint('📡 Privacy Policy Response Success: ${response.isSuccess}');
      debugPrint('📡 Privacy Policy Response Data: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // Extract data from response (adjust based on your API structure)
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          if (data is String && data.isNotEmpty) {
            content.value = data;
          } else if (data is Map && data.containsKey('content')) {
            content.value = data['content'].toString();
          } else {
            content.value = data.toString();
          }
          errorMessage.value = '';
          debugPrint('✅ Privacy policy loaded successfully');
        } else if (jsonResponse.containsKey('content')) {
          content.value = jsonResponse['content'].toString();
          errorMessage.value = '';
        } else {
          errorMessage.value = 'No privacy policy content available';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load privacy policy';
        debugPrint('❌ Privacy Policy Error: ${response.errorMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load privacy policy';
      debugPrint('❌ Exception fetching privacy policy: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch terms of service
  Future<void> fetchTermsOfService() async {
    isLoading.value = true;
    errorMessage.value = '';
    content.value = '';

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      final headers = token != null ? {'Authorization': 'Bearer $token'} : null;

      final response = await _networkCaller.getRequest(
        AppUrl.termsOfService,
        headers: headers,
      );

      debugPrint('📡 Terms Response Status: ${response.statusCode}');
      debugPrint('📡 Terms Response Success: ${response.isSuccess}');
      debugPrint('📡 Terms Response Data: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        final jsonResponse = response.jsonResponse!;

        // Extract data from response (adjust based on your API structure)
        if (jsonResponse.containsKey('data') && jsonResponse['data'] != null) {
          final data = jsonResponse['data'];
          if (data is String && data.isNotEmpty) {
            content.value = data;
          } else if (data is Map && data.containsKey('content')) {
            content.value = data['content'].toString();
          } else {
            content.value = data.toString();
          }
          errorMessage.value = '';
          debugPrint('✅ Terms of service loaded successfully');
        } else if (jsonResponse.containsKey('content')) {
          content.value = jsonResponse['content'].toString();
          errorMessage.value = '';
        } else {
          errorMessage.value = 'No terms of service content available';
        }
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load terms of service';
        debugPrint('❌ Terms Error: ${response.errorMessage}');
      }
    } catch (e) {
      errorMessage.value = 'Failed to load terms of service';
      debugPrint('❌ Exception fetching terms of service: $e');
    } finally {
      isLoading.value = false;
    }
  }
}