// lib/core/services/player_service.dart
import 'package:flutter/material.dart';

class PlayerService {
  static final PlayerService _instance = PlayerService._internal();
  factory PlayerService() => _instance;
  PlayerService._internal();

  final ValueNotifier<Map<String, dynamic>?> currentTrack = ValueNotifier(null);
  final ValueNotifier<bool> isPlaying = ValueNotifier(false);
  final ValueNotifier<bool> showMiniPlayer = ValueNotifier(false);

  void playTrack(Map<String, dynamic> track) {
    currentTrack.value = track;
    isPlaying.value = true;
    showMiniPlayer.value = true;
  }

  void togglePlayPause() {
    isPlaying.value = !isPlaying.value;
  }

  void closePlayer() {
    showMiniPlayer.value = false;
    currentTrack.value = null;
  }

  void updateTrack(Map<String, dynamic> track) {
    currentTrack.value = track;
  }

  void dispose() {
    currentTrack.dispose();
    isPlaying.dispose();
    showMiniPlayer.dispose();
  }
}