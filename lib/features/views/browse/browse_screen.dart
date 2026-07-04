/**
import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import 'package:shimmer/shimmer.dart';
import 'package:outdoor_therapy/features/views/browse/browse_details_screen.dart';
import 'package:outdoor_therapy/features/views/browse/controller/browse_controller.dart';
import 'package:outdoor_therapy/model/category_model.dart';
import '../now_playing/player_controller.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late final TextEditingController _searchController;
  late final BrowseController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize controller properly
    _searchController = TextEditingController();

    // Check if controller is already registered (for hot reload)
    if (Get.isRegistered<BrowseController>()) {
      _controller = Get.find<BrowseController>();
    } else {
      _controller = Get.put(BrowseController());
    }

    _searchController.addListener(() {
      _controller.filterCategories(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Don't dispose GetX controllers - they're managed by GetX
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Column(
        children: [
          // ── Fixed Header + Search ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore sounds by category',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.45),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 20),

                // ── Search bar ──────────────────────────────────
                _SearchBar(controller: _searchController),

                const SizedBox(height: 28),

                const Text(
                  'Categories',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // ── Scrollable Grid ─────────────────────────────────────────
          Expanded(
            child: Obx(() {
              // Loading state
              if (_controller.isCategoriesLoading.value &&
                  _controller.filteredCategories.isEmpty) {
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) =>
                  const _CategoryShimmerCard(),
                );
              }

              // Error state
              if (_controller.categoriesError.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _controller.categoriesError.value,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _controller.fetchCategories(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF117A65),
                        ),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                );
              }

              // Empty state
              if (_controller.filteredCategories.isEmpty) {
                return const Center(
                  child: Text(
                    'No categories found',
                    style: TextStyle(color: Colors.white54),
                  ),
                );
              }

              // Categories grid with pull-to-refresh and reactive padding
              return RefreshIndicator(
                onRefresh: () async {
                  await _controller.fetchCategories();
                },
                color: const Color(0xFF117A65),
                backgroundColor: const Color(0xFF151B2E),
                child: Obx(() {
                  // ✅ Reactive padding based on mini player visibility
                  final bool showMiniPlayer = playerController.showMiniPlayer.value;
                  final double bottomPadding = showMiniPlayer ? 170.0 : 90.0;

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      bottomPadding,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _controller.filteredCategories.length,
                    itemBuilder: (context, index) => _CategoryCard(
                      category: _controller.filteredCategories[index],
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Search bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.mainBottomNavColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.35),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: const TextStyle(color: Colors.white, fontSize: 15),
              decoration: InputDecoration(
                hintText: 'Search sounds...',
                hintStyle: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Category card
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnim;

  static const List<Color> _defaultGradient = [
    Color(0xFF1B3A4B),
    Color(0xFF0D2137),
  ];
  static const IconData _defaultIcon = Icons.music_note_outlined;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BrowseDetailsScreen(
                  categoryId: cat.id ?? '',
                  categoryName: cat.name ?? 'Category',
                  soundCount: cat.totalTracks ?? 0,
                  icon: _defaultIcon,
                  gradient: _defaultGradient,
                  imagePath: cat.coverImageUrl ?? '',
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background asset/image ───────────────────────────
              _BackgroundImage(
                imagePath: cat.coverImageUrl ?? '',
                gradient: _defaultGradient,
              ),

              // ── Legibility Mask ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.40),
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // ── Content Overlay ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Icon badge
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: categoryHasIcon(cat)
                              ? CachedNetworkImage(
                            imageUrl: cat.iconUrl!,
                            fit: BoxFit.contain,
                          )
                              : const Icon(
                            Icons.water_drop_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      cat.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Subtitle
                    Text(
                      '${cat.totalTracks ?? 0} Sounds',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool categoryHasIcon(CategoryModel model) {
    return model.iconUrl != null && model.iconUrl!.isNotEmpty;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shimmer Card for Loading State
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryShimmerCard extends StatelessWidget {
  const _CategoryShimmerCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF151B2E),
        highlightColor: const Color(0xFF1F2937),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 85,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 50,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Background Image Handler
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundImage extends StatelessWidget {
  final String imagePath;
  final List<Color> gradient;

  const _BackgroundImage({required this.imagePath, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const SizedBox.expand(),
        placeholder: (_, __) => Container(color: Colors.white10),
      ),
    );
  }
}*/











import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_therapy/core/app_colors.dart';
import 'package:outdoor_therapy/core/app_text_style.dart';
import 'package:shimmer/shimmer.dart';
import 'package:outdoor_therapy/features/views/browse/browse_details_screen.dart';
import 'package:outdoor_therapy/features/views/browse/controller/browse_controller.dart';
import 'package:outdoor_therapy/model/category_model.dart';
import '../now_playing/player_controller.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  late final TextEditingController _searchController;
  late final BrowseController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize controller properly
    _searchController = TextEditingController();

    // Check if controller is already registered (for hot reload)
    if (Get.isRegistered<BrowseController>()) {
      _controller = Get.find<BrowseController>();
    } else {
      _controller = Get.put(BrowseController());
    }

    _searchController.addListener(() {
      _controller.filterCategories(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    // Don't dispose GetX controllers - they're managed by GetX
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PlayerController playerController = Get.find<PlayerController>();

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Column(
        children: [
          // ── Fixed Header + Search ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Browse',
                  style: AppTextStyle.ARIAL_White.copyWith(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Explore sounds by category',
                  style: AppTextStyle.ARIAL_Grey.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.45),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Search bar ──────────────────────────────────
                _SearchBar(controller: _searchController),

                const SizedBox(height: 28),

                Text(
                  'Categories',
                  style: AppTextStyle.ARIAL_White.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 14),
              ],
            ),
          ),

          // ── Scrollable Grid ─────────────────────────────────────────
          Expanded(
            child: Obx(() {
              // Loading state
              if (_controller.isCategoriesLoading.value &&
                  _controller.filteredCategories.isEmpty) {
                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  physics: const AlwaysScrollableScrollPhysics(),
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    childAspectRatio: 1.0,
                  ),
                  itemCount: 6,
                  itemBuilder: (context, index) =>
                  const _CategoryShimmerCard(),
                );
              }

              // Error state
              if (_controller.categoriesError.isNotEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _controller.categoriesError.value,
                        style: AppTextStyle.ARIAL_White.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => _controller.fetchCategories(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF117A65),
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
                );
              }

              // Empty state
              if (_controller.filteredCategories.isEmpty) {
                return Center(
                  child: Text(
                    'No categories found',
                    style: AppTextStyle.ARIAL_White.copyWith(
                      color: Colors.white54,
                    ),
                  ),
                );
              }

              // Categories grid with pull-to-refresh and reactive padding
              return RefreshIndicator(
                onRefresh: () async {
                  await _controller.fetchCategories();
                },
                color: const Color(0xFF117A65),
                backgroundColor: const Color(0xFF151B2E),
                child: Obx(() {
                  // ✅ Reactive padding based on mini player visibility
                  final bool showMiniPlayer = playerController.showMiniPlayer.value;
                  final double bottomPadding = showMiniPlayer ? 170.0 : 90.0;

                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      0,
                      20,
                      bottomPadding,
                    ),
                    physics: const AlwaysScrollableScrollPhysics(),
                    gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _controller.filteredCategories.length,
                    itemBuilder: (context, index) => _CategoryCard(
                      category: _controller.filteredCategories[index],
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Search bar
// ─────────────────────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: AppColors.mainBottomNavColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.07), width: 1),
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(
            Icons.search_rounded,
            color: Colors.white.withOpacity(0.35),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              style: AppTextStyle.ARIAL_White.copyWith(
                fontSize: 15,
              ),
              decoration: InputDecoration(
                hintText: 'Search sounds...',
                hintStyle: AppTextStyle.ARIAL_White.copyWith(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 15,
                ),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Category card
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryCard extends StatefulWidget {
  final CategoryModel category;

  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnim;

  static const List<Color> _defaultGradient = [
    Color(0xFF1B3A4B),
    Color(0xFF0D2137),
  ];
  static const IconData _defaultIcon = Icons.music_note_outlined;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _animationController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BrowseDetailsScreen(
                  categoryId: cat.id ?? '',
                  categoryName: cat.name ?? 'Category',
                  soundCount: cat.totalTracks ?? 0,
                  icon: _defaultIcon,
                  gradient: _defaultGradient,
                  imagePath: cat.coverImageUrl ?? '',
                ),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(1.0, 0.0);
              const end = Offset.zero;
              const curve = Curves.easeOutCubic;
              var tween = Tween(
                begin: begin,
                end: end,
              ).chain(CurveTween(curve: curve));
              return SlideTransition(
                position: animation.drive(tween),
                child: child,
              );
            },
          ),
        );
      },
      child: AnimatedBuilder(
        animation: _scaleAnim,
        builder: (context, child) =>
            Transform.scale(scale: _scaleAnim.value, child: child),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background asset/image ───────────────────────────
              _BackgroundImage(
                imagePath: cat.coverImageUrl ?? '',
                gradient: _defaultGradient,
              ),

              // ── Legibility Mask ──────────────────────────────────
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.05),
                      Colors.black.withOpacity(0.40),
                      Colors.black.withOpacity(0.75),
                    ],
                    stops: const [0.0, 0.4, 0.7, 1.0],
                  ),
                ),
              ),

              // ── Content Overlay ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.only(left: 8, bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Icon badge
                    ClipOval(
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Colors.white24,
                            shape: BoxShape.circle,
                          ),
                          child: categoryHasIcon(cat)
                              ? CachedNetworkImage(
                            imageUrl: cat.iconUrl!,
                            fit: BoxFit.contain,
                          )
                              : const Icon(
                            Icons.water_drop_outlined,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Title
                    Text(
                      cat.name ?? '',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyle.ARIAL_White.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    // Subtitle
                    Text(
                      '${cat.totalTracks ?? 0} Sounds',
                      style: AppTextStyle.ARIAL_White.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.white.withOpacity(0.55),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool categoryHasIcon(CategoryModel model) {
    return model.iconUrl != null && model.iconUrl!.isNotEmpty;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shimmer Card for Loading State
// ─────────────────────────────────────────────────────────────────────────────
class _CategoryShimmerCard extends StatelessWidget {
  const _CategoryShimmerCard();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFF151B2E),
        highlightColor: const Color(0xFF1F2937),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.white),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    width: 85,
                    height: 16,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 50,
                    height: 11,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Background Image Handler
// ─────────────────────────────────────────────────────────────────────────────
class _BackgroundImage extends StatelessWidget {
  final String imagePath;
  final List<Color> gradient;

  const _BackgroundImage({required this.imagePath, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
      ),
      child: CachedNetworkImage(
        imageUrl: imagePath,
        fit: BoxFit.cover,
        errorWidget: (_, __, ___) => const SizedBox.expand(),
        placeholder: (_, __) => Container(color: Colors.white10),
      ),
    );
  }
}