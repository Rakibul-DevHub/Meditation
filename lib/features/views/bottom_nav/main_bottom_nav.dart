import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/browse/browse_screen.dart';
import 'package:outdoor_therapy/features/views/download/download_page.dart';
import 'package:outdoor_therapy/features/views/favorite/favorite_screen.dart';
import 'package:outdoor_therapy/features/views/menu/menu_screen.dart';
import 'package:outdoor_therapy/core/widget/custom_play_card.dart';
import 'package:outdoor_therapy/features/views/now_playing/player_controller.dart';
import '../../../core/app_colors.dart';
import '../browse/controller/browse_controller.dart';
import '../favorite/favorite_screen_controller.dart';
import '../home/home_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selectedIndex = 0;
  final PlayerController _playerController = Get.find<PlayerController>();

  late final List<Widget> _screens;

  bool _isBrowsePreloaded = false;

  @override
  void initState() {
    super.initState();

    _screens = const [
      HomeScreen(),
      BrowseScreen(),
      FavoriteScreen(),
      DownloadScreen(),
      MenuScreen(),
    ];

    _preloadBrowseData();
  }

  void _preloadBrowseData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isBrowsePreloaded && Get.isRegistered<BrowseController>()) {
        _isBrowsePreloaded = true;
        Get.find<BrowseController>().fetchCategories(showLoading: false);
      }
    });
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) return;

    setState(() {
      _selectedIndex = index;
    });

    _refreshTabDataIfNeeded(index);
  }

  void _refreshTabDataIfNeeded(int index) {
    switch (index) {
      case 1: // Browse tab
        if (Get.isRegistered<BrowseController>()) {
          final browseController = Get.find<BrowseController>();
          if (browseController.categories.isEmpty) {
            browseController.fetchCategories(showLoading: false);
          }
        }
        break;
      case 2: // Favorites tab
        if (Get.isRegistered<FavoriteScreenController>()) {
          // Optional: Refresh favorites
        }
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      // No bottomNavigationBar — the bar is overlaid in a Stack so it
      // reserves NO layout space and the screen behind stays fully visible.
      body: Stack(
        children: [
          // Screens fill the entire available area
          Positioned.fill(
            child: IndexedStack(
              index: _selectedIndex,
              children: _screens,
            ),
          ),

          // Floating glassmorphic nav (+ mini-player) overlaid at the bottom
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _FloatingNavContainer(
              selectedIndex: _selectedIndex,
              onItemTapped: _onItemTapped,
              playerController: _playerController,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Floating container: holds the mini-player + glassmorphic curved nav bar
// ─────────────────────────────────────────────────────────────────────────────
class _FloatingNavContainer extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;
  final PlayerController playerController;

  const _FloatingNavContainer({
    required this.selectedIndex,
    required this.onItemTapped,
    required this.playerController,
  });

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: bottomInset > 0 ? bottomInset : 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Player floats just above the nav bar
          Obx(() {
            final track = playerController.currentTrack.value;
            final showPlayer = playerController.showMiniPlayer.value;

            if (!showPlayer || track == null) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: CustomPlayCard(
                  track: track,
                  isPlaying: playerController.isPlaying.value,
                  onPlayPause: playerController.togglePlayPause,
                  onClose: playerController.stopAndHidePlayer,
                ),
              ),
            );
          }),

          _GlassNavBar(
            selectedIndex: selectedIndex,
            onItemTapped: onItemTapped,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Glassmorphic curved nav bar with rounded corners + blur
// ─────────────────────────────────────────────────────────────────────────────
class _GlassNavBar extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onItemTapped;

  const _GlassNavBar({
    required this.selectedIndex,
    required this.onItemTapped,
  });

  static const List<NavItem> _navItems = [
    NavItem(
      icon: 'assets/icons/home_inactive.svg',
      activeIcon: 'assets/icons/home.svg',
      label: 'Home',
    ),
    NavItem(
      icon: 'assets/icons/browse_inactive.svg',
      activeIcon: 'assets/icons/browse.svg',
      label: 'Browse',
    ),
    NavItem(
      icon: 'assets/icons/favorite_inactive.svg',
      activeIcon: 'assets/icons/favorite.svg',
      label: 'Favourites',
    ),
    NavItem(
      icon: 'assets/icons/download_inactive.svg',
      activeIcon: 'assets/icons/download.svg',
      label: 'Downloads',
    ),
    NavItem(
      icon: 'assets/icons/menu_inactive.svg',
      activeIcon: 'assets/icons/menu.svg',
      label: 'Menu',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          height: 68,
          decoration: BoxDecoration(
            color: AppColors.mainBottomNavColor.withOpacity(0.55),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.12),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Row(
            children: List.generate(_navItems.length, (index) {
              return Expanded(
                child: _NavItemWidget(
                  item: _navItems[index],
                  isSelected: selectedIndex == index,
                  onTap: () => onItemTapped(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Single nav item
// ─────────────────────────────────────────────────────────────────────────────
class _NavItemWidget extends StatelessWidget {
  final NavItem item;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItemWidget({
    required this.item,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(
              horizontal: isSelected ? 12 : 0,
              vertical: 6,
            ),
            decoration: BoxDecoration(
              color: isSelected
                  ? Colors.white.withOpacity(0.12)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: SizedBox(
              width: 20,
              height: 20,
              child: SvgPicture.asset(
                isSelected ? item.activeIcon : item.icon,
                width: 20,
                height: 20,
                colorFilter: ColorFilter.mode(
                  isSelected ? AppColors.whiteColor : Colors.grey,
                  BlendMode.srcIn,
                ),
                cacheColorFilter: true,
                semanticsLabel: item.label,
              ),
            ),
          ),
          const SizedBox(height: 3),
          AnimatedDefaultTextStyle(
            duration: const Duration(milliseconds: 150),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
              color: isSelected ? AppColors.whiteColor : Colors.grey,
              fontFamily: 'Plus Jakarta Sans',
            ),
            child: Text(item.label),
          ),
        ],
      ),
    );
  }
}

// Model class for nav items
class NavItem {
  final String icon;
  final String activeIcon;
  final String label;

  const NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}