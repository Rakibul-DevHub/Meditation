/**
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

// Download state enum
enum DownloadStatus { idle, downloading, completed, failed, alreadyDownloaded, cancelled }

// Download state model
class DownloadState {
  final String trackId;
  final String trackTitle;
  final String coverImageUrl;
  final String categoryName;
  final int durationSeconds;
  final DownloadStatus status;
  final int progressPercent;
  final String? errorMessage;
  final String? downloadId;
  final CancelToken? cancelToken; // Add cancel token for Dio

  DownloadState({
    required this.trackId,
    required this.trackTitle,
    required this.coverImageUrl,
    required this.categoryName,
    required this.durationSeconds,
    required this.status,
    this.progressPercent = 0,
    this.errorMessage,
    this.downloadId,
    this.cancelToken,
  });

  DownloadState copyWith({
    String? trackId,
    String? trackTitle,
    String? coverImageUrl,
    String? categoryName,
    int? durationSeconds,
    DownloadStatus? status,
    int? progressPercent,
    String? errorMessage,
    String? downloadId,
    CancelToken? cancelToken,
  }) {
    return DownloadState(
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      categoryName: categoryName ?? this.categoryName,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadId: downloadId ?? this.downloadId,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class DownloadService extends GetxService {
  final RxMap<String, DownloadState> activeDownloads = <String, DownloadState>{}.obs;
  final RxList<DownloadState> completedDownloads = <DownloadState>[].obs;

  void addOrUpdateDownload(DownloadState state) {
    activeDownloads[state.trackId] = state;
  }

  void markAsCompleted(String trackId) {
    final state = activeDownloads[trackId];
    if (state != null && state.status == DownloadStatus.completed) {
      completedDownloads.add(state);
      activeDownloads.remove(trackId);
    }
  }

  void cancelDownload(String trackId) {
    final state = activeDownloads[trackId];
    if (state != null && state.cancelToken != null) {
      // Cancel the ongoing download request
      state.cancelToken!.cancel('Download cancelled by user');

      // Update state to cancelled
      final cancelledState = state.copyWith(
        status: DownloadStatus.cancelled,
        errorMessage: 'Download cancelled by user',
      );
      activeDownloads[trackId] = cancelledState;

      // Remove after a short delay to show cancelled state
      Future.delayed(const Duration(milliseconds: 500), () {
        if (activeDownloads[trackId]?.status == DownloadStatus.cancelled) {
          activeDownloads.remove(trackId);
        }
      });
    } else {
      // If no cancel token, just remove
      activeDownloads.remove(trackId);
    }
  }

  void removeFromActive(String trackId) {
    activeDownloads.remove(trackId);
  }

  void clearCompletedDownloads() {
    completedDownloads.clear();
  }

  DownloadState? getDownloadState(String trackId) {
    return activeDownloads[trackId];
  }

  bool isDownloading(String trackId) {
    final state = activeDownloads[trackId];
    return state != null && state.status == DownloadStatus.downloading;
  }

  bool isCompleted(String trackId) {
    final state = activeDownloads[trackId];
    return state != null && state.status == DownloadStatus.completed;
  }

  void refreshActiveDownloads() {
    activeDownloads.refresh();
  }
}*/
















import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart';

// Download state enum
enum DownloadStatus { idle, downloading, completed, failed, alreadyDownloaded, cancelled }

// Download state model
class DownloadState {
  final String trackId;
  final String trackTitle;
  final String coverImageUrl;
  final String categoryName;
  final int durationSeconds;
  final DownloadStatus status;
  final int progressPercent;
  final String? errorMessage;
  final String? downloadId;
  final CancelToken? cancelToken;

  DownloadState({
    required this.trackId,
    required this.trackTitle,
    required this.coverImageUrl,
    required this.categoryName,
    required this.durationSeconds,
    required this.status,
    this.progressPercent = 0,
    this.errorMessage,
    this.downloadId,
    this.cancelToken,
  });

  DownloadState copyWith({
    String? trackId,
    String? trackTitle,
    String? coverImageUrl,
    String? categoryName,
    int? durationSeconds,
    DownloadStatus? status,
    int? progressPercent,
    String? errorMessage,
    String? downloadId,
    CancelToken? cancelToken,
  }) {
    return DownloadState(
      trackId: trackId ?? this.trackId,
      trackTitle: trackTitle ?? this.trackTitle,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      categoryName: categoryName ?? this.categoryName,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      status: status ?? this.status,
      progressPercent: progressPercent ?? this.progressPercent,
      errorMessage: errorMessage ?? this.errorMessage,
      downloadId: downloadId ?? this.downloadId,
      cancelToken: cancelToken ?? this.cancelToken,
    );
  }

  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

class DownloadService extends GetxService {
  final RxMap<String, DownloadState> activeDownloads = <String, DownloadState>{}.obs;
  final RxList<DownloadState> completedDownloads = <DownloadState>[].obs;

  void addOrUpdateDownload(DownloadState state) {
    activeDownloads[state.trackId] = state;
  }

  void markAsCompleted(String trackId) {
    final state = activeDownloads[trackId];
    if (state != null && state.status == DownloadStatus.completed) {
      completedDownloads.add(state);
      activeDownloads.remove(trackId);
    }
  }

  void cancelDownload(String trackId) {
    final state = activeDownloads[trackId];
    if (state != null && state.cancelToken != null) {
      state.cancelToken!.cancel('Download cancelled by user');

      final cancelledState = state.copyWith(
        status: DownloadStatus.cancelled,
        errorMessage: 'Download cancelled by user',
      );
      activeDownloads[trackId] = cancelledState;

      Future.delayed(const Duration(milliseconds: 500), () {
        if (activeDownloads[trackId]?.status == DownloadStatus.cancelled) {
          activeDownloads.remove(trackId);
        }
      });
    } else {
      activeDownloads.remove(trackId);
    }
  }

  void removeFromActive(String trackId) {
    activeDownloads.remove(trackId);
  }

  void clearCompletedDownloads() {
    completedDownloads.clear();
  }

  DownloadState? getDownloadState(String trackId) {
    return activeDownloads[trackId];
  }

  bool isDownloading(String trackId) {
    final state = activeDownloads[trackId];
    return state != null && state.status == DownloadStatus.downloading;
  }

  bool isCompleted(String trackId) {
    final state = activeDownloads[trackId];
    return state != null && state.status == DownloadStatus.completed;
  }

  void refreshActiveDownloads() {
    activeDownloads.refresh();
  }
}