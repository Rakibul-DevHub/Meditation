import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_controller.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_model.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// In-app Stripe Checkout WebView.
///
/// Displays the Stripe hosted checkout page. Listens for redirect URLs:
///   - success → calls [onSuccess]
///   - cancel  → calls [onCancel]
///
/// Make sure your Stripe session is created with:
///   success_url: "https://yourapp.com/payment/success" (or a deep link)
///   cancel_url:  "https://yourapp.com/payment/cancel"
///
/// Update [_successUrlPattern] and [_cancelUrlPattern] to match your
/// actual success/cancel redirect URLs configured on the backend.

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_model.dart';
import 'package:outdoor_therapy/features/views/menu/subscription/subscription_controller.dart';

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
        // ── Loading state ───────────────────────────────────────────────
        if (controller.isLoading.value && controller.plans.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF7B61FF)),
            ),
          );
        }

        // ── Error state ─────────────────────────────────────────────────
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

        // ── Main content ────────────────────────────────────────────────
        return RefreshIndicator(
          onRefresh: controller.refresh,
          color: const Color(0xFF7B61FF),
          backgroundColor: const Color(0xFF151932),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),

                // ── Header ────────────────────────────────────────────
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundColor: const Color(0xFF151932),
                        child: SvgPicture.asset(
                          'assets/icons/subscription.svg',
                          height: 30,
                          width: 30,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Unlock unlimited sounds and features',
                        style: TextStyle(
                          color: Color(0xFF9AA4B2),
                          fontSize: 13,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                // ── Plans list ────────────────────────────────────────
                _buildPlansList(controller),
                const SizedBox(height: 24),

                // ── Payment + Subscribe (only when not premium) ───────
                if (controller.subscriptionStatus.value?.isPremium != true) ...[
                  _buildPaymentSection(controller),
                  const SizedBox(height: 20),
                  _buildSubscribeButton(controller),
                ],

                const SizedBox(height: 16),

                // ── Footer ────────────────────────────────────────────
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

  // ─────────────────────────────────────────────────────────────────────────
  // Subscribe button
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildSubscribeButton(SubscriptionController controller) {
    return Obx(() {
      final bool isPayPalSelected =
          controller.selectedPaymentMethod.value == 'paypal';
      final bool canSubscribe = !controller.isProcessing.value &&
          controller.selectedPlanId.isNotEmpty &&
          !isPayPalSelected;

      return SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: canSubscribe
              ? () {
            final selectedPlan = controller.plans.firstWhere(
                  (p) => p.id == controller.selectedPlanId.value,
            );
            controller.subscribeToPlan(selectedPlan);
          }
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7B61FF),
            disabledBackgroundColor:
            const Color(0xFF7B61FF).withOpacity(0.4),
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
              valueColor:
              AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
              : Text(
            isPayPalSelected
                ? 'PayPal Coming Soon'
                : 'Subscribe Now',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Payment method section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPaymentSection(SubscriptionController controller) {
    return Container(
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
              // Stripe
              Expanded(
                child: _buildPaymentMethodCard(
                  method: 'stripe',
                  icon: Icons.credit_card_rounded,
                  label: 'Stripe',
                  isComingSoon: false,
                  controller: controller,
                ),
              ),
              const SizedBox(width: 12),
              // PayPal — Coming Soon
              Expanded(
                child: _buildPaymentMethodCard(
                  method: 'paypal',
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'PayPal',
                  isComingSoon: true,
                  controller: controller,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodCard({
    required String method,
    required IconData icon,
    required String label,
    required bool isComingSoon,
    required SubscriptionController controller,
  }) {
    return Obx(() {
      final bool isSelected =
          controller.selectedPaymentMethod.value == method;

      return GestureDetector(
        onTap: () => controller.setPaymentMethod(method),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            color: isSelected && !isComingSoon
                ? const Color(0xFF7B61FF).withOpacity(0.15)
                : isSelected && isComingSoon
                ? Colors.orange.withOpacity(0.08)
                : const Color(0xFF1E2538),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected && !isComingSoon
                  ? const Color(0xFF7B61FF)
                  : isSelected && isComingSoon
                  ? Colors.orange.withOpacity(0.6)
                  : Colors.white.withOpacity(0.1),
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 18,
                    color: isComingSoon
                        ? Colors.white38
                        : isSelected
                        ? const Color(0xFF7B61FF)
                        : Colors.white70,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isComingSoon
                          ? Colors.white38
                          : isSelected
                          ? const Color(0xFF7B61FF)
                          : Colors.white70,
                      fontSize: 13,
                      fontWeight: isSelected && !isComingSoon
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              if (isComingSoon)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.orange.withOpacity(0.5),
                      width: 1,
                    ),
                  ),
                  child: const Text(
                    'Coming Soon',
                    style: TextStyle(
                      color: Colors.orange,
                      fontSize: 9,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.4,
                    ),
                  ),
                )
              else if (isSelected)
                const Icon(
                  Icons.check_circle,
                  color: Color(0xFF7B61FF),
                  size: 14,
                )
              else
                const SizedBox(height: 14),
            ],
          ),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Plans list — "Most Popular" badge sits between cards
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPlansList(SubscriptionController controller) {
    final plans = controller.plans;
    if (plans.isEmpty) return const SizedBox.shrink();

    return Obx(() {
      final List<Widget> items = [];

      for (int i = 0; i < plans.length; i++) {
        final plan = plans[i];
        final bool isPremium =
            plan.name.toLowerCase().contains('premium') ||
                plan.name.toLowerCase().contains('pro');
        final bool isCurrentPlan = controller.isCurrentPlan(plan.name);
        final bool isSelected =
            controller.selectedPlanId.value == plan.id || isCurrentPlan;
        final bool isFree = plan.price == 0;

        items.add(
          _buildPlanCard(
            plan: plan,
            controller: controller,
            isPremium: isPremium,
            isSelected: isSelected,
            isCurrentPlan: isCurrentPlan,
            isFree: isFree,
          ),
        );

        if (i < plans.length - 1) {
          final nextPlan = plans[i + 1];
          final bool nextIsPremium =
              nextPlan.name.toLowerCase().contains('premium') ||
                  nextPlan.name.toLowerCase().contains('pro');
          final bool nextIsCurrentPlan =
          controller.isCurrentPlan(nextPlan.name);

          if (nextIsPremium && !nextIsCurrentPlan) {
            // "Most Popular" pill between the two cards
            items.add(
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7B61FF),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Most Popular',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ),
            );
          } else {
            items.add(const SizedBox(height: 12));
          }
        }
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: items,
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Individual plan card
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPlanCard({
    required SubscriptionPlan plan,
    required SubscriptionController controller,
    required bool isPremium,
    required bool isSelected,
    required bool isCurrentPlan,
    required bool isFree,
  }) {
    final List<String> includedFeatures = plan.description;

    // Excluded features only shown on the free/basic plan
    final List<String> excludedFeatures = isFree
        ? [
      'Offline downloads',
      'Premium sounds',
      'Sleep timer',
      'Ad-free experience',
    ]
        : [];

    return GestureDetector(
      onTap: () {
        if (!isCurrentPlan) controller.selectPlan(plan.id);
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF131929),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected || isCurrentPlan
                ? const Color(0xFF7B61FF)
                : Colors.white.withOpacity(0.08),
            width: isSelected || isCurrentPlan ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Plan name + radio button ─────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  plan.name,
                  style: const TextStyle(
                    color: Color(0xFF9AA4B2),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    if (!isCurrentPlan) controller.selectPlan(plan.id);
                  },
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCurrentPlan || isSelected
                            ? const Color(0xFF7B61FF)
                            : Colors.white.withOpacity(0.35),
                        width: 2,
                      ),
                      color: isCurrentPlan
                          ? const Color(0xFF7B61FF)
                          : Colors.transparent,
                    ),
                    child: isCurrentPlan
                        ? const Icon(Icons.check,
                        color: Colors.white, size: 16)
                        : null,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),

            // ── Price ────────────────────────────────────────────
            Text(
              isFree ? 'Free' : plan.formattedPrice,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                height: 1.1,
              ),
            ),
            if (!isFree)
              Text(
                plan.intervalText,
                style: const TextStyle(
                  color: Color(0xFF9AA4B2),
                  fontSize: 13,
                ),
              ),

            const SizedBox(height: 20),
            const Divider(color: Color(0xFF1E293B), height: 1),
            const SizedBox(height: 16),

            // ── Included features (✓) ────────────────────────────
            ...includedFeatures.map(
                  (f) => _featureRow(label: f, included: true),
            ),

            // ── Excluded features (✗) — free plan only ───────────
            ...excludedFeatures.map(
                  (f) => _featureRow(label: f, included: false),
            ),

          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Feature row helper
  // ─────────────────────────────────────────────────────────────────────────
  Widget _featureRow({
    required String label,
    required bool included,
    IconData? icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(
            included ? (icon ?? Icons.check) : Icons.close,
            size: 18,
            color: included
                ? const Color(0xFF7B61FF)
                : const Color(0xFF3D4A5C),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                color:
                included ? Colors.white : const Color(0xFF3D4A5C),
                fontSize: 14,
                decoration: included
                    ? TextDecoration.none
                    : TextDecoration.lineThrough,
                decorationColor: const Color(0xFF3D4A5C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class StripeCheckoutScreen extends StatefulWidget {
  final String checkoutUrl;
  final String planName;
  final VoidCallback onSuccess;
  final VoidCallback onCancel;

  const StripeCheckoutScreen({
    super.key,
    required this.checkoutUrl,
    required this.planName,
    required this.onSuccess,
    required this.onCancel,
  });

  @override
  State<StripeCheckoutScreen> createState() => _StripeCheckoutScreenState();
}

class _StripeCheckoutScreenState extends State<StripeCheckoutScreen> {
  late final WebViewController _webViewController;
  bool _isLoading = true;
  bool _hasHandledRedirect = false;

  // ── Update these to match your backend's configured redirect URLs ──────
  // These patterns are matched against the URL the WebView navigates to.
  static const String _successUrlPattern = '/payment/success';
  static const String _cancelUrlPattern  = '/payment/cancel';

  // Stripe's own cancel link inside the hosted page
  static const String _stripeReturnPattern = 'return_url';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFF0A0E1A))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) setState(() => _isLoading = true);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _isLoading = false);
          },
          onWebResourceError: (WebResourceError error) {
            debugPrint('❌ WebView error: ${error.description}');
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url;
            debugPrint('🌐 WebView navigating to: $url');

            if (_hasHandledRedirect) return NavigationDecision.prevent;

            // ── Success redirect ──────────────────────────────────
            if (url.contains(_successUrlPattern)) {
              _hasHandledRedirect = true;
              debugPrint('✅ Stripe payment success detected');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onSuccess();
              });
              return NavigationDecision.prevent;
            }

            // ── Cancel redirect ───────────────────────────────────
            if (url.contains(_cancelUrlPattern)) {
              _hasHandledRedirect = true;
              debugPrint('🚫 Stripe payment cancelled detected');
              WidgetsBinding.instance.addPostFrameCallback((_) {
                widget.onCancel();
              });
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.checkoutUrl));
  }

  Future<bool> _onWillPop() async {
    // If WebView can go back within Stripe's flow, go back inside it.
    if (await _webViewController.canGoBack()) {
      await _webViewController.goBack();
      return false;
    }
    // Otherwise ask user to confirm leaving checkout
    final shouldLeave = await _showExitDialog();
    if (shouldLeave) widget.onCancel();
    return shouldLeave;
  }

  Future<bool> _showExitDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF131929),
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Leave Checkout?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        content: const Text(
          'Your payment has not been completed. Are you sure you want to leave?',
          style: TextStyle(color: Color(0xFF9AA4B2), fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(
              'Stay',
              style: TextStyle(color: Color(0xFF7B61FF)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(
              'Leave',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0E1A),
        appBar: AppBar(
          backgroundColor: const Color(0xFF0A0E1A),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () async {
              final shouldLeave = await _showExitDialog();
              if (shouldLeave && context.mounted) {
                widget.onCancel();
              }
            },
          ),
          title: Column(
            children: [
              Text(
                widget.planName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                'Secure Checkout',
                style: TextStyle(
                  color: Color(0xFF9AA4B2),
                  fontSize: 11,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            // Lock icon to indicate secure page
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: Icon(Icons.lock_outline, color: Color(0xFF7B61FF), size: 20),
            ),
          ],
        ),
        body: Stack(
          children: [
            // ── WebView ───────────────────────────────────────────
            WebViewWidget(controller: _webViewController),

            // ── Loading overlay ───────────────────────────────────
            if (_isLoading)
              Container(
                color: const Color(0xFF0A0E1A),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Color(0xFF7B61FF)),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Loading secure checkout...',
                        style: TextStyle(
                          color: Color(0xFF9AA4B2),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}