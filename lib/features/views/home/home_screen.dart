/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/app_colors.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../model/favorite_response_model.dart';
import '../now_playing/player_controller.dart';
import '../../../model/category_model.dart';
import '../../../features/views/now_playing/now_playing_screen.dart';
import '../favorite/favorite_screen_controller.dart';
import 'home_screen_controller.dart';
import '../menu/controller/menu_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String greeting = HomeScreen._getGreeting();
  final PlayerController _playerController = Get.find<PlayerController>();
  final HomeScreenController _controller = Get.put(HomeScreenController());
  late final FavoriteScreenController _favoriteController;
  late final MenuScreenController _menuController;
  final ScrollController _scrollController = ScrollController();
  final RxMap<String, bool> _localFavoriteStatus = <String, bool>{}.obs;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<FavoriteScreenController>()) {
      _favoriteController = Get.find<FavoriteScreenController>();
    } else {
      _favoriteController = Get.put(FavoriteScreenController());
    }
    if (Get.isRegistered<MenuScreenController>()) {
      _menuController = Get.find<MenuScreenController>();
    } else {
      _menuController = Get.put(MenuScreenController());
    }
    ever(_favoriteController.tracks, (_) => _syncFavoriteStatus());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _controller.fetchPopularSounds(isLoadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncFavoriteStatus() {
    for (var track in _controller.featuredTracks) {
      if (track.id != null) _localFavoriteStatus[track.id!] = _favoriteController.tracks.any((fav) => fav.id == track.id);
    }
    for (var track in _controller.sleepTonightTracks) {
      if (track.id != null) _localFavoriteStatus[track.id!] = _favoriteController.tracks.any((fav) => fav.id == track.id);
    }
    for (var track in _controller.popularTracks) {
      if (track.id != null) _localFavoriteStatus[track.id!] = _favoriteController.tracks.any((fav) => fav.id == track.id);
    }
  }

  void _playTrack(TrackModel track, List<TrackModel> playlist, int index) {
    _playerController.setPlaylist(playlist, initialIndex: index);
    Get.to(() => const NowPlayingScreen());
  }

  bool _isFavorite(String trackId) => _localFavoriteStatus[trackId] ?? false;

  Future<void> _toggleFavorite(TrackModel track) async {
    final trackId = track.id ?? '';
    if (trackId.isEmpty) return;
    final isCurrentlyFavorite = _isFavorite(trackId);
    _localFavoriteStatus[trackId] = !isCurrentlyFavorite;
    if (!isCurrentlyFavorite) {
      _favoriteController.tracks.insert(0, FavoriteTrack(
        id: trackId, title: track.title ?? 'Unknown', description: track.description,
        coverImageUrl: track.coverImageUrl, durationSeconds: track.durationSeconds,
        categoryName: track.categoryName, playCount: track.playCount ?? 0,
        downloadCount: track.downloadCount ?? 0, isFeatured: track.isFeatured ?? false,
        isSleepTonight: track.isSleepTonight ?? false, createdAt: DateTime.now(),
        updatedAt: DateTime.now(), categoryId: '', audioUrl: '',
      ));
    } else {
      _favoriteController.tracks.removeWhere((t) => t.id == trackId);
    }
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        _localFavoriteStatus[trackId] = isCurrentlyFavorite;
        Get.snackbar('Error', 'Please login again.', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      final networkCaller = NetworkCallerDio();
      if (isCurrentlyFavorite) {
        await networkCaller.postRequest(AppUrl.removeFavorites(trackId), body: {}, headers: {'Authorization': 'Bearer $token'});
      } else {
        await networkCaller.postRequest(AppUrl.addFavorites(trackId), body: {}, headers: {'Authorization': 'Bearer $token'});
      }
    } catch (e) {
      _localFavoriteStatus[trackId] = isCurrentlyFavorite;
      Get.snackbar('Error', 'Failed to update favorites', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _handlePlayButtonTap(TrackModel track, List<TrackModel> playlist, int index) => _playTrack(track, playlist, index);

  void _showSleepTimerSheet() => _menuController.showSleepTimerPicker(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refreshAllData,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(greeting, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                          Obx(() {
                            final timerLabel = _menuController.sleepTimer.value;
                            final isActive = timerLabel != 'Off';
                            return GestureDetector(
                              onTap: _showSleepTimerSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xff101828),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isActive ? const Color(0xFF6366F1) : const Color(0xff364153)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.watch_later_outlined, size: 16, color: isActive ? const Color(0xFF6366F1) : AppColors.whiteColor70),
                                    const SizedBox(width: 6),
                                    Text(timerLabel == 'Off' ? 'Sleep' : timerLabel, style: TextStyle(color: isActive ? const Color(0xFF6366F1) : AppColors.whiteColor70)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text("Time to unwind and relax", style: TextStyle(color: Color(0xff9AA4B2))),
                      const SizedBox(height: 30),
                      const SectionHeader(title: "Featured Sounds"),
                      const SizedBox(height: 16),
                      _buildFeaturedSection(),
                      const SizedBox(height: 30),
                      const SectionHeader(title: "Sleep Tonight"),
                      const SizedBox(height: 16),
                      _buildSleepSection(),
                      const SizedBox(height: 30),
                      const SectionHeader(title: "Popular Listening"),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildPopularSliverList(),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  if (_controller.isPaginatingPopular.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: _buildPopularShimmerItem(),
                    );
                  }
                  return const SizedBox(height: 40);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeaturedSection() {
    return Obx(() {
      if ((_controller.isLoadingFeatured.value && _controller.featuredTracks.isEmpty) || _controller.isRefreshingFeatured.value) return _buildFeaturedShimmer();
      if (_controller.featuredTracks.isEmpty) return const SizedBox(height: 180, child: Center(child: Text('No featured sounds available', style: TextStyle(color: Colors.white54))));
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _controller.featuredTracks.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final track = _controller.featuredTracks[index];
            return GestureDetector(
              onTap: () => _playTrack(track, _controller.featuredTracks, index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: track.coverImageUrl ?? '', fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.grey800, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        errorWidget: (_, __, ___) => Container(color: AppColors.grey800, child: const Icon(Icons.music_note, color: Colors.white54)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(width: 120, child: Text(track.title ?? 'Unknown', style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(_controller.formatDuration(track.durationSeconds), style: const TextStyle(color: Color(0xff9AA4B2), fontSize: 12)),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSleepSection() {
    return Obx(() {
      if ((_controller.isLoadingSleep.value && _controller.sleepTonightTracks.isEmpty) || _controller.isRefreshingSleep.value) return _buildSleepShimmer();
      if (_controller.sleepTonightTracks.isEmpty) return const SizedBox(height: 180, child: Center(child: Text('No sleep sounds available', style: TextStyle(color: Colors.white54))));
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _controller.sleepTonightTracks.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final track = _controller.sleepTonightTracks[index];
            return GestureDetector(
              onTap: () => _playTrack(track, _controller.sleepTonightTracks, index),
              child: SleepCard(title: track.title ?? 'Unknown', duration: _controller.formatDuration(track.durationSeconds), image: track.coverImageUrl ?? '', width: 110, height: 110),
            );
          },
        ),
      );
    });
  }

  Widget _buildPopularSliverList() {
    return Obx(() {
      if ((_controller.isLoadingPopular.value && _controller.popularTracks.isEmpty) || _controller.isRefreshingPopular.value) return _buildPopularShimmer();
      if (_controller.popularTracks.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No popular tracks available', style: TextStyle(color: Colors.white54)))));
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final track = _controller.popularTracks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Obx(() {
              final isFav = _isFavorite(track.id ?? '');
              final isCurrentTrack = _playerController.currentTrack.value?.id == track.id;
              final isPlaying = _playerController.isPlaying.value;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _playTrack(track, _controller.popularTracks, index),
                    child: Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: track.coverImageUrl ?? '', fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.grey800, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (_, __, ___) => Container(color: AppColors.grey800, child: const Icon(Icons.music_note, color: Colors.white54)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _playTrack(track, _controller.popularTracks, index),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.title ?? 'Unknown Track', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text("${_controller.getCategoryName(track)} • ${_controller.formatDuration(track.durationSeconds)}", style: const TextStyle(color: Color(0xff9AA4B2), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handlePlayButtonTap(track, _controller.popularTracks, index),
                    child: Container(padding: const EdgeInsets.all(8), child: Icon((isCurrentTrack && isPlaying) ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.whiteColor70, size: 30)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _toggleFavorite(track),
                    child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? const Color(0xFF7B61FF) : AppColors.whiteColor70, size: 24),
                  ),
                ],
              );
            }),
          );
        }, childCount: _controller.popularTracks.length),
      );
    });
  }

  Widget _buildFeaturedShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: AppColors.grey850!, highlightColor: AppColors.grey800!,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 120, height: 120, decoration: BoxDecoration(color: AppColors.grey800, borderRadius: BorderRadius.circular(18))),
            const SizedBox(height: 6),
            Container(width: 100, height: 14, color: AppColors.grey800),
            const SizedBox(height: 4),
            Container(width: 60, height: 12, color: AppColors.grey800),
          ]),
        ),
      ),
    );
  }

  Widget _buildSleepShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: AppColors.grey850!, highlightColor: AppColors.grey800!,
          child: SizedBox(width: 110, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 110, width: 110, decoration: BoxDecoration(color: AppColors.grey800, borderRadius: BorderRadius.circular(18))),
            const SizedBox(height: 6),
            Container(width: 90, height: 14, color: AppColors.grey800),
            const SizedBox(height: 4),
            Container(width: 50, height: 12, color: AppColors.grey800),
          ])),
        ),
      ),
    );
  }

  Widget _buildPopularShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildPopularShimmerItem(),
      ), childCount: 5),
    );
  }

  Widget _buildPopularShimmerItem() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey850!, highlightColor: AppColors.grey800!,
      child: Row(children: [
        Container(width: 55, height: 55, decoration: BoxDecoration(color: AppColors.grey800, borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 150, height: 14, color: AppColors.grey800),
          const SizedBox(height: 6),
          Container(width: 100, height: 12, color: AppColors.grey800),
        ])),
        Container(width: 30, height: 30, decoration:  BoxDecoration(color: AppColors.grey800, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Container(width: 24, height: 24, color: AppColors.grey800),
      ]),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600));
  }
}

class SleepCard extends StatelessWidget {
  final String title, duration, image;
  final double width, height;
  const SleepCard({super.key, required this.title, required this.duration, required this.image, required this.width, required this.height});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: height, width: width, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)), child: ClipRRect(
        borderRadius: BorderRadius.circular(18), child: CachedNetworkImage(
          imageUrl: image, fit: BoxFit.cover, placeholder: (_, __) => Container(color: AppColors.grey800, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
          errorWidget: (_, __, ___) => Container(color: AppColors.grey800, child: const Icon(Icons.music_note, color: Colors.white54)),
        ),
      )),
      const SizedBox(height: 6),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
      Text(duration, style: const TextStyle(color: Color(0xff9AA4B2), fontSize: 12)),
    ]));
  }
}
*/









import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/app_colors.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../model/favorite_response_model.dart';
import '../now_playing/player_controller.dart';
import '../../../model/category_model.dart';
import '../../../features/views/now_playing/now_playing_screen.dart';
import '../favorite/favorite_screen_controller.dart';
import 'home_screen_controller.dart';
import '../menu/controller/menu_screen_controller.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String greeting = HomeScreen._getGreeting();
  final PlayerController _playerController = Get.find<PlayerController>();

  // ✅ Get the controller but don't call fetchAllData here - it's handled in onInit
  late final HomeScreenController _controller;
  late final FavoriteScreenController _favoriteController;
  late final MenuScreenController _menuController;
  final ScrollController _scrollController = ScrollController();
  final RxMap<String, bool> _localFavoriteStatus = <String, bool>{}.obs;

  @override
  void initState() {
    super.initState();
    // ✅ Get or put the controller - this will call onInit which fetches data
    if (Get.isRegistered<HomeScreenController>()) {
      _controller = Get.find<HomeScreenController>();
    } else {
      _controller = Get.put(HomeScreenController());
    }

    if (Get.isRegistered<FavoriteScreenController>()) {
      _favoriteController = Get.find<FavoriteScreenController>();
    } else {
      _favoriteController = Get.put(FavoriteScreenController());
    }
    if (Get.isRegistered<MenuScreenController>()) {
      _menuController = Get.find<MenuScreenController>();
    } else {
      _menuController = Get.put(MenuScreenController());
    }
    ever(_favoriteController.tracks, (_) => _syncFavoriteStatus());
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        _controller.fetchPopularSounds(isLoadMore: true);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _syncFavoriteStatus() {
    for (var track in _controller.featuredTracks) {
      if (track.id != null) _localFavoriteStatus[track.id!] = _favoriteController.tracks.any((fav) => fav.id == track.id);
    }
    for (var track in _controller.sleepTonightTracks) {
      if (track.id != null) _localFavoriteStatus[track.id!] = _favoriteController.tracks.any((fav) => fav.id == track.id);
    }
    for (var track in _controller.popularTracks) {
      if (track.id != null) _localFavoriteStatus[track.id!] = _favoriteController.tracks.any((fav) => fav.id == track.id);
    }
  }

  void _playTrack(TrackModel track, List<TrackModel> playlist, int index) {
    _playerController.setPlaylist(playlist, initialIndex: index);
    Get.to(() => const NowPlayingScreen());
  }

  bool _isFavorite(String trackId) => _localFavoriteStatus[trackId] ?? false;

  Future<void> _toggleFavorite(TrackModel track) async {
    final trackId = track.id ?? '';
    if (trackId.isEmpty) return;
    final isCurrentlyFavorite = _isFavorite(trackId);
    _localFavoriteStatus[trackId] = !isCurrentlyFavorite;
    if (!isCurrentlyFavorite) {
      _favoriteController.tracks.insert(0, FavoriteTrack(
        id: trackId, title: track.title ?? 'Unknown', description: track.description,
        coverImageUrl: track.coverImageUrl, durationSeconds: track.durationSeconds,
        categoryName: track.categoryName, playCount: track.playCount ?? 0,
        downloadCount: track.downloadCount ?? 0, isFeatured: track.isFeatured ?? false,
        isSleepTonight: track.isSleepTonight ?? false, createdAt: DateTime.now(),
        updatedAt: DateTime.now(), categoryId: '', audioUrl: '',
      ));
    } else {
      _favoriteController.tracks.removeWhere((t) => t.id == trackId);
    }
    try {
      final token = await SecureStorageService.instance.getAccessToken();
      if (token == null) {
        _localFavoriteStatus[trackId] = isCurrentlyFavorite;
        Get.snackbar('Error', 'Please login again.', backgroundColor: Colors.red, colorText: Colors.white);
        return;
      }
      final networkCaller = NetworkCallerDio();
      if (isCurrentlyFavorite) {
        await networkCaller.postRequest(AppUrl.removeFavorites(trackId), body: {}, headers: {'Authorization': 'Bearer $token'});
      } else {
        await networkCaller.postRequest(AppUrl.addFavorites(trackId), body: {}, headers: {'Authorization': 'Bearer $token'});
      }
    } catch (e) {
      _localFavoriteStatus[trackId] = isCurrentlyFavorite;
      Get.snackbar('Error', 'Failed to update favorites', backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  void _handlePlayButtonTap(TrackModel track, List<TrackModel> playlist, int index) => _playTrack(track, playlist, index);

  void _showSleepTimerSheet() => _menuController.showSleepTimerPicker(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refreshAllData,
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(greeting, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white)),
                          Obx(() {
                            final timerLabel = _menuController.sleepTimer.value;
                            final isActive = timerLabel != 'Off';
                            return GestureDetector(
                              onTap: _showSleepTimerSheet,
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xff101828),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: isActive ? const Color(0xFF6366F1) : const Color(0xff364153)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.watch_later_outlined, size: 16, color: isActive ? const Color(0xFF6366F1) : AppColors.whiteColor70),
                                    const SizedBox(width: 6),
                                    Text(timerLabel == 'Off' ? 'Sleep' : timerLabel, style: TextStyle(color: isActive ? const Color(0xFF6366F1) : AppColors.whiteColor70)),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Text("Time to unwind and relax", style: TextStyle(color: Color(0xff9AA4B2))),
                      const SizedBox(height: 30),
                      const SectionHeader(title: "Featured Sounds"),
                      const SizedBox(height: 16),
                      _buildFeaturedSection(),
                      const SizedBox(height: 30),
                      const SectionHeader(title: "Sleep Tonight"),
                      const SizedBox(height: 16),
                      _buildSleepSection(),
                      const SizedBox(height: 30),
                      const SectionHeader(title: "Popular Listening"),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                sliver: _buildPopularSliverList(),
              ),
              SliverToBoxAdapter(
                child: Obx(() {
                  if (_controller.isPaginatingPopular.value) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      child: _buildPopularShimmerItem(),
                    );
                  }
                  return const SizedBox(height: 40);
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ... rest of the widget methods remain the same ...
  Widget _buildFeaturedSection() {
    return Obx(() {
      if ((_controller.isLoadingFeatured.value && _controller.featuredTracks.isEmpty) || _controller.isRefreshingFeatured.value) return _buildFeaturedShimmer();
      if (_controller.featuredTracks.isEmpty) return const SizedBox(height: 180, child: Center(child: Text('No featured sounds available', style: TextStyle(color: Colors.white54))));
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _controller.featuredTracks.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final track = _controller.featuredTracks[index];
            return GestureDetector(
              onTap: () => _playTrack(track, _controller.featuredTracks, index),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(18),
                      child: CachedNetworkImage(
                        imageUrl: track.coverImageUrl ?? '', fit: BoxFit.cover,
                        placeholder: (_, __) => Container(color: AppColors.grey800, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                        errorWidget: (_, __, ___) => Container(color: AppColors.grey800, child: const Icon(Icons.music_note, color: Colors.white54)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(width: 120, child: Text(track.title ?? 'Unknown', style: const TextStyle(color: Colors.white), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  Text(_controller.formatDuration(track.durationSeconds), style: const TextStyle(color: Color(0xff9AA4B2), fontSize: 12)),
                ],
              ),
            );
          },
        ),
      );
    });
  }

  Widget _buildSleepSection() {
    return Obx(() {
      if ((_controller.isLoadingSleep.value && _controller.sleepTonightTracks.isEmpty) || _controller.isRefreshingSleep.value) return _buildSleepShimmer();
      if (_controller.sleepTonightTracks.isEmpty) return const SizedBox(height: 180, child: Center(child: Text('No sleep sounds available', style: TextStyle(color: Colors.white54))));
      return SizedBox(
        height: 180,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: _controller.sleepTonightTracks.length,
          separatorBuilder: (_, __) => const SizedBox(width: 14),
          itemBuilder: (context, index) {
            final track = _controller.sleepTonightTracks[index];
            return GestureDetector(
              onTap: () => _playTrack(track, _controller.sleepTonightTracks, index),
              child: SleepCard(title: track.title ?? 'Unknown', duration: _controller.formatDuration(track.durationSeconds), image: track.coverImageUrl ?? '', width: 110, height: 110),
            );
          },
        ),
      );
    });
  }

  Widget _buildPopularSliverList() {
    return Obx(() {
      if ((_controller.isLoadingPopular.value && _controller.popularTracks.isEmpty) || _controller.isRefreshingPopular.value) return _buildPopularShimmer();
      if (_controller.popularTracks.isEmpty) return const SliverToBoxAdapter(child: Center(child: Padding(padding: EdgeInsets.all(32), child: Text('No popular tracks available', style: TextStyle(color: Colors.white54)))));
      return SliverList(
        delegate: SliverChildBuilderDelegate((context, index) {
          final track = _controller.popularTracks[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Obx(() {
              final isFav = _isFavorite(track.id ?? '');
              final isCurrentTrack = _playerController.currentTrack.value?.id == track.id;
              final isPlaying = _playerController.isPlaying.value;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () => _playTrack(track, _controller.popularTracks, index),
                    child: Container(
                      width: 55, height: 55,
                      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl: track.coverImageUrl ?? '', fit: BoxFit.cover,
                          placeholder: (_, __) => Container(color: AppColors.grey800, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
                          errorWidget: (_, __, ___) => Container(color: AppColors.grey800, child: const Icon(Icons.music_note, color: Colors.white54)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _playTrack(track, _controller.popularTracks, index),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(track.title ?? 'Unknown Track', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w500), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 3),
                          Text("${_controller.getCategoryName(track)} • ${_controller.formatDuration(track.durationSeconds)}", style: const TextStyle(color: Color(0xff9AA4B2), fontSize: 12)),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _handlePlayButtonTap(track, _controller.popularTracks, index),
                    child: Container(padding: const EdgeInsets.all(8), child: Icon((isCurrentTrack && isPlaying) ? Icons.pause_rounded : Icons.play_arrow_rounded, color: AppColors.whiteColor70, size: 30)),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => _toggleFavorite(track),
                    child: Icon(isFav ? Icons.favorite : Icons.favorite_border, color: isFav ? const Color(0xFF7B61FF) : AppColors.whiteColor70, size: 24),
                  ),
                ],
              );
            }),
          );
        }, childCount: _controller.popularTracks.length),
      );
    });
  }

  Widget _buildFeaturedShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: AppColors.grey850!, highlightColor: AppColors.grey800!,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(width: 120, height: 120, decoration: BoxDecoration(color: AppColors.grey800, borderRadius: BorderRadius.circular(18))),
            const SizedBox(height: 6),
            Container(width: 100, height: 14, color: AppColors.grey800),
            const SizedBox(height: 4),
            Container(width: 60, height: 12, color: AppColors.grey800),
          ]),
        ),
      ),
    );
  }

  Widget _buildSleepShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal, itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: AppColors.grey850!, highlightColor: AppColors.grey800!,
          child: SizedBox(width: 110, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(height: 110, width: 110, decoration: BoxDecoration(color: AppColors.grey800, borderRadius: BorderRadius.circular(18))),
            const SizedBox(height: 6),
            Container(width: 90, height: 14, color: AppColors.grey800),
            const SizedBox(height: 4),
            Container(width: 50, height: 12, color: AppColors.grey800),
          ])),
        ),
      ),
    );
  }

  Widget _buildPopularShimmer() {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: _buildPopularShimmerItem(),
      ), childCount: 5),
    );
  }

  Widget _buildPopularShimmerItem() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey850!, highlightColor: AppColors.grey800!,
      child: Row(children: [
        Container(width: 55, height: 55, decoration: BoxDecoration(color: AppColors.grey800, borderRadius: BorderRadius.circular(10))),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 150, height: 14, color: AppColors.grey800),
          const SizedBox(height: 6),
          Container(width: 100, height: 12, color: AppColors.grey800),
        ])),
        Container(width: 30, height: 30, decoration:  BoxDecoration(color: AppColors.grey800, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Container(width: 24, height: 24, color: AppColors.grey800),
      ]),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  const SectionHeader({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Text(title, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600));
  }
}

class SleepCard extends StatelessWidget {
  final String title, duration, image;
  final double width, height;
  const SleepCard({super.key, required this.title, required this.duration, required this.image, required this.width, required this.height});
  @override
  Widget build(BuildContext context) {
    return SizedBox(width: width, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(height: height, width: width, decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)), child: ClipRRect(
        borderRadius: BorderRadius.circular(18), child: CachedNetworkImage(
        imageUrl: image, fit: BoxFit.cover, placeholder: (_, __) => Container(color: AppColors.grey800, child: const Center(child: CircularProgressIndicator(strokeWidth: 2))),
        errorWidget: (_, __, ___) => Container(color: AppColors.grey800, child: const Icon(Icons.music_note, color: Colors.white54)),
      ),
      )),
      const SizedBox(height: 6),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
      Text(duration, style: const TextStyle(color: Color(0xff9AA4B2), fontSize: 12)),
    ]));
  }
}