import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:outdoor_therapy/features/views/now_playing/now_playing_screen.dart';
import 'package:outdoor_therapy/model/category_model.dart';
import 'package:outdoor_therapy/features/views/now_playing/player_controller.dart';

class CustomPlayCard extends StatelessWidget {
  final TrackModel track;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onClose;
  final VoidCallback? onTap;

  const CustomPlayCard({
    super.key,
    required this.track,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onClose,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap ?? () => _navigateToNowPlaying(context),
      behavior: HitTestBehavior.opaque,
      child: ClipRRect(
        borderRadius: BorderRadius.zero,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.06),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.18),
                  width: 0.8,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  // Track thumbnail - using URL or GIF fallback
                  _VinylAvatar(imageUrl: track.coverImageUrl),

                  const SizedBox(width: 14),

                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          track.title ?? 'Unknown Track',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          track.categoryName ?? 'Meditation',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 10),

                  // Play/Pause button
                  _PlayPauseButton(
                    isPlaying: isPlaying,
                    onTap: onPlayPause,
                  ),

                  const SizedBox(width: 10),

                  // Close button
                  GestureDetector(
                    onTap: onClose,
                    behavior: HitTestBehavior.opaque,
                    child: Icon(
                      Icons.close,
                      color: Colors.white.withOpacity(0.65),
                      size: 22,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToNowPlaying(BuildContext context) {
    Get.to(() => const NowPlayingScreen());
  }
}

// Play/Pause button with glass effect
class _PlayPauseButton extends StatelessWidget {
  final bool isPlaying;
  final VoidCallback onTap;

  const _PlayPauseButton({
    required this.isPlaying,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withOpacity(0.12),
              border: Border.all(
                color: const Color(0xFF7B6CF6).withOpacity(0.85),
                width: 2.2,
              ),
            ),
            child: Center(
              child: Icon(
                isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Vinyl avatar widget - supports Network Images and local fallback
class _VinylAvatar extends StatelessWidget {
  final String? imageUrl;

  const _VinylAvatar({this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
      height: 52,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Outer purple ring
          Container(
            width: 52,
            height: 52,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: [
                  Color(0xFF7B6CF6),
                  Color(0xFF5E4AD4),
                  Color(0xFF9E8FFE),
                  Color(0xFF7B6CF6),
                ],
              ),
            ),
          ),
          // Album art
          ClipOval(
            child: Container(
              width: 38,
              height: 38,
              color: Colors.black26,
              child: imageUrl != null && imageUrl!.isNotEmpty
                ? CachedNetworkImage(
                    imageUrl: imageUrl!,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => const CircularProgressIndicator(strokeWidth: 2),
                    errorWidget: (_, __, ___) => Image.asset('assets/gif/playing.gif', fit: BoxFit.cover),
                  )
                : Image.asset('assets/gif/playing.gif', fit: BoxFit.cover),
            ),
          ),
          // Centre dot
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8B44A),
            ),
          ),
        ],
      ),
    );
  }
}
