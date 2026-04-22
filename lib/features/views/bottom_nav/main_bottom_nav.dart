// import 'package:flutter/material.dart';
// import 'package:flutter_svg/flutter_svg.dart';
// import 'dart:ui';
// import 'package:outdoor_therapy/features/views/browse/browse_screen.dart';
// import 'package:outdoor_therapy/features/views/download/download_page.dart';
// import 'package:outdoor_therapy/features/views/favorite/favorite_screen.dart';
// import 'package:outdoor_therapy/features/views/menu/menu_screen.dart';
// import 'package:outdoor_therapy/features/views/now_playing/now_playing_screen.dart'; // Import the now playing screen
// import '../../../core/app_colors.dart';
// import '../home/home_screen.dart';
//
// class MainBottomNav extends StatefulWidget {
//   const MainBottomNav({super.key});
//
//   @override
//   State<MainBottomNav> createState() => _MainBottomNavState();
// }
//
// class _MainBottomNavState extends State<MainBottomNav> {
//   int _selectedIndex = 0;
//   bool _isPlaying = true;
//   bool _showMiniPlayer = true;
//
//   final Map<String, dynamic>? _currentTrack = {
//     'title': 'Soft Breeze',
//     'subtitle': 'Meditation',
//     'image': 'assets/gif/playing.gif',
//   };
//
//   final List<Widget> _screens = [
//     const HomeScreen(),
//     const BrowseScreen(),
//     const FavoriteScreen(),
//     const DownloadScreen(),
//     const MenuScreen(),
//   ];
//
//   final List<Map<String, dynamic>> _navItems = [
//     {
//       'icon': 'assets/icons/home_inactive.svg',
//       'activeIcon': 'assets/icons/home.svg',
//       'label': 'Home',
//       'fallbackIcon': Icons.home_outlined,
//       'fallbackActiveIcon': Icons.home,
//     },
//     {
//       'icon': 'assets/icons/browse_inactive.svg',
//       'activeIcon': 'assets/icons/browse.svg',
//       'label': 'Browse',
//       'fallbackIcon': Icons.explore_outlined,
//       'fallbackActiveIcon': Icons.explore,
//     },
//     {
//       'icon': 'assets/icons/favorite_inactive.svg',
//       'activeIcon': 'assets/icons/favorite.svg',
//       'label': 'Favourites',
//       'fallbackIcon': Icons.favorite_outline,
//       'fallbackActiveIcon': Icons.favorite,
//     },
//     {
//       'icon': 'assets/icons/download_inactive.svg',
//       'activeIcon': 'assets/icons/download.svg',
//       'label': 'Downloads',
//       'fallbackIcon': Icons.download_outlined,
//       'fallbackActiveIcon': Icons.download,
//     },
//     {
//       'icon': 'assets/icons/menu_inactive.svg',
//       'activeIcon': 'assets/icons/menu.svg',
//       'label': 'Menu',
//       'fallbackIcon': Icons.menu_outlined,
//       'fallbackActiveIcon': Icons.menu,
//     },
//   ];
//
//   void _onItemTapped(int index) => setState(() => _selectedIndex = index);
//
//   void _togglePlayPause() => setState(() => _isPlaying = !_isPlaying);
//
//   void _closePlayer() => setState(() => _showMiniPlayer = false);
//
//   // Navigate to now playing screen
//   void _navigateToNowPlaying() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (context) => const NowPlayingScreen(
//           title: 'sone',
//           image: 'assets/images/dummy_image.jpg',
//           duration: '2:25',
//           description: 'Beautiful',
//           category: 'song',
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // Extend body so the blurred mini-player truly sits OVER the screen content
//       extendBody: true,
//       body: IndexedStack(index: _selectedIndex, children: _screens),
//       bottomNavigationBar: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           if (_currentTrack != null && _showMiniPlayer) _buildMiniPlayer(),
//           _buildBottomNav(),
//         ],
//       ),
//     );
//   }
//
//   // ── Liquid-glass mini player ─────────────────────────────────────────────
//   Widget _buildMiniPlayer() {
//     return GestureDetector(
//       // Entire card navigates to now playing screen when tapped
//       onTap: _navigateToNowPlaying,
//       // Allow buttons inside to receive taps without triggering the card's onTap
//       behavior: HitTestBehavior.opaque,
//       child: ClipRRect(
//         // Sharp rectangular clip so BackdropFilter only blurs this region
//         borderRadius: BorderRadius.zero,
//         child: BackdropFilter(
//           // High sigma = strong blur = visible liquid-glass effect
//           filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
//           child: Container(
//             height: 72,
//             decoration: BoxDecoration(
//               // Almost fully transparent — background bleeds through the blur
//               color: Colors.white.withOpacity(0.06),
//               border: Border(
//                 top: BorderSide(
//                   color: Colors.white.withOpacity(0.18),
//                   width: 0.8,
//                 ),
//               ),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
//               child: Row(
//                 children: [
//                   // ── Vinyl / track thumbnail ──────────────────────────
//                   _VinylAvatar(image: _currentTrack!['image']),
//
//                   const SizedBox(width: 14),
//
//                   // ── Track title + subtitle ───────────────────────────
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           _currentTrack!['title'],
//                           style: const TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w600,
//                             letterSpacing: 0.1,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                         const SizedBox(height: 2),
//                         Text(
//                           _currentTrack!['subtitle'],
//                           style: TextStyle(
//                             color: Colors.white.withOpacity(0.55),
//                             fontSize: 13,
//                           ),
//                           maxLines: 1,
//                           overflow: TextOverflow.ellipsis,
//                         ),
//                       ],
//                     ),
//                   ),
//
//                   const SizedBox(width: 10),
//
//                   // ── Play / Pause button — circular glass ring ────────
//                   // Wrap with Listener to stop propagation to parent GestureDetector
//                   Listener(
//                     onPointerDown: (_) {
//                       // This prevents the parent GestureDetector from receiving the tap
//                       // but we need to also handle the actual tap
//                     },
//                     child: _GlassCircleButton(
//                       size: 42,
//                       onTap: _togglePlayPause,
//                       child: Icon(
//                         _isPlaying ? Icons.pause : Icons.play_arrow,
//                         color: Colors.white,
//                         size: 20,
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(width: 10),
//
//                   // ── Close button ─────────────────────────────────────
//                   // Wrap with Listener to stop propagation to parent GestureDetector
//                   Listener(
//                     onPointerDown: (_) {
//                       // This prevents the parent GestureDetector from receiving the tap
//                     },
//                     child: GestureDetector(
//                       onTap: _closePlayer,
//                       child: Icon(
//                         Icons.close,
//                         color: Colors.white.withOpacity(0.65),
//                         size: 22,
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ── Bottom nav bar ───────────────────────────────────────────────────────
//   Widget _buildBottomNav() {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: AppColors.mainBottomNavColor,
//         boxShadow: [
//           BoxShadow(
//             color: Colors.grey.withOpacity(0.15),
//             spreadRadius: 1,
//             blurRadius: 6,
//             offset: const Offset(0, -2),
//           ),
//         ],
//       ),
//       child: Row(
//         children: List.generate(_navItems.length, (index) {
//           final item = _navItems[index];
//           final isSelected = _selectedIndex == index;
//
//           return Expanded(
//             child: GestureDetector(
//               onTap: () => _onItemTapped(index),
//               behavior: HitTestBehavior.opaque,
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   SizedBox(
//                     width: 26,
//                     height: 26,
//                     child: SvgPicture.asset(
//                       isSelected ? item['activeIcon'] : item['icon'],
//                       width: 26,
//                       height: 26,
//                       colorFilter: ColorFilter.mode(
//                         isSelected ? AppColors.whiteColor : Colors.grey,
//                         BlendMode.srcIn,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     item['label'],
//                     style: TextStyle(
//                       fontSize: 11,
//                       fontWeight: isSelected
//                           ? FontWeight.w700
//                           : FontWeight.w400,
//                       color: isSelected ? AppColors.whiteColor : Colors.grey,
//                       fontFamily: 'Plus Jakarta Sans',
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           );
//         }),
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  Vinyl / album art thumbnail with subtle spin ring
// // ─────────────────────────────────────────────────────────────────────────────
// class _VinylAvatar extends StatelessWidget {
//   final String image;
//
//   const _VinylAvatar({required this.image});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: 52,
//       height: 52,
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           // Outer purple ring (mimics the vinyl look in the screenshot)
//           Container(
//             width: 52,
//             height: 52,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               gradient: const SweepGradient(
//                 colors: [
//                   Color(0xFF7B6CF6),
//                   Color(0xFF5E4AD4),
//                   Color(0xFF9E8FFE),
//                   Color(0xFF7B6CF6),
//                 ],
//               ),
//             ),
//           ),
//           // Album art
//           Container(
//             width: 38,
//             height: 38,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               image: DecorationImage(
//                 image: AssetImage(image),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           // Centre dot
//           Container(
//             width: 10,
//             height: 10,
//             decoration: const BoxDecoration(
//               shape: BoxShape.circle,
//               color: Color(0xFFE8B44A),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // ─────────────────────────────────────────────────────────────────────────────
// //  Glass-ring circle button (used for play/pause)
// // ─────────────────────────────────────────────────────────────────────────────
// class _GlassCircleButton extends StatelessWidget {
//   final double size;
//   final VoidCallback onTap;
//   final Widget child;
//
//   const _GlassCircleButton({
//     required this.size,
//     required this.onTap,
//     required this.child,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: ClipOval(
//         child: BackdropFilter(
//           // Additional blur just inside the button for the nested-glass look
//           filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
//           child: Container(
//             width: size,
//             height: size,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               // Slightly lighter tint than the bar so the button "pops"
//               color: Colors.white.withOpacity(0.12),
//               border: Border.all(
//                 // Circular progress-like ring matching the screenshot
//                 color: const Color(0xFF7B6CF6).withOpacity(0.85),
//                 width: 2.2,
//               ),
//             ),
//             child: Center(child: child),
//           ),
//         ),
//       ),
//     );
//   }
// }












/*

// main_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:outdoor_therapy/features/views/browse/browse_screen.dart';
import 'package:outdoor_therapy/features/views/download/download_page.dart';
import 'package:outdoor_therapy/features/views/favorite/favorite_screen.dart';
import 'package:outdoor_therapy/features/views/menu/menu_screen.dart';
import 'package:outdoor_therapy/features/views/now_playing/now_playing_screen.dart';
// import 'package:outdoor_therapy/features/widgets/custom_play_card.dart'; // Import the new widget
import '../../../core/app_colors.dart';
import '../../../core/widget/custom_play_card.dart';
import '../home/home_screen.dart';

class MainBottomNav extends StatefulWidget {
  const MainBottomNav({super.key});

  @override
  State<MainBottomNav> createState() => _MainBottomNavState();
}

class _MainBottomNavState extends State<MainBottomNav> {
  int _selectedIndex = 0;
  bool _isPlaying = true;
  bool _showMiniPlayer = true;

  final Map<String, dynamic>? _currentTrack = {
    'title': 'Soft Breeze',
    'subtitle': 'Meditation',
    'image': 'assets/gif/playing.gif',
    'duration': '2:25',
    'description': 'Beautiful meditation track',
    'category': 'meditation',
  };

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
      'fallbackIcon': Icons.home_outlined,
      'fallbackActiveIcon': Icons.home,
    },
    {
      'icon': 'assets/icons/browse_inactive.svg',
      'activeIcon': 'assets/icons/browse.svg',
      'label': 'Browse',
      'fallbackIcon': Icons.explore_outlined,
      'fallbackActiveIcon': Icons.explore,
    },
    {
      'icon': 'assets/icons/favorite_inactive.svg',
      'activeIcon': 'assets/icons/favorite.svg',
      'label': 'Favourites',
      'fallbackIcon': Icons.favorite_outline,
      'fallbackActiveIcon': Icons.favorite,
    },
    {
      'icon': 'assets/icons/download_inactive.svg',
      'activeIcon': 'assets/icons/download.svg',
      'label': 'Downloads',
      'fallbackIcon': Icons.download_outlined,
      'fallbackActiveIcon': Icons.download,
    },
    {
      'icon': 'assets/icons/menu_inactive.svg',
      'activeIcon': 'assets/icons/menu.svg',
      'label': 'Menu',
      'fallbackIcon': Icons.menu_outlined,
      'fallbackActiveIcon': Icons.menu,
    },
  ];

  void _onItemTapped(int index) => setState(() => _selectedIndex = index);
  void _togglePlayPause() => setState(() => _isPlaying = !_isPlaying);
  void _closePlayer() => setState(() => _showMiniPlayer = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_currentTrack != null && _showMiniPlayer)
            CustomPlayCard(
              track: _currentTrack!,
              isPlaying: _isPlaying,
              onPlayPause: _togglePlayPause,
              onClose: _closePlayer,
            ),
          _buildBottomNav(),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      height: 80,
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
                    width: 26,
                    height: 26,
                    child: SvgPicture.asset(
                      isSelected ? item['activeIcon'] : item['icon'],
                      width: 26,
                      height: 26,
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
*/













// main_bottom_nav.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:outdoor_therapy/features/views/browse/browse_screen.dart';
import 'package:outdoor_therapy/features/views/download/download_page.dart';
import 'package:outdoor_therapy/features/views/favorite/favorite_screen.dart';
import 'package:outdoor_therapy/features/views/menu/menu_screen.dart';
import 'package:outdoor_therapy/core/widget/custom_play_card.dart';
import 'package:outdoor_therapy/core/widget/player_controller.dart';
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


