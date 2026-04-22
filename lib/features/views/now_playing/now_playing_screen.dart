import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/app_colors.dart';
import '../../../core/widget/player_controller.dart';
import '../../../model/category_model.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  
  String? selectedSleepTimer = "Off";

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
  }

  void _showSleepTimerSheet() {
    final List<String> timers = ["Off", "15 min", "30 min", "45 min", "1 hour"];
    
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xff0F172A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bedtime, color: Colors.white, size: 18),
                  SizedBox(width: 10),
                  Text(
                    "Sleep time",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              const Divider(color: Color(0xff1E293B)),
              ...timers.map((timer) => ListTile(
                title: Text(
                  timer,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: selectedSleepTimer == timer ? const Color(0xff6366F1) : Colors.white70,
                    fontSize: 16,
                    fontWeight: selectedSleepTimer == timer ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
                onTap: () {
                  setState(() {
                    selectedSleepTimer = timer;
                  });
                  Navigator.pop(context);
                },
              )),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff020617),
      appBar: AppBar(
        backgroundColor: const Color(0xff020617),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Now Playing",
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Obx(() {
        final track = _playerController.currentTrack.value;
        if (track == null) {
          return const Center(child: Text("No track selected", style: TextStyle(color: Colors.white)));
        }

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),

                /// Album Art
                Hero(
                  tag: 'track-image-${track.id}',
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: CachedNetworkImage(
                      imageUrl: track.coverImageUrl ?? '',
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.fill,
                      placeholder: (_, __) => Container(color: Colors.white10),
                      errorWidget: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.music_note, color: Colors.white54, size: 50)),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                /// Title + icons
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              track.title ?? 'Unknown Track',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              track.categoryName ?? '',
                              style: const TextStyle(
                                color: Color(0xff94A3B8),
                                fontSize: 14,
                              ),
                            ),
                          ]),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_border, color: AppColors.lightGreyColor),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.cloud_download_outlined, color: AppColors.lightGreyColor),
                      onPressed: () {},
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// Progress bar
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: const Color(0xff6366F1),
                    inactiveTrackColor: const Color(0xff1E293B),
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                    overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
                  ),
                  child: Slider(
                    value: _playerController.position.value.inSeconds.toDouble().clamp(0, _playerController.duration.value.inSeconds.toDouble()),
                    max: _playerController.duration.value.inSeconds.toDouble() > 0 
                        ? _playerController.duration.value.inSeconds.toDouble() 
                        : 100,
                    onChanged: (value) {
                      _playerController.seek(Duration(seconds: value.toInt()));
                    },
                  ),
                ),

                /// Time labels
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(_playerController.position.value),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                    Text(
                      _formatDuration(_playerController.duration.value),
                      style: const TextStyle(color: Color(0xff94A3B8), fontSize: 12),
                    ),
                  ],
                ),

                const SizedBox(height: 40),

                /// Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Playback Mode Toggle (Shuffle/Repeat/Continuous)
                    IconButton(
                      icon: Icon(
                        _getPlaybackIcon(),
                        color: _playerController.playbackMode.value == PlaybackMode.continuous 
                            ? AppColors.lightGreyColor 
                            : const Color(0xff6366F1),
                        size: 26,
                      ),
                      onPressed: _playerController.cyclePlaybackMode,
                    ),

                    // Previous Button
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 32),
                      onPressed: _playerController.playPrevious,
                    ),

                    /// Play/Pause button
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: _playerController.isLoading.value 
                        ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                        : IconButton(
                            icon: Icon(
                              _playerController.isPlaying.value ? Icons.pause_rounded : Icons.play_arrow_rounded,
                              color: Colors.black,
                              size: 34,
                            ),
                            onPressed: _playerController.togglePlayPause,
                          ),
                    ),

                    // Next Button
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 32),
                      onPressed: _playerController.playNext,
                    ),

                    // Sleep Timer Icon Button
                    IconButton(
                      icon: Icon(
                        Icons.timer_outlined, 
                        color: selectedSleepTimer != "Off" ? const Color(0xff6366F1) : AppColors.lightGreyColor, 
                        size: 26
                      ),
                      onPressed: _showSleepTimerSheet,
                    ),
                  ],
                ),

                const Spacer(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }

  IconData _getPlaybackIcon() {
    switch (_playerController.playbackMode.value) {
      case PlaybackMode.shuffle:
        return Icons.shuffle_rounded;
      case PlaybackMode.repeatOne:
        return Icons.repeat_one_rounded;
      case PlaybackMode.continuous:
      default:
        return Icons.repeat_rounded;
    }
  }
}
