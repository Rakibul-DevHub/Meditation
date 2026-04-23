class CategoryListResponse {
  final int? code;
  final String? message;
  final CategoryListData? data;

  CategoryListResponse({this.code, this.message, this.data});

  factory CategoryListResponse.fromJson(Map<String, dynamic> json) {
    return CategoryListResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? CategoryListData.fromJson(json['data']) : null,
    );
  }
}

class CategoryListData {
  final List<CategoryModel>? results;
  final int? page;
  final int? limit;
  final int? totalPages;
  final int? totalResults;

  CategoryListData({
    this.results,
    this.page,
    this.limit,
    this.totalPages,
    this.totalResults,
  });

  factory CategoryListData.fromJson(Map<String, dynamic> json) {
    return CategoryListData(
      results: json['results'] != null
          ? (json['results'] as List).map((i) => CategoryModel.fromJson(i)).toList()
          : null,
      page: json['page'],
      limit: json['limit'],
      totalPages: json['totalPages'],
      totalResults: json['totalResults'],
    );
  }
}

class CategoryDetailResponse {
  final int? code;
  final String? message;
  final CategoryModel? data;

  CategoryDetailResponse({this.code, this.message, this.data});

  factory CategoryDetailResponse.fromJson(Map<String, dynamic> json) {
    return CategoryDetailResponse(
      code: json['code'],
      message: json['message'],
      data: json['data'] != null ? CategoryModel.fromJson(json['data']) : null,
    );
  }
}

class CategoryModel {
  final String? id;
  final String? name;
  final String? iconUrl;
  final String? coverImageUrl;
  final int? totalTracks;
  final String? createdAt;
  final String? updatedAt;
  final List<TrackModel>? tracks;

  CategoryModel({
    this.id,
    this.name,
    this.iconUrl,
    this.coverImageUrl,
    this.totalTracks,
    this.createdAt,
    this.updatedAt,
    this.tracks,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      iconUrl: json['iconUrl'],
      coverImageUrl: json['coverImageUrl'],
      totalTracks: json['totalTracks'] ?? (json['_count'] != null ? json['_count']['tracks'] : 0),
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      tracks: json['tracks'] != null
          ? (json['tracks'] as List).map((i) => TrackModel.fromJson(i)).toList()
          : null,
    );
  }
}

class TrackModel {
  bool? isFavorite;
  final String? id;
  final String? categoryId;
  final String? title;
  final String? description;
  final String? tagline;
  final String? audioUrl;
  final String? coverImageUrl;
  final int? durationSeconds;
  final int? playCount;
  final int? downloadCount;
  final bool? isFeatured;
  final bool? isSleepTonight;
  final String? createdAt;
  final String? updatedAt;
  final String? categoryName;
  final int? playedSeconds;

  TrackModel({
    this.isFavorite,
    this.id,
    this.categoryId,
    this.title,
    this.description,
    this.tagline,
    this.audioUrl,
    this.coverImageUrl,
    this.durationSeconds,
    this.playCount,
    this.downloadCount,
    this.isFeatured,
    this.isSleepTonight,
    this.createdAt,
    this.updatedAt,
    this.categoryName,
    this.playedSeconds,
  });

  factory TrackModel.fromJson(Map<String, dynamic> json) {
    return TrackModel(
      id: json['id'],
      isFavorite: json['is_favorite'],
      categoryId: json['categoryId'],
      title: json['title'],
      description: json['description'],
      tagline: json['tagline'],
      audioUrl: json['audioUrl'],
      coverImageUrl: json['coverImageUrl'],
      durationSeconds: json['durationSeconds'],
      playCount: json['playCount'],
      downloadCount: json['downloadCount'],
      isFeatured: json['isFeatured'],
      isSleepTonight: json['isSleepTonight'],
      createdAt: json['createdAt'],
      updatedAt: json['updatedAt'],
      categoryName: json['category'] != null ? json['category']['name'] : null,
      playedSeconds: json['playedSeconds'] ?? 0,
    );
  }
}
