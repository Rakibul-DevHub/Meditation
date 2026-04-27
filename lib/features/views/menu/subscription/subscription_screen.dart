/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_model.dart';
import 'subscription_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SubscriptionController controller = Get.put(SubscriptionController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value && controller.plans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
            ),
          );
        }

        // Error state
        if (controller.errorMessage.isNotEmpty && controller.plans.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: const Color(0xFF7B61FF),
            backgroundColor: const Color(0xFF151932),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFF9AA4B2), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF9AA4B2),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: controller.refresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B61FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        // Show subscription plans (always show, even for premium users)
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: const Color(0xFF7B61FF),
          backgroundColor: const Color(0xFF151932),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header - Changes based on premium status
                if (controller.subscriptionStatus.value?.isPremium == true) ...[
                  // Premium user header
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF7B61FF), Color(0xFF6B51EF)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.verified_user,
                          size: 48,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Premium Member',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'You are enjoying premium benefits!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Your Current Plan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Show current subscription badge
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131929),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFF7B61FF), width: 2),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: const Color(0xFF7B61FF).withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.stars,
                            color: Color(0xFF7B61FF),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Active Subscription',
                                style: TextStyle(
                                  color: Color(0xFF7B61FF),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                controller.subscriptionStatus.value?.userType ?? 'PREMIUM',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Other Plans',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else ...[
                  // Non-premium user header
                  const Center(
                    child: Column(
                      children: [
                        Text(
                          'Unlock Unlimited Sounds',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Choose the plan that works for you',
                          style: TextStyle(
                            color: Color(0xFF9AA4B2),
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],

                // Plans List
                ...controller.plans.map((plan) => _buildPlanCard(plan, controller)),

                const SizedBox(height: 24),

                // Payment Method Selection (only show if not premium)
                if (controller.subscriptionStatus.value?.isPremium != true &&
                    (controller.stripeEnabled.value || controller.paypalEnabled.value)) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131929),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (controller.stripeEnabled.value)
                              Expanded(
                                child: _buildPaymentMethodCard(
                                  context,
                                  'stripe',
                                  '💳 Credit Card',
                                  controller,
                                ),
                              ),
                            if (controller.stripeEnabled.value && controller.paypalEnabled.value)
                              const SizedBox(width: 12),
                            if (controller.paypalEnabled.value)
                              Expanded(
                                child: _buildPaymentMethodCard(
                                  context,
                                  'paypal',
                                  '💰 PayPal',
                                  controller,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Cancel anytime note
                const Center(
                  child: Text(
                    'Cancel anytime • No hidden fees',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, String method, String label, SubscriptionController controller) {
    return Obx(() => GestureDetector(
      onTap: () => controller.setPaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: controller.selectedPaymentMethod.value == method
              ? const Color(0xFF7B61FF).withOpacity(0.2)
              : const Color(0xFF1E2538),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.selectedPaymentMethod.value == method
                ? const Color(0xFF7B61FF)
                : Colors.white12,
            width: controller.selectedPaymentMethod.value == method ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.selectedPaymentMethod.value == method)
              const Icon(Icons.check_circle, color: Color(0xFF7B61FF), size: 16),
            if (controller.selectedPaymentMethod.value == method)
              const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: controller.selectedPaymentMethod.value == method
                    ? const Color(0xFF7B61FF)
                    : Colors.white70,
                fontSize: 14,
                fontWeight: controller.selectedPaymentMethod.value == method
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildPlanCard(SubscriptionPlan plan, SubscriptionController controller) {
    final isPopular = plan.name.contains('Premium') || plan.name.contains('Pro') || plan.price >= 10;
    final isCurrentPlan = controller.isCurrentPlan(plan.name);

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: isPopular && !isCurrentPlan
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF7B61FF), Color(0xFF6B51EF)],
        )
            : null,
        color: isCurrentPlan
            ? const Color(0xFF1E2538)
            : (isPopular ? null : const Color(0xFF131929)),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isCurrentPlan
              ? const Color(0xFF7B61FF)
              : (isPopular ? Colors.transparent : Colors.white.withOpacity(0.06)),
          width: isCurrentPlan ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          // Popular tag or Current Plan tag
          if (isPopular && !isCurrentPlan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                'MOST POPULAR',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          if (isCurrentPlan)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF7B61FF),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: const Text(
                'CURRENT PLAN',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Plan Name
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      plan.name,
                      style: TextStyle(
                        color: isPopular || isCurrentPlan ? Colors.white : Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (isCurrentPlan)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Active',
                          style: TextStyle(
                            color: Colors.green,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),

                // Price (only show if not current plan)
                if (!isCurrentPlan)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        plan.formattedPrice,
                        style: TextStyle(
                          color: isPopular ? Colors.white : const Color(0xFF7B61FF),
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          plan.intervalText,
                          style: TextStyle(
                            color: isPopular ? Colors.white70 : const Color(0xFF9AA4B2),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                if (isCurrentPlan)
                  const Text(
                    'Already Subscribed',
                    style: TextStyle(
                      color: Color(0xFF7B61FF),
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                const SizedBox(height: 20),

                // Features
                ...plan.description.map((feature) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Icon(
                        isCurrentPlan ? Icons.check_circle : Icons.check_circle,
                        size: 20,
                        color: isCurrentPlan
                            ? const Color(0xFF7B61FF)
                            : (isPopular ? Colors.white : const Color(0xFF7B61FF)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          feature,
                          style: TextStyle(
                            color: isCurrentPlan
                                ? Colors.white
                                : (isPopular ? Colors.white70 : Colors.white70),
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                )),

                // Download limit feature
                if (plan.downloadLimit > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.cloud_download_outlined,
                          size: 20,
                          color: isCurrentPlan
                              ? const Color(0xFF7B61FF)
                              : (isPopular ? Colors.white : const Color(0xFF7B61FF)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Up to ${plan.downloadLimit} downloads',
                            style: TextStyle(
                              color: isCurrentPlan
                                  ? Colors.white
                                  : (isPopular ? Colors.white70 : Colors.white70),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 24),

                // Subscribe/Upgrade Button
                if (!isCurrentPlan)
                  Obx(() => SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: controller.isProcessing.value
                          ? null
                          : () => controller.subscribeToPlan(plan),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPopular ? Colors.white : const Color(0xFF7B61FF),
                        foregroundColor: isPopular ? const Color(0xFF7B61FF) : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isProcessing.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : Text(
                        controller.subscriptionStatus.value?.isPremium == true
                            ? 'Change Plan'
                            : 'Subscribe Now',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}*/





///
///
///
/// todo:: matching with the UI
///
///
///



import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_model.dart';
import 'subscription_controller.dart';

class SubscriptionScreen extends StatelessWidget {
  const SubscriptionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final SubscriptionController controller = Get.put(SubscriptionController());

    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Subscription',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Loading state
        if (controller.isLoading.value && controller.plans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
            ),
          );
        }

        // Error state
        if (controller.errorMessage.isNotEmpty && controller.plans.isEmpty) {
          return RefreshIndicator(
            onRefresh: controller.refresh,
            color: const Color(0xFF7B61FF),
            backgroundColor: const Color(0xFF151932),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: SizedBox(
                height: MediaQuery.of(context).size.height * 0.7,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            color: Color(0xFF9AA4B2), size: 48),
                        const SizedBox(height: 12),
                        Text(
                          controller.errorMessage.value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF9AA4B2),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: controller.refresh,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF7B61FF),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: const Color(0xFF7B61FF),
          backgroundColor: const Color(0xFF151932),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                const Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.workspace_premium,
                        size: 48,
                        color: Color(0xFF7B61FF),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Unlock Unlimited Sounds and Features',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Choose the plan that works for you',
                        style: TextStyle(
                          color: Color(0xFF9AA4B2),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                // Plans List
                ...controller.plans.map((plan) {
                  final isPremium = plan.name.toLowerCase().contains('premium') ||
                      plan.name.toLowerCase().contains('pro');
                  final isCurrentPlan = controller.isCurrentPlan(plan.name);
                  final isSelected = controller.selectedPlanId.value == plan.id || isCurrentPlan;

                  return _buildPlanCard(
                    plan,
                    controller,
                    isPremium,
                    isSelected,
                    isCurrentPlan,
                  );
                }),

                const SizedBox(height: 24),

                // Payment Method Selection (only show if not premium)
                if (controller.subscriptionStatus.value?.isPremium != true &&
                    (controller.stripeEnabled.value || controller.paypalEnabled.value)) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF131929),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withOpacity(0.06)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Select Payment Method',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (controller.stripeEnabled.value)
                              Expanded(
                                child: _buildPaymentMethodCard(
                                  context,
                                  'stripe',
                                  '💳 Credit Card',
                                  controller,
                                ),
                              ),
                            if (controller.stripeEnabled.value && controller.paypalEnabled.value)
                              const SizedBox(width: 12),
                            if (controller.paypalEnabled.value)
                              Expanded(
                                child: _buildPaymentMethodCard(
                                  context,
                                  'paypal',
                                  '💰 PayPal',
                                  controller,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Subscribe Button
                if (controller.subscriptionStatus.value?.isPremium != true)
                  Obx(() => SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: controller.isProcessing.value || controller.selectedPlanId.isEmpty
                          ? null
                          : () {
                        final selectedPlan = controller.plans.firstWhere(
                              (p) => p.id == controller.selectedPlanId.value,
                        );
                        controller.subscribeToPlan(selectedPlan);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7B61FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: controller.isProcessing.value
                          ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Text(
                        'Subscribe Now',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )),

                const SizedBox(height: 16),

                // Cancel anytime note
                const Center(
                  child: Text(
                    'Cancel anytime • No hidden fees',
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildPaymentMethodCard(BuildContext context, String method, String label, SubscriptionController controller) {
    return Obx(() => GestureDetector(
      onTap: () => controller.setPaymentMethod(method),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: controller.selectedPaymentMethod.value == method
              ? const Color(0xFF7B61FF).withOpacity(0.2)
              : const Color(0xFF1E2538),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: controller.selectedPaymentMethod.value == method
                ? const Color(0xFF7B61FF)
                : Colors.white12,
            width: controller.selectedPaymentMethod.value == method ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (controller.selectedPaymentMethod.value == method)
              const Icon(Icons.check_circle, color: Color(0xFF7B61FF), size: 16),
            if (controller.selectedPaymentMethod.value == method)
              const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: controller.selectedPaymentMethod.value == method
                    ? const Color(0xFF7B61FF)
                    : Colors.white70,
                fontSize: 14,
                fontWeight: controller.selectedPaymentMethod.value == method
                    ? FontWeight.w600
                    : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    ));
  }

  Widget _buildPlanCard(
      SubscriptionPlan plan,
      SubscriptionController controller,
      bool isPremium,
      bool isSelected,
      bool isCurrentPlan,
      ) {
    final isFree = plan.price == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Most Popular Badge (positioned above the card)
          if (isPremium && !isCurrentPlan)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B61FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Most Popular',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

          // Plan Card
          GestureDetector(
            onTap: () {
              if (!isCurrentPlan) {
                controller.selectPlan(plan.id);
              }
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF131929),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected || isCurrentPlan
                      ? const Color(0xFF7B61FF)
                      : Colors.white.withOpacity(0.06),
                  width: isSelected || isCurrentPlan ? 2 : 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: Plan Name + Radio Button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        plan.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      // Radio Button - ONLY current plan shows checkmark
                      GestureDetector(
                        onTap: () {
                          if (!isCurrentPlan) {
                            controller.selectPlan(plan.id);
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isCurrentPlan
                                  ? const Color(0xFF7B61FF)
                                  : (isSelected
                                  ? const Color(0xFF7B61FF)
                                  : Colors.white.withOpacity(0.3)),
                              width: 2,
                            ),
                            color: isCurrentPlan
                                ? const Color(0xFF7B61FF)  // ✅ Fill only for purchased
                                : Colors.transparent,       // ❌ No fill for others
                          ),
                          child: isCurrentPlan
                              ? const Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          )
                              : null,  // ❌ No checkmark for other plans
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Price
                  Text(
                    isFree ? 'Free' : plan.formattedPrice,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: isFree ? 28 : 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!isFree)
                    Text(
                      plan.intervalText,
                      style: const TextStyle(
                        color: Color(0xFF9AA4B2),
                        fontSize: 14,
                      ),
                    ),

                  const SizedBox(height: 20),
                  const Divider(color: Color(0xFF1E293B), height: 1),
                  const SizedBox(height: 20),

                  // ✅ Features from API response (plan.description)
                  ...plan.description.map((feature) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check,  // ✅ All description items are included features
                            size: 18,
                            color: Color(0xFF7B61FF),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              feature,  // ✅ Directly from API: "Unlimited songs", "3 max download"
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),

                  // ✅ Show download limit if > 0 (from API)
                  if (plan.downloadLimit > 0)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_download_outlined,
                            size: 18,
                            color: Color(0xFF7B61FF),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Up to ${plan.downloadLimit} downloads',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}