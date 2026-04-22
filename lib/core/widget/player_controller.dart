import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../network/app_url.dart';
import '../network/network_caller_dio.dart';
import '../network/secure_storage_service.dart';
import '../../model/category_model.dart';

class PlayerController extends GetxController {
  final AudioPlayer player = AudioPlayer();
  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  // Reactive State
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rxn<TrackModel> currentTrack = Rxn<TrackModel>();
  final RxBool isLoading = false.obs;
  final RxBool showMiniPlayer = false.obs;

  Timer? _historyTimer;

  @override
  void onInit() {
    super.onInit();
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    // Listen to play/pause state
    player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _savePlayHistory(force: true);
      }
    });

    // Listen to position changes
    player.positionStream.listen((p) {
      position.value = p;
    });

    // Listen to duration changes
    player.durationStream.listen((d) {
      duration.value = d ?? Duration.zero;
    });
  }

  @override
  void onClose() {
    _savePlayHistory(force: true);
    _historyTimer?.cancel();
    player.dispose();
    super.onClose();
  }

  // Load and Play a track
  Future<void> playTrack(TrackModel track) async {
    try {
      isLoading.value = true;
      showMiniPlayer.value = true;
      
      // 1. Save progress of previous track if any
      if (currentTrack.value != null) {
        await _savePlayHistory(force: true);
      }

      currentTrack.value = track;
      
      // 2. Set the audio source
      final String? url = track.audioUrl;
      if (url == null || url.isEmpty) throw 'Audio URL is missing';

      await player.setUrl(url);

      // 3. Resume logic (Section 3.C of guide)
      if (track.playedSeconds != null && track.playedSeconds! > 0) {
        await player.seek(Duration(seconds: track.playedSeconds!));
      } else {
        await player.seek(Duration.zero);
      }

      // 4. Start playback
      player.play();
      
      // 5. Start periodic history saving (every 30 seconds)
      _startHistoryTimer();

    } catch (e) {
      debugPrint('Error playing track: $e');
      Get.snackbar('Player Error', 'Could not play audio',
          backgroundColor: Colors.red, colorText: Colors.white);
    } finally {
      isLoading.value = false;
    }
  }

  void togglePlayPause() {
    if (player.playing) {
      player.pause();
      _savePlayHistory(force: true);
    } else {
      player.play();
    }
  }

  void seek(Duration pos) {
    player.seek(pos);
  }

  void stopAndHidePlayer() {
    player.stop();
    showMiniPlayer.value = false;
    currentTrack.value = null;
    _historyTimer?.cancel();
  }

  // Save playback progress to backend (Section 3.C of guide)
  Future<void> _savePlayHistory({bool force = false}) async {
    final track = currentTrack.value;
    if (track == null || track.id == null) return;

    // Only save if playing or if forced (pause/stop)
    if (!player.playing && !force) return;

    final playedSeconds = position.value.inSeconds;
    if (playedSeconds <= 0) return;

    final token = await _storage.getAccessToken();
    
    await _networkCaller.postRequest(
      AppUrl.playHistory,
      body: {
        "trackId": track.id,
        "playedSeconds": playedSeconds,
      },
      headers: {
        if (token != null) 'Authorization': 'Bearer $token',
      },
    );
  }

  void _startHistoryTimer() {
    _historyTimer?.cancel();
    _historyTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _savePlayHistory();
    });
  }
}
