/**
    import 'package:flutter/material.dart';
    import 'dart:ui';
    import 'package:get/get.dart';
    import 'package:cached_network_image/cached_network_image.dart';

    import 'package:outdoor_therapy/features/views/browse/browse_details_screen.dart';
    import 'package:outdoor_therapy/features/views/browse/controller/browse_controller.dart';
    import 'package:outdoor_therapy/model/category_model.dart';

    class BrowseScreen extends StatefulWidget {
    const BrowseScreen({super.key});

    @override
    State<BrowseScreen> createState() => _BrowseScreenState();
    }

    class _BrowseScreenState extends State<BrowseScreen> {
    final TextEditingController _searchController = TextEditingController();
    final BrowseController _controller = Get.put(BrowseController());

    @override
    void initState() {
    super.initState();
    _searchController.addListener(() {
    _controller.filterCategories(_searchController.text);
    });
    }

    @override
    void dispose() {
    _searchController.dispose();
    super.dispose();
    }

    @override
    Widget build(BuildContext context) {
    return Scaffold(
    backgroundColor: const Color(0xFF0A0E1A),
    body: SafeArea(
    child: CustomScrollView(
    physics: const BouncingScrollPhysics(),
    slivers: [
    // ── Header ─────────────────────────────────────────────────
    SliverToBoxAdapter(
    child: Padding(
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
    ),

    // ── Grid ───────────────────────────────────────────────────
    Obx(() {
    if (_controller.isCategoriesLoading.value) {
    return const SliverFillRemaining(
    child: Center(
    child: CircularProgressIndicator(color: Color(0xFF117A65)),
    ),
    );
    }

    if (_controller.categoriesError.isNotEmpty) {
    return SliverFillRemaining(
    child: Center(
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
    ),
    );
    }

    if (_controller.filteredCategories.isEmpty) {
    return const SliverFillRemaining(
    child: Center(
    child: Text(
    'No categories found',
    style: TextStyle(color: Colors.white54),
    ),
    ),
    );
    }

    return SliverPadding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
    sliver: SliverGrid(
    delegate: SliverChildBuilderDelegate(
    (context, index) => _CategoryCard(
    category: _controller.filteredCategories[index],
    ),
    childCount: _controller.filteredCategories.length,
    ),
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 2,
    crossAxisSpacing: 12,
    mainAxisSpacing: 12,
    childAspectRatio: 0.88,
    ),
    ),
    );
    }),
    ],
    ),
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
    color: const Color(0xFF151B2E),
    borderRadius: BorderRadius.circular(14),
    border: Border.all(
    color: Colors.white.withOpacity(0.07),
    width: 1,
    ),
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
    style: const TextStyle(
    color: Colors.white,
    fontSize: 15,
    ),
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
    late AnimationController _controller;
    late Animation<double> _scaleAnim;

    // Professional mapping for categories that don't have these in the API
    static const List<Color> _defaultGradient = [Color(0xFF1B3A4B), Color(0xFF0D2137)];
    static const IconData _defaultIcon = Icons.music_note_outlined;

    @override
    void initState() {
    super.initState();
    _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 120),
    lowerBound: 0.0,
    upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
    }

    @override
    void dispose() {
    _controller.dispose();
    super.dispose();
    }

    @override
    Widget build(BuildContext context) {
    final cat = widget.category;

    return GestureDetector(
    onTapDown: (_) => _controller.forward(),
    onTapUp: (_) => _controller.reverse(),
    onTapCancel: () => _controller.reverse(),
    onTap: () {
    Navigator.push(
    context,
    PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) =>
    BrowseDetailsScreen(
    categoryId: cat.id ?? '',
    categoryName: cat.name ?? 'Category',
    soundCount: cat.totalTracks ?? 0,
    icon: _defaultIcon, // You can map this based on cat.name if needed
    gradient: _defaultGradient,
    imagePath: cat.coverImageUrl ?? '',
    ),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeOutCubic;
    var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
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
    builder: (context, child) => Transform.scale(
    scale: _scaleAnim.value,
    child: child,
    ),
    child: ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: Stack(
    fit: StackFit.expand,
    children: [
    // ── Background image ──────────────────────────────────
    _BackgroundImage(imagePath: cat.coverImageUrl ?? '', gradient: _defaultGradient),

    // ── Bottom info overlay (frosted glass) ───────────────
    Positioned(
    left: 0,
    right: 0,
    bottom: 0,
    child: _CardInfoOverlay(category: cat),
    ),
    ],
    ),
    ),
    ),
    );
    }
    }

    // Background: tries network image first, falls back to gradient
    class _BackgroundImage extends StatelessWidget {
    final String imagePath;
    final List<Color> gradient;

    const _BackgroundImage({
    required this.imagePath,
    required this.gradient,
    });

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

    // Frosted bottom label
    class _CardInfoOverlay extends StatelessWidget {
    final CategoryModel category;
    const _CardInfoOverlay({required this.category});

    @override
    Widget build(BuildContext context) {
    return ClipRect(
    child: BackdropFilter(
    filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
    child: Container(
    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
    decoration: BoxDecoration(
    color: Colors.black.withOpacity(0.30),
    border: Border(
    top: BorderSide(
    color: Colors.white.withOpacity(0.08),
    width: 0.5,
    ),
    ),
    ),
    child: Row(
    children: [
    // Icon badge from URL or Default
    Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
    color: Colors.white.withOpacity(0.12),
    shape: BoxShape.circle,
    border: Border.all(
    color: Colors.white.withOpacity(0.2),
    width: 0.8,
    ),
    ),
    child: category.iconUrl != null && category.iconUrl!.isNotEmpty
    ? Padding(
    padding: const EdgeInsets.all(6.0),
    child: CachedNetworkImage(
    imageUrl: category.iconUrl!,
    color: Colors.white,
    ),
    )
    : const Icon(
    Icons.music_note_outlined,
    size: 16,
    color: Colors.white,
    ),
    ),
    const SizedBox(width: 10),
    Expanded(
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Text(
    category.name ?? '',
    style: const TextStyle(
    color: Colors.white,
    fontSize: 15,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    ),
    ),
    const SizedBox(height: 1),
    Text(
    '${category.totalTracks ?? 0} Sounds',
    style: TextStyle(
    color: Colors.white.withOpacity(0.55),
    fontSize: 11,
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
    }*/

import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart'; // Make sure to add shimmer package in pubspec.yaml

import 'package:outdoor_therapy/features/views/browse/browse_details_screen.dart';
import 'package:outdoor_therapy/features/views/browse/controller/browse_controller.dart';
import 'package:outdoor_therapy/model/category_model.dart';
import '../../../core/app_colors.dart'; // Assuming you have this, otherwise use Colors.grey

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchController = TextEditingController();
  final BrowseController _controller = Get.put(BrowseController());

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      _controller.filterCategories(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await _controller.fetchCategories();
          },
          color: const Color(0xFF117A65),
          backgroundColor: const Color(0xFF151B2E),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            // Ensures pull-to-refresh works even if list is short
            slivers: [
              // ── Header ─────────────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
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
              ),

              // ── Grid / Loading / Error ───────────────────────────────
              Obx(() {
                // Show Shimmer if loading AND list is empty (initial load or refresh)
                // Inside BrowseScreen build method -> Obx

                // Show Shimmer if:
                // 1. Loading is true AND
                // 2. The list currently displayed (filteredCategories) is empty
                if (_controller.isCategoriesLoading.value &&
                    _controller.filteredCategories.isEmpty) {
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _CategoryShimmerCard(),
                        // Your shimmer widget
                        childCount: 6,
                      ),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                            childAspectRatio: 0.88,
                          ),
                    ),
                  );
                }

                if (_controller.categoriesError.isNotEmpty) {
                  return SliverFillRemaining(
                    child: Center(
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
                    ),
                  );
                }

                if (_controller.filteredCategories.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No categories found',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ),
                  );
                }

                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => _CategoryCard(
                        category: _controller.filteredCategories[index],
                      ),
                      childCount: _controller.filteredCategories.length,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 0.88,
                        ),
                  ),
                );
              }),
            ],
          ),
        ),
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
        color: const Color(0xFF151B2E),
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
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

  // Professional mapping for categories that don't have these in the API
  static const List<Color> _defaultGradient = [
    Color(0xFF1B3A4B),
    Color(0xFF0D2137),
  ];
  static const IconData _defaultIcon = Icons.music_note_outlined;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
      lowerBound: 0.0,
      upperBound: 0.04,
    );
    _scaleAnim = Tween<double>(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cat = widget.category;

    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) => _controller.reverse(),
      onTapCancel: () => _controller.reverse(),
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
          borderRadius: BorderRadius.circular(18),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Background image ──────────────────────────────────
              _BackgroundImage(
                imagePath: cat.coverImageUrl ?? '',
                gradient: _defaultGradient,
              ),

              // ── Bottom info overlay (frosted glass) ───────────────
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _CardInfoOverlay(category: cat),
              ),
            ],
          ),
        ),
      ),
    );
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
      borderRadius: BorderRadius.circular(18),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Background Shimmer
          Shimmer.fromColors(
            baseColor: const Color(0xFF151B2E),
            highlightColor: const Color(0xFF1F2937),
            child: Container(color: Colors.white),
          ),

          // Bottom Overlay Shimmer
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                child: Container(
                  height: 60, // Approximate height of overlay
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.30),
                    border: Border(
                      top: BorderSide(
                        color: Colors.white.withOpacity(0.08),
                        width: 0.5,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Circle Icon Shimmer
                      Shimmer.fromColors(
                        baseColor: Colors.white.withOpacity(0.1),
                        highlightColor: Colors.white.withOpacity(0.2),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Title Shimmer
                            Shimmer.fromColors(
                              baseColor: Colors.white.withOpacity(0.1),
                              highlightColor: Colors.white.withOpacity(0.2),
                              child: Container(
                                width: double.infinity,
                                height: 14,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 6),
                            // Subtitle Shimmer
                            Shimmer.fromColors(
                              baseColor: Colors.white.withOpacity(0.1),
                              highlightColor: Colors.white.withOpacity(0.2),
                              child: Container(
                                width: 60,
                                height: 10,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Background: tries network image first, falls back to gradient
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

// Frosted bottom label
class _CardInfoOverlay extends StatelessWidget {
  final CategoryModel category;

  const _CardInfoOverlay({required this.category});

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.30),
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.08),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            children: [
              // Icon badge from URL or Default
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 0.8,
                  ),
                ),
                child: category.iconUrl != null && category.iconUrl!.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: CachedNetworkImage(
                          imageUrl: category.iconUrl!,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.music_note_outlined,
                        size: 16,
                        color: Colors.white,
                      ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${category.totalTracks ?? 0} Sounds',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 11,
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
}
