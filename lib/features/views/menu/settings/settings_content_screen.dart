/**
// settings_content_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'settings_controller.dart';

class SettingsContentScreen extends StatefulWidget {
  final String title;
  final String type; // 'privacy' or 'terms'

  const SettingsContentScreen({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<SettingsContentScreen> createState() => _SettingsContentScreenState();
}

class _SettingsContentScreenState extends State<SettingsContentScreen> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SettingsController());
    _loadContent();
  }

  Future<void> _loadContent() async {
    if (widget.type == 'privacy') {
      await _controller.fetchPrivacyPolicy();
    } else {
      await _controller.fetchTermsOfService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Loading state
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5ECF)),
            ),
          );
        }

        // Error state
        if (_controller.errorMessage.isNotEmpty && _controller.content.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage.value,
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5ECF),
                    ),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          );
        }

        // Content loaded successfully
        if (_controller.content.isNotEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Last updated info (optional - if your API provides this)
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFF6C5ECF).withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     'Last updated: ${DateTime.now().year}',
                //     style: const TextStyle(
                //       color: Color(0xFF6C5ECF),
                //       fontSize: 12,
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 24),

                // Content
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131929),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    _controller.content.value,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        }

        // No content state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.white38,
              ),
              const SizedBox(height: 16),
              const Text(
                'No content available',
                style: TextStyle(color: Colors.white54),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5ECF),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        );
      }),
    );
  }
}*/






// settings_content_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/core/app_text_style.dart';
import 'settings_controller.dart';

class SettingsContentScreen extends StatefulWidget {
  final String title;
  final String type; // 'privacy' or 'terms'

  const SettingsContentScreen({
    super.key,
    required this.title,
    required this.type,
  });

  @override
  State<SettingsContentScreen> createState() => _SettingsContentScreenState();
}

class _SettingsContentScreenState extends State<SettingsContentScreen> {
  late final SettingsController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(SettingsController());
    _loadContent();
  }

  Future<void> _loadContent() async {
    if (widget.type == 'privacy') {
      await _controller.fetchPrivacyPolicy();
    } else {
      await _controller.fetchTermsOfService();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: AppTextStyle.ARIAL_White.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        // Loading state
        if (_controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6C5ECF)),
            ),
          );
        }

        // Error state
        if (_controller.errorMessage.isNotEmpty && _controller.content.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _controller.errorMessage.value,
                    style: AppTextStyle.ARIAL_Grey.copyWith(
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _loadContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6C5ECF),
                    ),
                    child: Text(
                      'Try Again',
                      style: AppTextStyle.ARIAL_White.copyWith(
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Content loaded successfully
        if (_controller.content.isNotEmpty) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  widget.title,
                  style: AppTextStyle.ARIAL_White.copyWith(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Last updated info (optional - if your API provides this)
                // Container(
                //   padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                //   decoration: BoxDecoration(
                //     color: const Color(0xFF6C5ECF).withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(20),
                //   ),
                //   child: Text(
                //     'Last updated: ${DateTime.now().year}',
                //     style: AppTextStyle.ARIAL_Grey.copyWith(
                //       fontSize: 12,
                //       color: const Color(0xFF6C5ECF),
                //     ),
                //   ),
                // ),
                // const SizedBox(height: 24),

                // Content
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF131929),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.06),
                      width: 1,
                    ),
                  ),
                  child: SelectableText(
                    _controller.content.value,
                    textAlign: TextAlign.justify,
                    style: AppTextStyle.ARIAL_Grey.copyWith(
                      fontSize: 14,
                      color: Colors.white70,
                      height: 1.6,
                    ),
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          );
        }

        // No content state
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.description_outlined,
                size: 64,
                color: Colors.white38,
              ),
              const SizedBox(height: 16),
              Text(
                'No content available',
                style: AppTextStyle.ARIAL_Grey.copyWith(
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadContent,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6C5ECF),
                ),
                child: Text(
                  'Retry',
                  style: AppTextStyle.ARIAL_White.copyWith(
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}