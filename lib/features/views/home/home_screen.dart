import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/app_colors.dart';
import '../../../core/widget/player_controller.dart';
import '../../../model/category_model.dart';
import '../../../features/views/now_playing/now_playing_screen.dart';
import 'home_screen_controller.dart';

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

  void _playTrack(TrackModel track, List<TrackModel> playlist, int index) {
    _playerController.setPlaylist(playlist, initialIndex: index);
    Get.to(() => const NowPlayingScreen());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _controller.refreshAllData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),

                /// Greeting
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      greeting,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xff101828),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xff364153)),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.watch_later_outlined, size: 16, color: AppColors.whiteColor70),
                          SizedBox(width: 6),
                          Text("Sleep", style: TextStyle(color: AppColors.whiteColor70)),
                        ],
                      ),
                    )
                  ],
                ),

                const SizedBox(height: 6),

                const Text(
                  "Time to unwind and relax",
                  style: TextStyle(color: Color(0xff9AA4B2)),
                ),

                const SizedBox(height: 30),

                /// Featured Sounds - Horizontal Scroll
                const SectionHeader(title: "Featured Sounds"),
                const SizedBox(height: 16),

                Obx(() {
                  final shouldShowShimmer = (_controller.isLoadingFeatured.value && _controller.featuredTracks.isEmpty) ||
                      _controller.isRefreshingFeatured.value;

                  if (shouldShowShimmer) {
                    return _buildFeaturedShimmer();
                  }

                  if (_controller.featuredError.isNotEmpty && _controller.featuredTracks.isEmpty) {
                    return SizedBox(
                      height: 180,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _controller.featuredError.value,
                              style: const TextStyle(color: AppColors.whiteColor70),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _controller.fetchFeaturedSounds(),
                              child: const Text('Retry', style: TextStyle(color: Color(0xFF6C5ECF))),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_controller.featuredTracks.isEmpty) {
                    return SizedBox(
                      height: 180,
                      child: const Center(
                        child: Text(
                          'No featured sounds available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }

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
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(18),
                                  child: CachedNetworkImage(
                                    imageUrl: track.coverImageUrl ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      color: AppColors.grey800,
                                      child: const Center(
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      ),
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      color: AppColors.grey800,
                                      child: const Icon(Icons.music_note, color: Colors.white54),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6),
                              SizedBox(
                                width: 120,
                                child: Text(
                                  track.title ?? 'Unknown',
                                  style: const TextStyle(color: Colors.white),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                _controller.formatDuration(track.durationSeconds),
                                style: const TextStyle(
                                  color: Color(0xff9AA4B2),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 30),

                /// Sleep Tonight - Horizontal Scroll
                const SectionHeader(title: "Sleep Tonight"),
                const SizedBox(height: 16),

                Obx(() {
                  final shouldShowShimmer = (_controller.isLoadingSleep.value && _controller.sleepTonightTracks.isEmpty) ||
                      _controller.isRefreshingSleep.value;

                  if (shouldShowShimmer) {
                    return _buildSleepShimmer();
                  }

                  if (_controller.sleepError.isNotEmpty && _controller.sleepTonightTracks.isEmpty) {
                    return SizedBox(
                      height: 180,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _controller.sleepError.value,
                              style: const TextStyle(color: AppColors.whiteColor70),
                            ),
                            const SizedBox(height: 8),
                            TextButton(
                              onPressed: () => _controller.fetchSleepTonight(),
                              child: const Text('Retry', style: TextStyle(color: Color(0xFF6C5ECF))),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (_controller.sleepTonightTracks.isEmpty) {
                    return SizedBox(
                      height: 180,
                      child: const Center(
                        child: Text(
                          'No sleep sounds available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }

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
                          child: SleepCard(
                            title: track.title ?? 'Unknown',
                            duration: _controller.formatDuration(track.durationSeconds),
                            image: track.coverImageUrl ?? '',
                            width: 110,
                            height: 110,
                          ),
                        );
                      },
                    ),
                  );
                }),

                const SizedBox(height: 30),

                /// Popular Listening - Vertical Scroll
                const SectionHeader(title: "Popular Listening"),
                const SizedBox(height: 16),

                Obx(() {
                  final shouldShowShimmer = (_controller.isLoadingPopular.value && _controller.popularTracks.isEmpty) ||
                      _controller.isRefreshingPopular.value;

                  if (shouldShowShimmer) {
                    return _buildPopularShimmer();
                  }

                  if (_controller.popularError.isNotEmpty && _controller.popularTracks.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _controller.popularError.value,
                            style: const TextStyle(color: AppColors.whiteColor70),
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => _controller.fetchPopularSounds(),
                            child: const Text('Retry', style: TextStyle(color: Color(0xFF6C5ECF))),
                          ),
                        ],
                      ),
                    );
                  }

                  if (_controller.popularTracks.isEmpty) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No popular tracks available',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _controller.popularTracks.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final track = _controller.popularTracks[index];
                      return GestureDetector(
                        onTap: () => _playTrack(track, _controller.popularTracks, index),
                        child: Row(
                          children: [
                            Container(
                              width: 55,
                              height: 55,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: CachedNetworkImage(
                                  imageUrl: track.coverImageUrl ?? '',
                                  fit: BoxFit.cover,
                                  placeholder: (_, __) => Container(
                                    color: AppColors.grey800,
                                    child: const Center(
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (_, __, ___) => Container(
                                    color: AppColors.grey800,
                                    child: const Icon(Icons.music_note, color: Colors.white54),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    track.title ?? 'Unknown Track',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    "${_controller.getCategoryName(track)} • ${_controller.formatDuration(track.durationSeconds)}",
                                    style: const TextStyle(
                                      color: Color(0xff9AA4B2),
                                      fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            ),
                            // Play/Pause icon based on current playing track
                            Obx(() {
                              final isCurrentTrack = _playerController.currentTrack.value?.id == track.id;
                              final isPlaying = _playerController.isPlaying.value;

                              return Icon(
                                (isCurrentTrack && isPlaying) ? Icons.pause_rounded : Icons.play_arrow_rounded,
                                color: AppColors.whiteColor70,
                                size: 30,
                              );
                            }),
                            const SizedBox(width: 12),
                            const Icon(Icons.favorite_border, color: AppColors.whiteColor70),
                          ],
                        ),
                      );
                    },
                  );
                }),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Shimmer for Featured Sounds section
  Widget _buildFeaturedShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.grey850!,
            highlightColor: AppColors.grey800!,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.grey800,
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  width: 100,
                  height: 14,
                  color: AppColors.grey800,
                ),
                const SizedBox(height: 4),
                Container(
                  width: 60,
                  height: 12,
                  color: AppColors.grey800,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Shimmer for Sleep Tonight section
  Widget _buildSleepShimmer() {
    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 5,
        separatorBuilder: (_, __) => const SizedBox(width: 14),
        itemBuilder: (context, index) {
          return Shimmer.fromColors(
            baseColor: AppColors.grey850!,
            highlightColor: AppColors.grey800!,
            child: SizedBox(
              width: 110,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 110,
                    width: 110,
                    decoration: BoxDecoration(
                      color: AppColors.grey800,
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    width: 90,
                    height: 14,
                    color: AppColors.grey800,
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 50,
                    height: 12,
                    color: AppColors.grey800,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // Shimmer for Popular Listening section
  Widget _buildPopularShimmer() {
    return Column(
      children: List.generate(
        5,
            (index) => Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Shimmer.fromColors(
            baseColor: AppColors.grey850!,
            highlightColor: AppColors.grey800!,
            child: Row(
              children: [
                Container(
                  width: 55,
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppColors.grey800,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: AppColors.grey800,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 120,
                        height: 12,
                        color: AppColors.grey800,
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 24,
                  height: 24,
                  color: AppColors.grey800,
                ),
                const SizedBox(width: 12),
                Container(
                  width: 24,
                  height: 24,
                  color: AppColors.grey800,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class SleepCard extends StatelessWidget {
  final String title;
  final String duration;
  final String image;
  final double width;
  final double height;

  const SleepCard({
    super.key,
    required this.title,
    required this.duration,
    required this.image,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: height,
            width: width,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: AppColors.grey800,
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  color: AppColors.grey800,
                  child: const Icon(Icons.music_note, color: Colors.white54),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            duration,
            style: const TextStyle(
              color: Color(0xff9AA4B2),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}