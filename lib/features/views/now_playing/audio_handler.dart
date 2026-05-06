/**
import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'player_controller.dart';

class MyAudioHandler extends BaseAudioHandler with QueueHandler, SeekHandler {
  final AudioPlayer player = AudioPlayer();

  MyAudioHandler() {
    // ✅ Exactly like the official example — pipe events directly
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    // Track change → update mediaItem for notification
    player.currentIndexStream.listen((index) {
      if (index != null &&
          queue.value.isNotEmpty &&
          index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });
  }

  // ── Safely get mode from PlayerController ─────────────────────────────
  PlaybackMode get _currentMode {
    try {
      return Get.find<PlayerController>().playbackMode.value;
    } catch (_) {
      return PlaybackMode.continuous;
    }
  }

  // ── Transform event exactly like official example ─────────────────────
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,                              // index 0
        if (player.playing) MediaControl.pause else MediaControl.play, // index 1
        MediaControl.skipToNext,                                  // index 2
        // ✅ index 3 — mode button replaces stop
        _getModeControl(),
      ],
      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
      },
      // ✅ KEY FIX: [0, 1, 3] like official example — skips index 2 in compact
      // compact view shows: prev | play/pause | mode button
      // expanded view shows all 4: prev | play/pause | next | mode
      androidCompactActionIndices: const [0, 1, 2],
      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,
      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,
      shuffleMode: player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,
      repeatMode: _getRepeatMode(player.loopMode),
    );
  }

  // ── Mode control button ───────────────────────────────────────────────
  MediaControl _getModeControl() {
    switch (_currentMode) {
      case PlaybackMode.shuffle:
        return const MediaControl(
          androidIcon: 'drawable/ic_audio_service_shuffle',
          label: 'Shuffle',
          action: MediaAction.setShuffleMode,
        );
      case PlaybackMode.repeatOne:
        return const MediaControl(
          androidIcon: 'drawable/ic_audio_service_fast_forward',
          label: 'Repeat One',
          action: MediaAction.setRepeatMode,
        );
      case PlaybackMode.continuous:
      default:
        return const MediaControl(
          androidIcon: 'drawable/ic_audio_service_skip_next',
          label: 'Repeat All',
          action: MediaAction.setRepeatMode,
        );
    }
  }

  AudioServiceRepeatMode _getRepeatMode(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
      default:
        return AudioServiceRepeatMode.none;
    }
  }

  // ── Playback controls ─────────────────────────────────────────────────

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> skipToNext() async {
    if (player.hasNext) await player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (player.hasPrevious) await player.seekToPrevious();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await player.seek(Duration.zero, index: index);
    await player.play();
  }

  // ✅ Notification mode button tapped → cycle in PlayerController
  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    try {
      Get.find<PlayerController>().cyclePlaybackMode();
    } catch (_) {
      await player.setShuffleModeEnabled(
        shuffleMode == AudioServiceShuffleMode.all,
      );
    }
  }

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    try {
      Get.find<PlayerController>().cyclePlaybackMode();
    } catch (_) {
      final loopMode = {
        AudioServiceRepeatMode.none: LoopMode.off,
        AudioServiceRepeatMode.one: LoopMode.one,
        AudioServiceRepeatMode.all: LoopMode.all,
      }[repeatMode];
      if (loopMode != null) await player.setLoopMode(loopMode);
    }
  }
}
*/
























import 'dart:async';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';

class MyAudioHandler extends BaseAudioHandler
    with QueueHandler, SeekHandler {
  final AudioPlayer player = AudioPlayer();

  MyAudioHandler() {
    /// Sync playback state
    player.playbackEventStream.map(_transformEvent).pipe(playbackState);

    /// Update current media item
    player.currentIndexStream.listen((index) {
      if (index != null &&
          queue.value.isNotEmpty &&
          index < queue.value.length) {
        mediaItem.add(queue.value[index]);
      }
    });
  }

  /// Transform player event → audio_service state
  PlaybackState _transformEvent(PlaybackEvent event) {
    return PlaybackState(
      controls: [
        MediaControl.skipToPrevious,

        /// 🔀 CUSTOM SHUFFLE BUTTON
        MediaControl(
          androidIcon: 'drawable/ic_shuffle',
          label: 'Shuffle',
          action: MediaAction.setShuffleMode,
        ),

        /// ▶️ PLAY / PAUSE
        if (player.playing)
          MediaControl.pause
        else
          MediaControl.play,

        /// 🔁 CUSTOM REPEAT BUTTON
        MediaControl(
          androidIcon: 'drawable/ic_repeat',
          label: 'Repeat',
          action: MediaAction.setRepeatMode,
        ),

        MediaControl.skipToNext,
      ],

      /// Only 3 buttons visible in compact notification
      androidCompactActionIndices: const [0, 2, 4],

      systemActions: const {
        MediaAction.seek,
        MediaAction.seekForward,
        MediaAction.seekBackward,
        MediaAction.setShuffleMode,
        MediaAction.setRepeatMode,
      },

      processingState: const {
        ProcessingState.idle: AudioProcessingState.idle,
        ProcessingState.loading: AudioProcessingState.loading,
        ProcessingState.buffering: AudioProcessingState.buffering,
        ProcessingState.ready: AudioProcessingState.ready,
        ProcessingState.completed: AudioProcessingState.completed,
      }[player.processingState]!,

      playing: player.playing,
      updatePosition: player.position,
      bufferedPosition: player.bufferedPosition,
      speed: player.speed,
      queueIndex: event.currentIndex,

      /// 🔀 Shuffle state
      shuffleMode: player.shuffleModeEnabled
          ? AudioServiceShuffleMode.all
          : AudioServiceShuffleMode.none,

      /// 🔁 Repeat state
      repeatMode: _getRepeatMode(player.loopMode),
    );
  }

  /// Map loop mode → repeat mode
  AudioServiceRepeatMode _getRepeatMode(LoopMode loopMode) {
    switch (loopMode) {
      case LoopMode.one:
        return AudioServiceRepeatMode.one;
      case LoopMode.all:
        return AudioServiceRepeatMode.all;
      default:
        return AudioServiceRepeatMode.none;
    }
  }

  // ───────────────────────────────
  // 🎮 BASIC CONTROLS
  // ───────────────────────────────

  @override
  Future<void> play() => player.play();

  @override
  Future<void> pause() => player.pause();

  @override
  Future<void> stop() async {
    await player.stop();
    await super.stop();
  }

  @override
  Future<void> seek(Duration position) => player.seek(position);

  @override
  Future<void> skipToNext() async {
    if (player.hasNext) await player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    if (player.hasPrevious) await player.seekToPrevious();
  }

  @override
  Future<void> skipToQueueItem(int index) async {
    await player.seek(Duration.zero, index: index);
    await player.play();
  }

  // ───────────────────────────────
  // 🔀 SHUFFLE CONTROL
  // ───────────────────────────────

  @override
  Future<void> setShuffleMode(AudioServiceShuffleMode shuffleMode) async {
    final enable = shuffleMode == AudioServiceShuffleMode.all;

    await player.setShuffleModeEnabled(enable);

    if (enable) {
      await player.shuffle();
    }

    /// Force UI update
    playbackState.add(_transformEvent(PlaybackEvent()));
  }

  // ───────────────────────────────
  // 🔁 REPEAT CONTROL
  // ───────────────────────────────

  @override
  Future<void> setRepeatMode(AudioServiceRepeatMode repeatMode) async {
    final loopMode = {
      AudioServiceRepeatMode.none: LoopMode.off,
      AudioServiceRepeatMode.one: LoopMode.one,
      AudioServiceRepeatMode.all: LoopMode.all,
    }[repeatMode]!;

    await player.setLoopMode(loopMode);

    /// Force UI update
    playbackState.add(_transformEvent(PlaybackEvent()));
  }
}