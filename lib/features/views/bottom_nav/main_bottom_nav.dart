import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/browse/browse_screen.dart';
import 'package:outdoor_therapy/features/views/download/download_page.dart';
import 'package:outdoor_therapy/features/views/favorite/favorite_screen.dart';
import 'package:outdoor_therapy/features/views/menu/menu_screen.dart';
import 'package:outdoor_therapy/core/widget/custom_play_card.dart';
import 'package:outdoor_therapy/core/widget/player_controller.dart';
import 'package:outdoor_therapy/features/views/browse/controller/browse_controller.dart';
import '../../../core/app_colors.dart';
import '../home/home_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selectedIndex = 0;
  final PlayerController _playerController = Get.put(PlayerController());

  final List<Widget> _screens = [
    const HomeScreen(),
    const BrowseScreen(),
    const FavoriteScreen(),
    const DownloadScreen(),
    const MenuScreen(),
  ];

  final List<Map<String, dynamic>> _navItems = [
    {
      'icon': 'assets/icons/home_inactive.svg',
      'activeIcon': 'assets/icons/home.svg',
      'label': 'Home',
    },
    {
      'icon': 'assets/icons/browse_inactive.svg',
      'activeIcon': 'assets/icons/browse.svg',
      'label': 'Browse',
    },
    {
      'icon': 'assets/icons/favorite_inactive.svg',
      'activeIcon': 'assets/icons/favorite.svg',
      'label': 'Favourites',
    },
    {
      'icon': 'assets/icons/download_inactive.svg',
      'activeIcon': 'assets/icons/download.svg',
      'label': 'Downloads',
    },
    {
      'icon': 'assets/icons/menu_inactive.svg',
      'activeIcon': 'assets/icons/menu.svg',
      'label': 'Menu',
    },
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    
    // Silent refresh logic: 
    // If user taps on the Browse tab (index 1), refresh data in background
    if (index == 1) {
      final browseController = Get.find<BrowseController>();
      browseController.fetchCategories(showLoading: false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini Player - using Obx for global state sync
          Obx(() {
            final track = _playerController.currentTrack.value;
            final showPlayer = _playerController.showMiniPlayer.value;

            if (!showPlayer || track == null) return const SizedBox.shrink();

            return CustomPlayCard(
              track: track,
              isPlaying: _playerController.isPlaying.value,
              onPlayPause: _playerController.togglePlayPause,
              onClose: _playerController.stopAndHidePlayer,
            );
          }),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.mainBottomNavColor,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(_navItems.length, (index) {
          final item = _navItems[index];
          final isSelected = _selectedIndex == index;

          return Expanded(
            child: GestureDetector(
              onTap: () => _onItemTapped(index),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: SvgPicture.asset(
                      isSelected ? item['activeIcon'] : item['icon'],
                      width: 20,
                      height: 20,
                      colorFilter: ColorFilter.mode(
                        isSelected ? AppColors.whiteColor : Colors.grey,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item['label'],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                      color: isSelected ? AppColors.whiteColor : Colors.grey,
                      fontFamily: 'Plus Jakarta Sans',
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}


