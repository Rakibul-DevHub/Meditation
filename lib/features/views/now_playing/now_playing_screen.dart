import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/widget/player_controller.dart';
import '../../../model/category_model.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final PlayerController _playerController = Get.find<PlayerController>();
  
  bool isShuffled = false;
  bool isLooped = false;
  String? selectedSleepTimer;

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return "${twoDigits(minutes)}:${twoDigits(seconds)}";
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
                const SizedBox(height: 10),

                /// Album Art
                ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: CachedNetworkImage(
                    imageUrl: track.coverImageUrl ?? '',
                    width: double.infinity,
                    height: 340,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.white10),
                    errorWidget: (_, __, ___) => Container(color: Colors.white10, child: const Icon(Icons.music_note, color: Colors.white54, size: 50)),
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
                      icon: const Icon(Icons.favorite_border, color: Colors.white),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.cloud_download_outlined, color: Colors.white),
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
                        : 100, // Fallback if duration is unknown
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

                const SizedBox(height: 36),

                /// Controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.repeat,
                        color: isShuffled ? const Color(0xff6366F1) : const Color(0xff94A3B8),
                        size: 26,
                      ),
                      onPressed: () => setState(() => isShuffled = !isShuffled),
                    ),
                    const Icon(Icons.skip_previous, color: Colors.white, size: 32),

                    /// Play/Pause button
                    Container(
                      width: 70,
                      height: 70,
                      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                      child: _playerController.isLoading.value 
                        ? const Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator(color: Colors.black, strokeWidth: 3))
                        : IconButton(
                            icon: Icon(
                              _playerController.isPlaying.value ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 34,
                            ),
                            onPressed: _playerController.togglePlayPause,
                          ),
                    ),

                    const Icon(Icons.skip_next, color: Colors.white, size: 32),
                    IconButton(
                      icon: const Icon(Icons.volume_up, color: Color(0xff94A3B8), size: 26),
                      onPressed: () => setState(() => isLooped = !isLooped),
                    ),
                  ],
                ),

                const Spacer(),

                /// Sleep dropdown
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: const Color(0xff0F172A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xff1E293B)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      dropdownColor: const Color(0xff0F172A),
                      value: selectedSleepTimer,
                      hint: const Row(
                        children: [
                          Icon(Icons.bedtime, color: Color(0xff94A3B8), size: 18),
                          SizedBox(width: 10),
                          Text("Sleep", style: TextStyle(color: Color(0xff94A3B8), fontSize: 14)),
                        ],
                      ),
                      icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xff94A3B8)),
                      items: ["15 min", "30 min", "45 min", "1 hour", "End of track"].map((e) {
                        return DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(color: Colors.white)));
                      }).toList(),
                      onChanged: (value) => setState(() => selectedSleepTimer = value),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      }),
    );
  }
}