import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_model.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_screen.dart';
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

  /// Default to 'stripe' — PayPal is "coming soon".
  final RxString selectedPaymentMethod = 'stripe'.obs;

  final RxBool isProcessing = false.obs;
  final RxBool stripeEnabled = false.obs;
  final RxBool paypalEnabled = false.obs;

  // Subscription status
  final Rx<SubscriptionStatus?> subscriptionStatus =
  Rx<SubscriptionStatus?>(null);
  final RxBool isLoadingStatus = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSubscriptionPlans();
    fetchSubscriptionStatus();
  }

  // ─────────────────────────────────────────────────────────────────────
  // Fetch plans
  // ─────────────────────────────────────────────────────────────────────
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

      if (response.isSuccess && response.jsonResponse != null) {
        final subscriptionResponse =
        SubscriptionResponse.fromJson(response.jsonResponse!);

        plans.assignAll(subscriptionResponse.plans);

        // Debug: Print the values received from API
        debugPrint('💰 Stripe enabled from API: ${subscriptionResponse.stripeEnabled}');
        debugPrint('💰 PayPal enabled from API: ${subscriptionResponse.paypalEnabled}');

        stripeEnabled.value = subscriptionResponse.stripeEnabled;
        paypalEnabled.value = subscriptionResponse.paypalEnabled;

        // Fallback: If both are false, enable at least Stripe as default
        if (!stripeEnabled.value && !paypalEnabled.value) {
          debugPrint('⚠️ No payment methods enabled from API, enabling Stripe as fallback');
          stripeEnabled.value = true;
        }

        // Auto-select Stripe if available
        if (stripeEnabled.value && selectedPaymentMethod.value.isEmpty) {
          selectedPaymentMethod.value = 'stripe';
        }

        errorMessage.value = '';
        debugPrint('✅ Loaded ${plans.length} subscription plans');
        debugPrint('✅ Stripe enabled: ${stripeEnabled.value}, PayPal enabled: ${paypalEnabled.value}');
      } else {
        errorMessage.value =
            response.errorMessage ?? 'Failed to load subscription plans';
        debugPrint('❌ Error: ${response.errorMessage}');

        // Fallback for development/testing - show both options
        if (plans.isEmpty) {
          debugPrint('⚠️ Using fallback payment methods for development');
          stripeEnabled.value = true;
          paypalEnabled.value = true;
          selectedPaymentMethod.value = 'stripe';
        }
      }
    } catch (e) {
      debugPrint('❌ Exception: $e');
      errorMessage.value = 'An unexpected error occurred';

      // Fallback for development/testing
      stripeEnabled.value = true;
      paypalEnabled.value = true;
      selectedPaymentMethod.value = 'stripe';
    } finally {
      isLoading.value = false;
      isRefreshing.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Fetch subscription status
  // ─────────────────────────────────────────────────────────────────────
  Future<void> fetchSubscriptionStatus({bool showLoading = true}) async {
    if (showLoading) isLoadingStatus.value = true;

    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        isLoadingStatus.value = false;
        return;
      }

      debugPrint('🌐 GET: ${AppUrl.getSubscriptionStatus}');

      final response = await _networkCaller.getRequest(
        AppUrl.getSubscriptionStatus,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.isSuccess && response.jsonResponse != null) {
        subscriptionStatus.value =
            SubscriptionStatus.fromJson(response.jsonResponse!);
        debugPrint('✅ isPremium: ${subscriptionStatus.value?.isPremium}');
      }
    } catch (e) {
      debugPrint('❌ Error fetching subscription status: $e');
    } finally {
      isLoadingStatus.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────────────────────────────
  void selectPlan(String planId) => selectedPlanId.value = planId;

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
    debugPrint('💳 Payment method changed to: $method');
  }

  bool isCurrentPlan(String planName) {
    if (subscriptionStatus.value == null) return false;
    return subscriptionStatus.value!.isPremium == true &&
        planName.toLowerCase().contains('premium');
  }

  // ─────────────────────────────────────────────────────────────────────
  // Subscribe → POST → extract checkoutUrl → open Stripe WebView
  // ─────────────────────────────────────────────────────────────────────
  Future<void> subscribeToPlan(SubscriptionPlan plan) async {
    // Guard: PayPal not yet supported
    if (selectedPaymentMethod.value == 'paypal') {
      Get.snackbar(
        'Coming Soon',
        'PayPal payments are not available yet. Please use Credit Card.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
        duration: const Duration(seconds: 3),
      );
      return;
    }

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
        return;
      }

      // ── Request body ──────────────────────────────────────────────
      final Map<String, dynamic> requestBody = {
        'planId': plan.id,
        'paymentMethod': selectedPaymentMethod.value, // "stripe"
      };

      debugPrint('💳 Subscribing to: ${plan.name}');
      debugPrint('📦 Body: $requestBody');
      debugPrint('🌐 POST: ${AppUrl.subscribeToPlan}');

      final response = await _networkCaller.postRequest(
        AppUrl.subscribeToPlan,
        body: requestBody,
        headers: {'Authorization': 'Bearer $token'},
      );

      debugPrint('📡 Status: ${response.statusCode} | Success: ${response.isSuccess}');
      debugPrint('📡 Body: ${response.jsonResponse}');

      if (response.isSuccess && response.jsonResponse != null) {
        // ── Extract checkoutUrl from response ─────────────────────
        // Response shape:
        // { "data": { "checkoutUrl": "https://checkout.stripe.com/..." } }
        final dynamic data = response.jsonResponse!['data'];
        final String? checkoutUrl =
        data is Map ? data['checkoutUrl']?.toString() : null;

        if (checkoutUrl != null && checkoutUrl.isNotEmpty) {
          debugPrint('🔗 Opening Stripe checkout: $checkoutUrl');

          // ── Navigate to in-app WebView ────────────────────────────
          Get.to(
                () => StripeCheckoutScreen(
              checkoutUrl: checkoutUrl,
              planName: plan.name,
              onSuccess: () async {
                // Called when Stripe redirects to success URL
                await fetchSubscriptionStatus(showLoading: false);
                Get.back(); // close WebView
                Get.back(); // close Subscription screen
                Get.snackbar(
                  'Success 🎉',
                  'You are now subscribed to ${plan.name}!',
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                  duration: const Duration(seconds: 4),
                );
              },
              onCancel: () {
                // Called when Stripe redirects to cancel URL
                Get.back(); // close WebView only
                Get.snackbar(
                  'Cancelled',
                  'Subscription was not completed.',
                  backgroundColor: Colors.orange,
                  colorText: Colors.white,
                  snackPosition: SnackPosition.TOP,
                  duration: const Duration(seconds: 3),
                );
              },
            ),
            transition: Transition.rightToLeft,
          );
        } else {
          // Unexpected: success but no checkoutUrl
          Get.snackbar(
            'Error',
            'Could not retrieve checkout link. Please try again.',
            backgroundColor: Colors.red,
            colorText: Colors.white,
            snackPosition: SnackPosition.TOP,
          );
        }
      } else {
        Get.snackbar(
          'Subscription Failed',
          response.errorMessage ?? 'Failed to subscribe. Please try again.',
          backgroundColor: Colors.red,
          colorText: Colors.white,
          snackPosition: SnackPosition.TOP,
          duration: const Duration(seconds: 3),
        );
      }
    } catch (e) {
      debugPrint('❌ Subscription error: $e');
      Get.snackbar(
        'Error',
        'An unexpected error occurred. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.TOP,
      );
    } finally {
      isProcessing.value = false;
    }
  }

  // ─────────────────────────────────────────────────────────────────────
  // Refresh
  // ─────────────────────────────────────────────────────────────────────
  Future<void> refresh() async {
    await Future.wait([
      fetchSubscriptionPlans(refresh: true),
      fetchSubscriptionStatus(showLoading: false),
    ]);
  }
}