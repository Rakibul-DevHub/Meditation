import 'package:flutter/material.dart';

import '../auth/sign_in_screen.dart';



class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingContent> _contents = [
    OnboardingContent(
      title: "Better Sleep Awaits",
      description:
      "Drift into peaceful slumber with our curated collection of soothing sounds and ambient noise.",
      icon: Icons.nightlight_round,
    ),
    OnboardingContent(
      title: "Premium Audio Quality",
      description:
      "High-fidelity recordings of nature sounds, white noise, and relaxation tracks designed for rest.",
      icon: Icons.volume_up,
    ),
    OnboardingContent(
      title: "Your Personal Sanctuary",
      description:
      "Create your perfect sleep environment with customizable timers, favorites, and offline access.",
      icon: Icons.favorite_border,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      // Navigate to sign in screen when "Get Started" is pressed
      _navigateToSignIn();
    }
  }

  void _skipToEnd() {
    _pageController.animateToPage(
      _contents.length - 1,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  void _navigateToSignIn() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const SignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff030712),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Sleep",
          style: TextStyle(
            color: Color(0xffF9FAFB),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Visibility(
            visible: _currentPage < _contents.length - 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 20),
              child: GestureDetector(
                onTap: _skipToEnd,
                child: const Text(
                  "Skip",
                  style: TextStyle(
                    color: Color(0xff615fff),
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          /// Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xff030712),
                  Color(0xff0A0C1A),
                ],
              ),
            ),
          ),

          /// PageView for Swipeable Content
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _contents.length,
            itemBuilder: (context, index) {
              return OnboardingPage(content: _contents[index]);
            },
          ),

          /// Pagination Dots
          Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(_contents.length, (index) {
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: _currentPage == index ? 32 : 8,
                  height: 8,
                  margin: EdgeInsets.only(right: index < _contents.length - 1 ? 8 : 0),
                  decoration: BoxDecoration(
                    gradient: _currentPage == index
                        ? const LinearGradient(
                      colors: [
                        Color(0xff615fff),
                        Color(0xff8B7FFF),
                      ],
                    )
                        : null,
                    color: _currentPage == index ? null : const Color(0xff2A2F3F),
                    borderRadius: BorderRadius.circular(100),
                    boxShadow: _currentPage == index
                        ? [
                      BoxShadow(
                        color: const Color(0xff615fff).withOpacity(0.3),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                        : null,
                  ),
                );
              }),
            ),
          ),

          /// Next Button / Get Started Button
          Positioned(
            bottom: 24,
            left: 20,
            right: 20,
            child: Container(
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [
                    Color(0xff615fff),
                    Color(0xff7B77FF),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xff615fff).withOpacity(0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: _nextPage,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _currentPage == _contents.length - 1 ? "Get Started" : "Next",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingContent {
  final String title;
  final String description;
  final IconData icon;

  OnboardingContent({
    required this.title,
    required this.description,
    required this.icon,
  });
}

class OnboardingPage extends StatelessWidget {
  final OnboardingContent content;

  const OnboardingPage({super.key, required this.content});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            /// Animated Icon Container
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.8, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              builder: (context, double scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    width: 160,
                    height: 160,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xff1A1F2E),
                          Color(0xff101828),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(500),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xff615fff).withOpacity(0.15),
                          blurRadius: 30,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        content.icon,
                        color: Colors.white,
                        size: 70,
                      ),
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 40),

            /// Title with Animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              builder: (context, double opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Text(
                content.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xfff9fafb),
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            /// Description with Animation
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 1),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOut,
              builder: (context, double opacity, child) {
                return Opacity(
                  opacity: opacity,
                  child: child,
                );
              },
              child: Text(
                content.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xff9AA4B2),
                  fontSize: 16,
                  height: 1.5,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
