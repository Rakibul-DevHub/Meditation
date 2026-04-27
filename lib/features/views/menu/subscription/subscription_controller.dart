import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_model.dart';
import '../../../../core/network/app_url.dart';
import '../../../../core/network/network_caller_dio.dart';
import '../../../../core/network/secure_storage_service.dart';

class SubscriptionController extends GetxController {
  final NetworkCallerDio _networkCaller = NetworkCallerDio();

  final RxList<SubscriptionPlan> plans = <SubscriptionPlan>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedPlanId = ''.obs;
  final RxString selectedPaymentMethod = 'stripe'.obs;
  final RxBool isProcessing = false.obs;
  final RxBool stripeEnabled = false.obs;
  final RxBool paypalEnabled = false.obs;

  // Subscription status
  final Rx<SubscriptionStatus?> subscriptionStatus = Rx<SubscriptionStatus?>(null);
  final RxBool isLoadingStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptionPlans();
    fetchSubscriptionStatus();
  }

  Future<void> fetchSubscriptionPlans({bool refresh = false}) async {
    if (refresh) {
      isRefreshing.value = true;
      plans.clear();
      errorMessage.value = '';
    } else if (plans.isEmpty) {
      isLoading.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        errorMessage.value = 'Please login to view subscription plans';
        isLoading.value = false;
        isRefreshing.value = false;
        return;
      }

      debugPrint('🔑 Fetching subscription plans...');
      debugPrint('🌐 GET: ${AppUrl.getSubscriptionPlans}');

      final response = await _networkCaller.getRequest(
        AppUrl.getSubscriptionPlans,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Response status: ${response.statusCode}');
      debugPrint('📡 Response success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        final subscriptionResponse = SubscriptionResponse.fromJson(response.jsonResponse!);

        plans.assignAll(subscriptionResponse.plans);
        stripeEnabled.value = subscriptionResponse.stripeEnabled;
        paypalEnabled.value = subscriptionResponse.paypalEnabled;

        errorMessage.value = '';
        debugPrint('✅ Loaded ${plans.length} subscription plans');
      } else {
        errorMessage.value = response.errorMessage ?? 'Failed to load subscription plans';
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

  // Fetch subscription status
  Future<void> fetchSubscriptionStatus({bool showLoading = true}) async {
    if (showLoading) {
      isLoadingStatus.value = true;
    }

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        isLoadingStatus.value = false;
        return;
      }

      debugPrint('🔑 Fetching subscription status...');
      debugPrint('🌐 GET: ${AppUrl.getSubscriptionStatus}');

      final response = await _networkCaller.getRequest(
        AppUrl.getSubscriptionStatus,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Status Response: ${response.statusCode}');
      debugPrint('📡 Status Success: ${response.isSuccess}');

      if (response.isSuccess && response.jsonResponse != null) {
        subscriptionStatus.value = SubscriptionStatus.fromJson(response.jsonResponse!);
        debugPrint('✅ User is premium: ${subscriptionStatus.value?.isPremium}');
        debugPrint('✅ User type: ${subscriptionStatus.value?.userType}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching subscription status: $e');
    } finally {
      isLoadingStatus.value = false;
    }
  }

  void selectPlan(String planId) {
    selectedPlanId.value = planId;
  }

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  // Check if a plan is the user's current plan
  bool isCurrentPlan(String planName) {
    if (subscriptionStatus.value == null) return false;
    // Check if user is premium and plan name matches
    return subscriptionStatus.value!.isPremium == true &&
        planName.toLowerCase().contains('premium');
  }

  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    isProcessing.value = true;

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        Get.snackbar(
          'Error',
          'Please login to subscribe',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
        isProcessing.value = false;
        return;
      }

      final requestBody = {
        'planId': plan.id,
        'paymentMethod': selectedPaymentMethod.value,
      };

      debugPrint('💳 Subscribing to plan: ${plan.name}');
      debugPrint('📦 Request body: $requestBody');
      debugPrint('🌐 POST: ${AppUrl.subscribeToPlan}');

      final response = await _networkCaller.postRequest(
        AppUrl.subscribeToPlan,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Subscription Response Status: ${response.statusCode}');
      debugPrint('📡 Subscription Response Success: ${response.isSuccess}');

      if (response.isSuccess) {
        await fetchSubscriptionStatus(showLoading: false);

        Get.snackbar(
          'Success',
          'Successfully subscribed to ${plan.name}!',
          backgroundColor: Colors.green,
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3),
        );

        Future.delayed(const Duration(seconds: 1), () {
          Get.back();
        });
      } else {
        Get.snackbar(
          'Subscription Failed',
          response.errorMessage ?? 'Failed to subscribe',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      debugPrint('❌ Subscription error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  Future<void> refresh() async {
    await Future.wait([
      fetchSubscriptionPlans(refresh: true),
      fetchSubscriptionStatus(showLoading: false),
    ]);
  }
}