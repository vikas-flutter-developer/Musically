
import 'package:audioplayers/audioplayers.dart' as ap;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_explorer_app/features/home/data/models/song_model.dart';

enum PlayerStatus { stopped, playing, paused, completed, loading }

class PlayerState {
  final PlayerStatus status;
  final Duration position;
  final Duration duration;
  final bool isShuffle;
  final bool isRepeat;

  final int? trackId;
  final String? trackName;
  final String? artistName;
  final String? collectionName;
  final String? artworkUrl100;
  final String? previewUrl;

  const PlayerState({
    this.status = PlayerStatus.stopped,
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.isShuffle = false,
    this.isRepeat = false,
    this.trackId,
    this.trackName,
    this.artistName,
    this.collectionName,
    this.artworkUrl100,
    this.previewUrl,
  });

  PlayerState copyWith({
    PlayerStatus? status,
    Duration? position,
    Duration? duration,
    bool? isShuffle,
    bool? isRepeat,
    int? trackId,
    String? trackName,
    String? artistName,
    String? collectionName,
    String? artworkUrl100,
    String? previewUrl,
    bool clearSong = false,
  }) {
    return PlayerState(
      status: status ?? this.status,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      isShuffle: isShuffle ?? this.isShuffle,
      isRepeat: isRepeat ?? this.isRepeat,
      trackId: clearSong ? null : (trackId ?? this.trackId),
      trackName: clearSong ? null : (trackName ?? this.trackName),
      artistName: clearSong ? null : (artistName ?? this.artistName),
      collectionName:
          clearSong ? null : (collectionName ?? this.collectionName),
      artworkUrl100:
          clearSong ? null : (artworkUrl100 ?? this.artworkUrl100),
      previewUrl: clearSong ? null : (previewUrl ?? this.previewUrl),
    );
  }
}

class PlayerCubit extends Cubit<PlayerState> {
  final ap.AudioPlayer _audioPlayer = ap.AudioPlayer();
  String? _currentUrl;

  PlayerCubit() : super(const PlayerState()) {
    _audioPlayer.setReleaseMode(ap.ReleaseMode.stop);

    _audioPlayer.onPlayerStateChanged.listen((s) {
      switch (s) {
        case ap.PlayerState.playing:
          emit(state.copyWith(status: PlayerStatus.playing));
          break;
        case ap.PlayerState.paused:
          emit(state.copyWith(status: PlayerStatus.paused));
          break;
        case ap.PlayerState.completed:
          emit(state.copyWith(
            status: PlayerStatus.completed,
            position: state.duration,
          ));
          break;
        case ap.PlayerState.stopped:
        case ap.PlayerState.disposed:
          break;
      }
    });

    _audioPlayer.onDurationChanged.listen((d) {
      emit(state.copyWith(duration: d));
    });

    _audioPlayer.onPositionChanged.listen((p) {
      emit(state.copyWith(position: p));
    });
  }

  Future<void> playSong(SongModel song) async {
    final url = song.previewUrl;
    if (url.isEmpty) return;

    if (_currentUrl != url) {
      await _audioPlayer.stop();
      _currentUrl = url;
      emit(state.copyWith(
        status: PlayerStatus.loading,
        position: Duration.zero,
        duration: Duration.zero,
        trackId: song.trackId,
        trackName: song.trackName,
        artistName: song.artistName,
        collectionName: song.collectionName,
        artworkUrl100: song.artworkUrl100,
        previewUrl: song.previewUrl,
      ));
      await _audioPlayer.play(ap.UrlSource(url));
    } else {
      await _audioPlayer.resume();
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();
    emit(state.copyWith(status: PlayerStatus.paused));
  }

  Future<void> stop() async {
    await _audioPlayer.stop();
    _currentUrl = null;
    emit(const PlayerState(status: PlayerStatus.stopped));
  }

  Future<void> seek(Duration position) async {
    await _audioPlayer.seek(position);
    emit(state.copyWith(position: position));
  }

  Future<void> seekRelative(Duration offset) async {
    final newPos = state.position + offset;
    final clamped = newPos < Duration.zero
        ? Duration.zero
        : (state.duration != Duration.zero && newPos > state.duration)
            ? state.duration
            : newPos;
    await _audioPlayer.seek(clamped);
    emit(state.copyWith(position: clamped));
  }

  void toggleShuffle() {
    emit(state.copyWith(isShuffle: !state.isShuffle));
  }

  Future<void> toggleRepeat() async {
    final newRepeat = !state.isRepeat;
    await _audioPlayer.setReleaseMode(
      newRepeat ? ap.ReleaseMode.loop : ap.ReleaseMode.stop,
    );
    emit(state.copyWith(isRepeat: newRepeat));
  }

  @override
  Future<void> close() {
    _audioPlayer.dispose();
    return super.close();
  }
}
