
import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import '../../../core/network/app_url.dart';
import '../../../core/network/network_caller_dio.dart';
import '../../../core/network/secure_storage_service.dart';
import '../../../model/category_model.dart';
import '../../../main.dart'; // for audioHandler global

enum PlaybackMode { continuous, shuffle, repeatOne }

class PlayerController extends GetxController {
  // Use the shared AudioPlayer owned by the global audioHandler
  AudioPlayer get player => audioHandler.player;

  final NetworkCallerDio _networkCaller = NetworkCallerDio();
  final SecureStorageService _storage = SecureStorageService.instance;

  // ── Reactive State ────────────────────────────────────────────────────────
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  final Rxn<TrackModel> currentTrack = Rxn<TrackModel>();
  final RxBool isLoading = false.obs;
  final RxBool showMiniPlayer = false.obs;

  // Playlist State
  final RxList<TrackModel> playlist = <TrackModel>[].obs;
  final RxInt currentIndex = 0.obs;

  // Playback mode
  final Rx<PlaybackMode> playbackMode = PlaybackMode.continuous.obs;

  Timer? _historyTimer;
  ConcatenatingAudioSource? _playlistSource;

  // Store subscriptions so we can cancel them cleanly on dispose
  final List<StreamSubscription> _subscriptions = [];

  @override
  void onInit() {
    super.onInit();
    _initPlayerListeners();
  }

  // ── Stream Listeners ──────────────────────────────────────────────────────

  void _initPlayerListeners() {
    // ── 1. Playing / paused / completed ──────────────────────────────────
    // Derive isPlaying from both the playing flag AND the processing state so
    // the UI button flips correctly the moment the OS notification is tapped.
    _subscriptions.add(
      player.playerStateStream.listen((state) {
        final playing = state.playing &&
            state.processingState != ProcessingState.completed &&
            state.processingState != ProcessingState.idle;
        isPlaying.value = playing;

        // Auto-save history when a track finishes naturally
        if (state.processingState == ProcessingState.completed) {
          _savePlayHistory(force: true);
        }
      }),
    );

    // ── 2. Also react to audio_service playback state so the lock-screen
    //       play/pause is always in sync with our RxBool ─────────────────
    _subscriptions.add(
      audioHandler.playbackState.listen((state) {
        final playing = state.playing &&
            !state.processingState.name.contains('idle') &&
            !state.processingState.name.contains('completed');
        isPlaying.value = playing;

        // Mirror loading/buffering state
        isLoading.value =
            state.processingState == AudioProcessingState.loading ||
                state.processingState == AudioProcessingState.buffering;
      }),
    );

    // ── 3. Seek position ──────────────────────────────────────────────────
    _subscriptions.add(
      player.positionStream.listen((p) => position.value = p),
    );

    // ── 4. Track duration ─────────────────────────────────────────────────
    _subscriptions.add(
      player.durationStream.listen((d) => duration.value = d ?? Duration.zero),
    );

    // ── 5. Current index / track change ───────────────────────────────────
    _subscriptions.add(
      player.currentIndexStream.listen((index) {
        if (index != null &&
            playlist.isNotEmpty &&
            index < playlist.length) {
          currentIndex.value = index;
          currentTrack.value = playlist[index];

          // Keep the OS notification / lock screen artwork up-to-date
          audioHandler.mediaItem.add(_trackToMediaItem(playlist[index]));
        }
      }),
    );
  }

  @override
  void onClose() {
    _savePlayHistory(force: true);
    _historyTimer?.cancel();
    for (final s in _subscriptions) {
      s.cancel();
    }
    _subscriptions.clear();
    // Do NOT dispose player — it belongs to audioHandler (app lifetime)
    super.onClose();
  }

  // ── MediaItem helper ──────────────────────────────────────────────────────

  MediaItem _trackToMediaItem(TrackModel track) {
    return MediaItem(
      id: track.id ?? '',
      title: track.title ?? 'Unknown Track',
      artist: track.categoryName ?? '',
      artUri: (track.coverImageUrl != null && track.coverImageUrl!.isNotEmpty)
          ? Uri.parse(track.coverImageUrl!)
          : null,
      duration: track.durationSeconds != null
          ? Duration(seconds: track.durationSeconds!)
          : null,
    );
  }

  // ── AudioSource builder ───────────────────────────────────────────────────

  AudioSource _buildAudioSource(TrackModel track, {String? token}) {
    final url = track.audioUrl ?? '';
    if (url.startsWith('http://') || url.startsWith('https://')) {
      return AudioSource.uri(
        Uri.parse(url),
        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
      );
    } else {
      final file = File(url);
      debugPrint('🎵 Playing local file: ${file.path}');
      return AudioSource.uri(Uri.file(file.path));
    }
  }

  // ── Core playback ─────────────────────────────────────────────────────────

  Future<void> setPlaylist(List<TrackModel> tracks, {int initialIndex = 0}) async {
    if (tracks.isEmpty) return;

    // 🚀 1. UPDATE STATE IMMEDIATELY
    // This prevents "No track selected" or UI flickering when the screen opens.
    playlist.assignAll(tracks);
    currentIndex.value = initialIndex;
    currentTrack.value = tracks[initialIndex];
    showMiniPlayer.value = true;
    isLoading.value = true;

    try {
      final token = await _storage.getAccessToken();

      // 🚀 2. HIT THE playTrack API IN THE BACKGROUND
      // We don't await this because it takes 3+ seconds and we want the music to start NOW.
      // This satisfies the backend requirement to "hit the API when I tap".
      if (currentTrack.value?.id != null) {
        final String trackApiUrl = AppUrl.playTrack(currentTrack.value!.id!);
        debugPrint('🎵 [PLAYBACK] Registering play event (BG): $trackApiUrl');
        
        // Fire and forget (don't await)
        _networkCaller.getRequest(
          trackApiUrl,
          headers: token != null ? {'Authorization': 'Bearer $token'} : null,
        ).then((response) {
          if (response.isSuccess && response.jsonResponse != null) {
            final data = response.jsonResponse!['data'];
            if (data != null) {
              // Optionally update metadata if something changed (like a new URL)
              final freshTrack = TrackModel.fromJson(data);
              // Only update if the user hasn't already switched tracks
              if (currentTrack.value?.id == freshTrack.id) {
                currentTrack.value = freshTrack;
                playlist[initialIndex] = freshTrack;
              }
            }
          }
        }).catchError((e) => debugPrint('⚠️ Background track refresh failed: $e'));
      }

      // 🚀 3. PREPARE PLAYER IMMEDIATELY
      // Push queue to audio_service
      await audioHandler.updateQueue(
        tracks.map(_trackToMediaItem).toList(),
      );

      // Show artwork in notification
      audioHandler.mediaItem.add(_trackToMediaItem(tracks[initialIndex]));

      _playlistSource = ConcatenatingAudioSource(
        children: tracks.map((t) => _buildAudioSource(t, token: token)).toList(),
      );

      await player.setAudioSource(
        _playlistSource!,
        initialIndex: initialIndex,
        initialPosition: Duration(
          seconds: tracks[initialIndex].playedSeconds ?? 0,
        ),
      );

      await audioHandler.play();
      _startHistoryTimer();
      
    } catch (e) {
      debugPrint('❌ Error setting playlist: $e');
      isLoading.value = false;
      
      Get.snackbar(
        'Playback Error',
        'Could not play this track. Please try again.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      // The playerStateStream listener usually handles isLoading, 
      // but we add a safety timeout here.
      Future.delayed(const Duration(milliseconds: 500), () {
        if (player.processingState == ProcessingState.ready) {
          isLoading.value = false;
        }
      });
    }
  }

  // Removed _refreshPlaylistInBackground to prevent multiple backend hits


  // ── Playback mode ─────────────────────────────────────────────────────────

  void cyclePlaybackMode() {
    switch (playbackMode.value) {
      case PlaybackMode.continuous:
        playbackMode.value = PlaybackMode.shuffle;
        audioHandler.setShuffleMode(AudioServiceShuffleMode.all);
        audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
      case PlaybackMode.shuffle:
        playbackMode.value = PlaybackMode.repeatOne;
        audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
        audioHandler.setRepeatMode(AudioServiceRepeatMode.one);
        break;
      case PlaybackMode.repeatOne:
        playbackMode.value = PlaybackMode.continuous;
        audioHandler.setShuffleMode(AudioServiceShuffleMode.none);
        audioHandler.setRepeatMode(AudioServiceRepeatMode.all);
        break;
    }
  }

  // ── Transport controls ────────────────────────────────────────────────────

  void togglePlayPause() {
    if (player.playing) {
      audioHandler.pause();
      _savePlayHistory(force: true);
    } else {
      audioHandler.play();
    }
  }

  void playNext() {
    if (player.hasNext) audioHandler.skipToNext();
  }

  void playPrevious() {
    if (player.hasPrevious) audioHandler.skipToPrevious();
  }

  void seek(Duration pos) => audioHandler.seek(pos);

  void stopAndHidePlayer() {
    audioHandler.stop();
    showMiniPlayer.value = false;
    currentTrack.value = null;
    playlist.clear();
    _historyTimer?.cancel();
    isPlaying.value = false;
    isLoading.value = false;
    position.value = Duration.zero;
    duration.value = Duration.zero;
  }

  // ── Play history ──────────────────────────────────────────────────────────

  Future<void> _savePlayHistory({bool force = false}) async {
    final track = currentTrack.value;
    if (track == null || track.id == null) return;
    if (!player.playing && !force) return;

    // Don't save history for locally-downloaded files
    final url = track.audioUrl ?? '';
    if (!url.startsWith('http://') && !url.startsWith('https://')) return;

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
    _historyTimer = Timer.periodic(
      const Duration(seconds: 30),
          (timer) => _savePlayHistory(),
    );
  }
}