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