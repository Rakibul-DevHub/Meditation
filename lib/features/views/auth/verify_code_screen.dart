import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../../../core/app_colors.dart';
import 'controller/verify_code_screen_controller.dart';

class VerifyCodeScreen extends StatelessWidget {
  final String? email;
  const VerifyCodeScreen({super.key, this.email});

  @override
  Widget build(BuildContext context) {
    // Initialize controller
    final VerifyCodeController controller = Get.put(VerifyCodeController());

    // Set the email if passed
    if (email != null && controller.email.value.isEmpty) {
      controller.setEmail(email!);
      debugPrint('📧 Email received in VerifyCodeScreen: $email');
    } else {
      debugPrint('⚠️ No email received in VerifyCodeScreen');
    }

    return Scaffold(
      backgroundColor: const Color(0xff030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xffE8EBF2), size: 20),
          onPressed: () => controller.goBack(),
        ),
        title: const Text(
          "Verify Code",
          style: TextStyle(
            color: Color(0xffF9FAFB),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Logo Icon
              Container(
                height: 64,
                width: 64,
                decoration: BoxDecoration(
                  color: const Color(0xff101828),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: SvgPicture.asset(
                    'assets/images/logo.svg',
                    width: 80,
                    height: 80,
                    fit: BoxFit.scaleDown,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Title
              const Text(
                "Verify Code",
                style: TextStyle(
                  fontSize: 24,
                  color: Color(0xfff9fafb),
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 12),

              /// Description
              Obx(
                    () => Text(
                  controller.email.value.isNotEmpty
                      ? "Enter the 6-digit verification code sent to ${controller.email.value} to continue."
                      : "Enter the 6-digit verification code sent to your email to continue.",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xff9AA4B2),
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              /// OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(6, (index) {
                  return _buildOtpField(controller, index);
                }),
              ),

              const SizedBox(height: 32),

              /// Verify Button
              Obx(
                    () => SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    onPressed: controller.isLoading.value ? null : () => controller.verifyCode(),
                    child: controller.isLoading.value
                        ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      "Verify Code",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              /// Resend Section
              Column(
                children: [
                  const Text(
                    "Didn't receive the code?",
                    style: TextStyle(
                      color: Color(0xff6a7282),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Obx(
                        () => !controller.canResend.value
                        ? Text(
                      "Resend code in ${controller.secondsRemaining.value} seconds",
                      style: const TextStyle(
                        color: Color(0xff9AA4B2),
                        fontSize: 13,
                      ),
                    )
                        : GestureDetector(
                      onTap: () => controller.resendCode(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xff101828),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: const Color(0xff364153)),
                        ),
                        child: const Text(
                          "Resend Code",
                          style: TextStyle(
                            color: Color(0xffffffff),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOtpField(VerifyCodeController controller, int index) {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          width: 55,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xff101828),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: controller.otpControllers[index].text.isNotEmpty
                  ? AppColors.primaryColor
                  : const Color(0xff364153),
              width: controller.otpControllers[index].text.isNotEmpty ? 2 : 1,
            ),
          ),
          child: TextField(
            controller: controller.otpControllers[index],
            focusNode: controller.focusNodes[index],
            style: const TextStyle(
              color: Color(0xfff9fafb),
              fontSize: 18,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
            textAlign: TextAlign.center,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.number,
            maxLength: 1,
            decoration: const InputDecoration(
              counterText: '',
              border: InputBorder.none,
              isCollapsed: true,
              contentPadding: EdgeInsets.only(
                top: 7,
                bottom: 6,
              ),
            ),
            onChanged: (value) {
              setState(() {});
              controller.onOtpChanged(value, index);
            },
          ),
        );
      },
    );
  }
}