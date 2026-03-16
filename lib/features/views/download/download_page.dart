import 'package:flutter/material.dart';
import 'package:outdoor_therapy/core/app_colors.dart';

class DownloadScreen extends StatefulWidget {
  const DownloadScreen({super.key});

  @override
  State<DownloadScreen> createState() => _DownloadScreenState();
}

class _DownloadScreenState extends State<DownloadScreen> {
  // Active downloads with progress
  final List<_DownloadingItem> _downloading = [
    _DownloadingItem(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
      image: 'assets/images/dummy_image2.jpg',
      progress: 0.24,
    ),
    _DownloadingItem(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
      image: 'assets/images/dummy_image2.jpg',
      progress: 0.24,
    ),
  ];

  // Completed downloads
  final List<_DownloadedItem> _downloaded = [
    _DownloadedItem(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
      image: 'assets/images/dummy_image2.jpg',
    ),
    _DownloadedItem(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
      image: 'assets/images/dummy_image2.jpg',
    ),
    _DownloadedItem(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
      image: 'assets/images/dummy_image2.jpg',
    ),
    _DownloadedItem(
      title: 'Ocean Waves',
      duration: '45:00',
      description: 'Calming Ocean Waves Washing Upon The Shore.',
      image: 'assets/images/dummy_image2.jpg',
    ),
  ];

  void _cancelDownload(int index) {
    setState(() => _downloading.removeAt(index));
  }

  void _deleteDownloaded(int index) {
    setState(() => _downloaded.removeAt(index));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [

            // ── Header ──────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Downloads',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_downloaded.length} sounds downloaded',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),

            // ── Downloading section ─────────────────────────────────────
            if (_downloading.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: const Text(
                    'Downloading',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _DownloadingCard(
                    item: _downloading[index],
                    onCancel: () => _cancelDownload(index),
                  ),
                  childCount: _downloading.length,
                ),
              ),
              const SliverToBoxAdapter(child: SizedBox(height: 28)),
            ],

            // ── Downloaded section ──────────────────────────────────────
            if (_downloaded.isNotEmpty) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: const Text(
                    'Downloaded',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) => _DownloadedCard(
                    item: _downloaded[index],
                    onDelete: () => _deleteDownloaded(index),
                  ),
                  childCount: _downloaded.length,
                ),
              ),
            ],

            // Bottom padding for mini player + nav bar
            const SliverToBoxAdapter(child: SizedBox(height: 160)),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Downloading card — with progress bar + cancel ×
// ─────────────────────────────────────────────────────────────────────────────
class _DownloadingCard extends StatelessWidget {
  final _DownloadingItem item;
  final VoidCallback onCancel;

  const _DownloadingCard({required this.item, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Thumbnail
              _Thumbnail(imagePath: item.image),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                item.duration,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.45),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                item.description,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.55),
                                  fontSize: 12,
                                  height: 1.4,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        // Cancel button
                        GestureDetector(
                          onTap: onCancel,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, top: 2),
                            child: Icon(
                              Icons.close,
                              size: 18,
                              color: Colors.white.withOpacity(0.55),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Progress bar + label
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: item.progress,
                  minHeight: 4,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFF6C5ECF),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(item.progress * 100).toInt()}% Complete',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.4),
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),

        // Divider
        const _RowDivider(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Downloaded card — with delete 🗑 icon
// ─────────────────────────────────────────────────────────────────────────────
class _DownloadedCard extends StatelessWidget {
  final _DownloadedItem item;
  final VoidCallback onDelete;

  const _DownloadedCard({required this.item, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Thumbnail
              _Thumbnail(imagePath: item.image),
              const SizedBox(width: 14),

              // Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.duration,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      item.description,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.55),
                        fontSize: 12,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),

              // Delete button
              GestureDetector(
                onTap: onDelete,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 22,
                    color: Colors.red[400],
                  ),
                ),
              ),
            ],
          ),
        ),
        const _RowDivider(),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Shared thumbnail widget
// ─────────────────────────────────────────────────────────────────────────────
class _Thumbnail extends StatelessWidget {
  final String imagePath;
  const _Thumbnail({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.asset(
        imagePath,
        width: 72,
        height: 72,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1A5276), Color(0xFF117A65)],
            ),
          ),
          child: const Icon(Icons.waves_outlined, color: Colors.white38, size: 28),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Thin row divider
// ─────────────────────────────────────────────────────────────────────────────
class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 0.5,
      color: Colors.white.withOpacity(0.08),
      indent: 20,
      endIndent: 20,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  Data models
// ─────────────────────────────────────────────────────────────────────────────
class _DownloadingItem {
  final String title;
  final String duration;
  final String description;
  final String image;
  final double progress; // 0.0 – 1.0

  const _DownloadingItem({
    required this.title,
    required this.duration,
    required this.description,
    required this.image,
    required this.progress,
  });
}

class _DownloadedItem {
  final String title;
  final String duration;
  final String description;
  final String image;

  const _DownloadedItem({
    required this.title,
    required this.duration,
    required this.description,
    required this.image,
  });
}