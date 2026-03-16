import 'package:flutter/material.dart';
import 'dart:ui';

import 'package:outdoor_therapy/features/views/browse/browse_details_screen.dart';

class BrowseScreen extends StatefulWidget {
  const BrowseScreen({super.key});

  @override
  State<BrowseScreen> createState() => _BrowseScreenState();
}

class _BrowseScreenState extends State<BrowseScreen> {
  final TextEditingController _searchController = TextEditingController();

  final List<_Category> _categories = [
    _Category(
      name: 'Rain',
      soundCount: 12,
      icon: Icons.water_drop_outlined,
      gradient: [Color(0xFF1B3A4B), Color(0xFF0D2137)],
      imagePath: 'assets/images/dummy_image.jpg',
    ),
    _Category(
      name: 'Ocean',
      soundCount: 12,
      icon: Icons.waves_outlined,
      gradient: [Color(0xFF1A5276), Color(0xFF117A65)],
      imagePath: 'assets/images/dummy_image2.jpg',
    ),
    _Category(
      name: 'Forest',
      soundCount: 12,
      icon: Icons.forest_outlined,
      gradient: [Color(0xFF1E3A1E), Color(0xFF2D5A27)],
      imagePath: 'assets/images/dummy_image2.jpg',
    ),
    _Category(
      name: 'Wind',
      soundCount: 12,
      icon: Icons.air_outlined,
      gradient: [Color(0xFF8D9DB6), Color(0xFF6B7A8D)],
      imagePath: 'assets/images/dummy_image.jpg',
    ),
    _Category(
      name: 'White Noise',
      soundCount: 12,
      icon: Icons.graphic_eq_outlined,
      gradient: [Color(0xFF2C3E50), Color(0xFF4A5568)],
      imagePath: 'assets/images/dummy_image2.jpg',
    ),
    _Category(
      name: 'Thunderstorm',
      soundCount: 12,
      icon: Icons.bolt_outlined,
      gradient: [Color(0xFF1A1A2E), Color(0xFF16213E)],
      imagePath: 'assets/images/dummy_image3.jpg',
    ),
    _Category(
      name: 'Fire',
      soundCount: 8,
      icon: Icons.local_fire_department_outlined,
      gradient: [Color(0xFF7B2D00), Color(0xFF4A1500)],
      imagePath: 'assets/images/dummy_image.jpg',
    ),
    _Category(
      name: 'Birds',
      soundCount: 15,
      icon: Icons.flutter_dash_outlined,
      gradient: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
      imagePath: 'assets/images/dummy_image.jpg',
    ),
  ];

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
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _CategoryCard(
                    category: _categories[index],
                  ),
                  childCount: _categories.length,
                ),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.88,
                ),
              ),
            ),
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
  final _Category category;
  const _CategoryCard({required this.category});

  @override
  State<_CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<_CategoryCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;

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
      // In _CategoryCardState, update the onTap:
      onTap: () {
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                BrowseDetailsScreen(
                  categoryName: cat.name,
                  soundCount: cat.soundCount,
                  icon: cat.icon,
                  gradient: cat.gradient,
                  imagePath: cat.imagePath,
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
              _BackgroundImage(imagePath: cat.imagePath, gradient: cat.gradient),

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

// Background: tries image first, falls back to gradient
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
      child: Image.asset(
        imagePath,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const SizedBox.expand(),
      ),
    );
  }
}

// Frosted bottom label
class _CardInfoOverlay extends StatelessWidget {
  final _Category category;
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
              // Icon badge
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
                child: Icon(
                  category.icon,
                  size: 16,
                  color: Colors.white.withOpacity(0.9),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      '${category.soundCount} Sounds',
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

// ─────────────────────────────────────────────────────────────────────────────
//  Data model
// ─────────────────────────────────────────────────────────────────────────────
class _Category {
  final String name;
  final int soundCount;
  final IconData icon;
  final List<Color> gradient;
  final String imagePath;

  const _Category({
    required this.name,
    required this.soundCount,
    required this.icon,
    required this.gradient,
    required this.imagePath,
  });
}