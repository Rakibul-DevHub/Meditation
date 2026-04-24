import 'package:flutter/cupertino.dart';

/**
// ── Model ──────────────────────────────────────────────────────────────────────

class FavoriteTrack {
  final String id;
  final String categoryId;
  final String title;
  final String? description;
  final String? tagline;
  final String audioUrl;
  final String? coverImageUrl;
  final int? durationSeconds;
  final int playCount;
  final int downloadCount;
  final bool isFeatured;
  final bool isSleepTonight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? categoryName;

  FavoriteTrack({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    this.tagline,
    required this.audioUrl,
    this.coverImageUrl,
    this.durationSeconds,
    required this.playCount,
    required this.downloadCount,
    required this.isFeatured,
    required this.isSleepTonight,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
  });

  factory FavoriteTrack.fromJson(Map<String, dynamic> json) {
    return FavoriteTrack(
      id:              json['id']?.toString() ?? '',
      categoryId:      json['categoryId']?.toString() ?? '',
      title:           json['title']?.toString() ?? '',
      description:     json['description']?.toString(),
      tagline:         json['tagline']?.toString(),
      audioUrl:        json['audioUrl']?.toString() ?? '',
      coverImageUrl:   json['coverImageUrl']?.toString(),
      durationSeconds: json['durationSeconds'] as int?,
      playCount:       json['playCount'] as int? ?? 0,
      downloadCount:   json['downloadCount'] as int? ?? 0,
      isFeatured:      json['isFeatured'] as bool? ?? false,
      isSleepTonight:  json['isSleepTonight'] as bool? ?? false,
      createdAt:       DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      updatedAt:       DateTime.tryParse(json['updatedAt']?.toString() ?? '') ??
          DateTime.now(),
      categoryName:    json['category']?['name']?.toString(),
    );
  }

  /// Human-readable duration string (e.g. "3:45"), falls back to empty string.
  String get formattedDuration {
    if (durationSeconds == null) return '';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ── Pagination meta ────────────────────────────────────────────────────────────

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total:      json['total'] as int? ?? 0,
      page:       json['page'] as int? ?? 1,
      limit:      json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}*/
















// ── Model ──────────────────────────────────────────────────────────────────────

class FavoriteTrack {
  final String id;
  final String categoryId;
  final String title;
  final String? description;
  final String? tagline;
  final String audioUrl;
  final String? coverImageUrl;
  final int? durationSeconds;
  final int playCount;
  final int downloadCount;
  final bool isFeatured;
  final bool isSleepTonight;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? categoryName;

  FavoriteTrack({
    required this.id,
    required this.categoryId,
    required this.title,
    this.description,
    this.tagline,
    required this.audioUrl,
    this.coverImageUrl,
    this.durationSeconds,
    required this.playCount,
    required this.downloadCount,
    required this.isFeatured,
    required this.isSleepTonight,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
  });

  factory FavoriteTrack.fromJson(Map<String, dynamic> json) {
    debugPrint('📝 Parsing track: ${json['title']}');

    return FavoriteTrack(
      id: json['id']?.toString() ?? '',
      categoryId: json['categoryId']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Unknown Track',
      description: json['description']?.toString(),
      tagline: json['tagline']?.toString(),
      audioUrl: json['audioUrl']?.toString() ?? '',
      coverImageUrl: json['coverImageUrl']?.toString(),
      durationSeconds: json['durationSeconds'] as int?,
      playCount: json['playCount'] as int? ?? 0,
      downloadCount: json['downloadCount'] as int? ?? 0,
      isFeatured: json['isFeatured'] as bool? ?? false,
      isSleepTonight: json['isSleepTonight'] as bool? ?? false,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      categoryName: json['category'] != null
          ? (json['category'] as Map)['name']?.toString()
          : null,
    );
  }

  /// Human-readable duration string (e.g. "3:45"), falls back to empty string.
  String get formattedDuration {
    if (durationSeconds == null || durationSeconds == 0) return '';
    final minutes = durationSeconds! ~/ 60;
    final seconds = durationSeconds! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

// ── Pagination meta ────────────────────────────────────────────────────────────

class PaginationMeta {
  final int total;
  final int page;
  final int limit;
  final int totalPages;

  PaginationMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.totalPages,
  });

  factory PaginationMeta.fromJson(Map<String, dynamic> json) {
    return PaginationMeta(
      total: json['total'] as int? ?? 0,
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 10,
      totalPages: json['totalPages'] as int? ?? 1,
    );
  }
}






