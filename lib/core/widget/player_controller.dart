import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import '../network/app_url.dart';
import '../network/network_caller_dio.dart';
import '../network/secure_storage_service.dart';
import '../../model/category_model.dart';

enum PlaybackMode { continuous, shuffle, repeatOne }

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

  // Playlist State
  final RxList<TrackModel> playlist = <TrackModel>[].obs;
  final RxInt currentIndex = 0.obs;
  
  // Single button playback mode
  final Rx<PlaybackMode> playbackMode = PlaybackMode.continuous.obs;

  Timer? _historyTimer;
  ConcatenatingAudioSource? _playlistSource;

  @override
  void onInit() {
    super.onInit();
    _initPlayerListeners();
  }

  void _initPlayerListeners() {
    player.playerStateStream.listen((state) {
      isPlaying.value = state.playing;
      if (state.processingState == ProcessingState.completed) {
        _savePlayHistory(force: true);
      }
    });

    player.positionStream.listen((p) => position.value = p);
    player.durationStream.listen((d) => duration.value = d ?? Duration.zero);

    player.currentIndexStream.listen((index) {
      if (index != null && playlist.isNotEmpty) {
        currentIndex.value = index;
        currentTrack.value = playlist[index];
      }
    });
  }

  @override
  void onClose() {
    _savePlayHistory(force: true);
    _historyTimer?.cancel();
    player.dispose();
    super.onClose();
  }

  Future<void> setPlaylist(List<TrackModel> tracks, {int initialIndex = 0}) async {
    try {
      isLoading.value = true;
      showMiniPlayer.value = true;
      
      playlist.assignAll(tracks);
      currentIndex.value = initialIndex;
      currentTrack.value = tracks[initialIndex];

      _playlistSource = ConcatenatingAudioSource(
        children: tracks.map((track) => AudioSource.uri(Uri.parse(track.audioUrl ?? ''))).toList(),
      );

      await player.setAudioSource(
        _playlistSource!,
        initialIndex: initialIndex,
        initialPosition: Duration(seconds: tracks[initialIndex].playedSeconds ?? 0),
      );

      player.play();
      _startHistoryTimer();
    } catch (e) {
      debugPrint('Error setting playlist: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void cyclePlaybackMode() {
    if (playbackMode.value == PlaybackMode.continuous) {
      playbackMode.value = PlaybackMode.shuffle;
      player.setShuffleModeEnabled(true);
      player.setLoopMode(LoopMode.all);
    } else if (playbackMode.value == PlaybackMode.shuffle) {
      playbackMode.value = PlaybackMode.repeatOne;
      player.setShuffleModeEnabled(false);
      player.setLoopMode(LoopMode.one);
    } else {
      playbackMode.value = PlaybackMode.continuous;
      player.setShuffleModeEnabled(false);
      player.setLoopMode(LoopMode.all);
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

  void playNext() {
    if (player.hasNext) player.seekToNext();
  }

  void playPrevious() {
    if (player.hasPrevious) player.seekToPrevious();
  }

  void seek(Duration pos) => player.seek(pos);

  void stopAndHidePlayer() {
    player.stop();
    showMiniPlayer.value = false;
    currentTrack.value = null;
    playlist.clear();
    _historyTimer?.cancel();
  }

  Future<void> _savePlayHistory({bool force = false}) async {
    final track = currentTrack.value;
    if (track == null || track.id == null || (!player.playing && !force)) return;

    final playedSeconds = position.value.inSeconds;
    if (playedSeconds <= 0) return;

    final token = await _storage.getAccessToken();
    await _networkCaller.postRequest(
      AppUrl.playHistory,
      body: {"trackId": track.id, "playedSeconds": playedSeconds},
      headers: {if (token != null) 'Authorization': 'Bearer $token'},
    );
  }

  void _startHistoryTimer() {
    _historyTimer?.cancel();
    _historyTimer = Timer.periodic(const Duration(seconds: 30), (timer) => _savePlayHistory());
  }
}
