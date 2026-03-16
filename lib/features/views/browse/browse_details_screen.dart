import 'package:flutter/material.dart';
import 'dart:ui';

class BrowseDetailsScreen extends StatefulWidget {
  final String categoryName;
  final int soundCount;
  final IconData icon;
  final List<Color> gradient;
  final String imagePath;

  const BrowseDetailsScreen({
    super.key,
    required this.categoryName,
    required this.soundCount,
    required this.icon,
    required this.gradient,
    required this.imagePath,
  });

  @override
  State<BrowseDetailsScreen> createState() => _BrowseDetailsScreenState();
}

class _BrowseDetailsScreenState extends State<BrowseDetailsScreen> {
  final List<_SoundTrack> _soundTracks = [
    _SoundTrack(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
    ),
    _SoundTrack(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
    ),
    _SoundTrack(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
    ),
    _SoundTrack(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
    ),
    _SoundTrack(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E1A),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar with Back Button and Title ───────────────────
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8, top: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image with gradient
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: widget.gradient,
                      ),
                    ),
                    child: Image.asset(
                      widget.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.expand(),
                    ),
                  ),
                  // Dark overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0A0E1A).withOpacity(0.9),
                        ],
                      ),
                    ),
                  ),
                  // Category info
                  Positioned(
                    left: 20,
                    right: 20,
                    bottom: 30,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.categoryName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 0,
                            vertical: 6,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${widget.soundCount} sounds',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Sound Tracks List ────────────────────────────────────
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => _SoundTrackCard(
                  track: _soundTracks[index],
                  isLast: index == _soundTracks.length - 1,
                ),
                childCount: _soundTracks.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Sound Track Card
// ─────────────────────────────────────────────────────────────────────────────
class _SoundTrackCard extends StatefulWidget {
  final _SoundTrack track;
  final bool isLast;

  const _SoundTrackCard({
    required this.track,
    required this.isLast,
  });

  @override
  State<_SoundTrackCard> createState() => _SoundTrackCardState();
}

class _SoundTrackCardState extends State<_SoundTrackCard> {
  bool _isPlaying = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            children: [
              // Play button
              GestureDetector(
                onTap: () {
                  setState(() {
                    _isPlaying = !_isPlaying;
                  });
                },
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        const Color(0xFF1A5276),
                        const Color(0xFF117A65),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF117A65).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Track info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          widget.track.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.track.duration,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.6),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.track.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              // More options
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.favorite_border,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.file_download_outlined,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (!widget.isLast)
          Divider(
            height: 0,
            color: Colors.white.withOpacity(0.08),
            thickness: 0.5,
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data Model
// ─────────────────────────────────────────────────────────────────────────────
class _SoundTrack {
  final String title;
  final String duration;
  final String description;

  const _SoundTrack({
    required this.title,
    required this.duration,
    required this.description,
  });
}