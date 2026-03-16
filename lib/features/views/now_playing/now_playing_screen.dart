/**
import 'package:flutter/material.dart';
import 'package:outdoor_therapy/core/app_colors.dart';

class NowPlayingScreen extends StatefulWidget {
  final String title;
  final String image;
  final String duration;
  final String description;
  final String category;

  const NowPlayingScreen({
    super.key,
    required this.title,
    required this.image,
    required this.duration,
    required this.description,
    required this.category,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool isPlaying = true;
  bool isShuffled = false;
  bool isLooped = false;
  Duration currentPosition = const Duration(minutes: 10, seconds: 35);
  Duration totalDuration = const Duration(minutes: 45);
  String? selectedSleepTimer;

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  void _toggleShuffle() {
    setState(() {
      isShuffled = !isShuffled;
    });
  }

  void _toggleLoop() {
    setState(() {
      isLooped = !isLooped;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${twoDigits(hours)}:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        centerTitle: true,
        title: Text(
          'Now Playing',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Album Art
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Large Album Art
                    Container(
                      width: double.infinity,
                      height: 350,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        image: DecorationImage(
                          image: AssetImage(widget.image),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Title and Actions
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                widget.description,
                                style: const TextStyle(
                                  color: Color(0xff9AA4B2),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_border, color: Colors.white),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: const Icon(Icons.cloud_download, color: Colors.white),
                          onPressed: () {},
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Progress Bar
                    Column(
                      children: [
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            trackHeight: 4,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 6,
                            ),
                            overlayShape: const RoundSliderOverlayShape(
                              overlayRadius: 14,
                            ),
                            activeTrackColor: AppColors.primaryColor,
                            inactiveTrackColor: const Color(0xff1E293B),
                            thumbColor: Colors.white,
                            overlayColor: Colors.blue.withOpacity(0.2),
                          ),
                          child: Slider(
                            value: currentPosition.inSeconds.toDouble(),
                            max: totalDuration.inSeconds.toDouble(),
                            onChanged: (value) {
                              setState(() {
                                currentPosition = Duration(seconds: value.toInt());
                              });
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(currentPosition),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                _formatDuration(totalDuration),
                                style: const TextStyle(
                                  color: Color(0xff9AA4B2),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Playback Controls
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // Shuffle
                        IconButton(
                          icon: Icon(
                            Icons.shuffle,
                            color: isShuffled ? Colors.blue : Colors.white54,
                            size: 28,
                          ),
                          onPressed: _toggleShuffle,
                        ),

                        // Previous
                        IconButton(
                          icon: const Icon(
                            Icons.skip_previous,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () {},
                        ),

                        // Play/Pause Button
                        Container(
                          width: 72,
                          height: 72,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.black,
                              size: 36,
                            ),
                            onPressed: _togglePlayPause,
                          ),
                        ),

                        // Next
                        IconButton(
                          icon: const Icon(
                            Icons.skip_next,
                            color: Colors.white,
                            size: 36,
                          ),
                          onPressed: () {},
                        ),

                        // Loop/Repeat
                        IconButton(
                          icon: Icon(
                            isLooped ? Icons.loop : Icons.repeat,
                            color: isLooped ? Colors.blue : Colors.white54,
                            size: 28,
                          ),
                          onPressed: _toggleLoop,
                        ),
                      ],
                    ),

                    const SizedBox(height: 40),

                    // Sleep Timer Dropdown
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xff1E293B),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xff334155)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSleepTimer,
                          hint: const Row(
                            children: [
                              Icon(
                                Icons.bedtime,
                                color: Color(0xff9AA4B2),
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Sleep',
                                style: TextStyle(
                                  color: Color(0xff9AA4B2),
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                          dropdownColor: const Color(0xff1E293B),
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: Color(0xff9AA4B2),
                          ),
                          items: [
                            '15 min',
                            '30 min',
                            '45 min',
                            '1 hour',
                            'End of track',
                          ].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(
                                value,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedSleepTimer = newValue;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/










import 'package:flutter/material.dart';
import 'package:outdoor_therapy/core/app_colors.dart';

class NowPlayingScreen extends StatefulWidget {
  final String title;
  final String image;
  final String duration;
  final String description;
  final String category;

  const NowPlayingScreen({
    super.key,
    required this.title,
    required this.image,
    required this.duration,
    required this.description,
    required this.category,
  });

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  bool isPlaying = true;
  bool isShuffled = false;
  bool isLooped = false;

  Duration currentPosition = const Duration(minutes: 10, seconds: 35);
  Duration totalDuration = const Duration(minutes: 45);

  String? selectedSleepTimer;

  void _togglePlayPause() {
    setState(() {
      isPlaying = !isPlaying;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60);
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

      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SizedBox(height: 10),

              /// Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset(
                  widget.image,
                  width: double.infinity,
                  height: 340,
                  fit: BoxFit.cover,
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
                            widget.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.description,
                            style: const TextStyle(
                              color: Color(0xff94A3B8),
                              fontSize: 14,
                            ),
                          ),
                        ]),
                  ),
                  IconButton(
                    icon: const Icon(Icons.favorite_border,
                        color: Colors.white),
                    onPressed: () {},
                  ),
                  IconButton(
                    icon: const Icon(Icons.cloud_download_outlined,
                        color: Colors.white),
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
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 6,
                  ),
                  overlayShape:
                  const RoundSliderOverlayShape(overlayRadius: 14),
                ),
                child: Slider(
                  value: currentPosition.inSeconds.toDouble(),
                  max: totalDuration.inSeconds.toDouble(),
                  onChanged: (value) {
                    setState(() {
                      currentPosition = Duration(seconds: value.toInt());
                    });
                  },
                ),
              ),

              /// Time labels
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    _formatDuration(currentPosition),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatDuration(totalDuration),
                    style: const TextStyle(
                      color: Color(0xff94A3B8),
                      fontSize: 12,
                    ),
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
                      color: isShuffled
                          ? const Color(0xff6366F1)
                          : const Color(0xff94A3B8),
                      size: 26,
                    ),
                    onPressed: () {
                      setState(() {
                        isShuffled = !isShuffled;
                      });
                    },
                  ),

                  const Icon(
                    Icons.skip_previous,
                    color: Colors.white,
                    size: 32,
                  ),

                  /// Play button
                  Container(
                    width: 70,
                    height: 70,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: Icon(
                        isPlaying ? Icons.pause : Icons.play_arrow,
                        color: Colors.black,
                        size: 34,
                      ),
                      onPressed: _togglePlayPause,
                    ),
                  ),

                  const Icon(
                    Icons.skip_next,
                    color: Colors.white,
                    size: 32,
                  ),

                  IconButton(
                    icon: Icon(
                      Icons.volume_up,
                      color: const Color(0xff94A3B8),
                      size: 26,
                    ),
                    onPressed: () {
                      setState(() {
                        isLooped = !isLooped;
                      });
                    },
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
                        Icon(Icons.bedtime,
                            color: Color(0xff94A3B8), size: 18),
                        SizedBox(width: 10),
                        Text(
                          "Sleep",
                          style: TextStyle(
                            color: Color(0xff94A3B8),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xff94A3B8),
                    ),
                    items: [
                      "15 min",
                      "30 min",
                      "45 min",
                      "1 hour",
                      "End of track"
                    ].map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(
                          e,
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedSleepTimer = value;
                      });
                    },
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}