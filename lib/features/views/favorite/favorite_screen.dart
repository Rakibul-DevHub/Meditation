import 'package:flutter/material.dart';
import 'package:outdoor_therapy/core/app_colors.dart';

class FavoriteScreen extends StatelessWidget {
  const FavoriteScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Favorites',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${_favoriteSounds.length} saved sounds',
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // Favorites List
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _favoriteSounds.length,
                separatorBuilder: (context, index) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final sound = _favoriteSounds[index];
                  return _FavoriteCard(sound: sound);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FavoriteCard extends StatelessWidget {
  final Map<String, dynamic> sound;

  const _FavoriteCard({required this.sound});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151932),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Thumbnail Image
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                image: DecorationImage(
                  image: AssetImage(sound['image']),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Sound Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    sound['title'],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sound['duration'],
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    sound['description'],
                    style: const TextStyle(
                      color: Color(0xFF9AA4B2),
                      fontSize: 12,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Heart Icon
            IconButton(
              icon: const Icon(
                Icons.favorite,
                color: Color(0xFF7B61FF),
                size: 24,
              ),
              onPressed: () {
                // Remove from favorites
              },
            ),
          ],
        ),
      ),
    );
  }
}

// Sample data
final List<Map<String, dynamic>> _favoriteSounds = [
  {
    'title': 'Ocean Waves',
    'duration': '45:00',
    'description': 'Calming Ocean Waves Washing Upon The Shore.',
    'image': 'assets/images/dummy_image.jpg',
  },
  {
    'title': 'Forest Night',
    'duration': '45:00',
    'description': 'Calming Ocean Waves Washing Upon The Shore.',
    'image': 'assets/images/dummy_image.jpg',
  },
  {
    'title': 'Distant Thunder',
    'duration': '45:00',
    'description': 'Calming Ocean Waves Washing Upon The Shore.',
    'image': 'assets/images/dummy_image.jpg',
  },
];