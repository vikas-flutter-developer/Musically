
import 'package:equatable/equatable.dart';
import 'package:music_explorer_app/features/home/data/models/song_model.dart';

enum HomeStatus { initial, loading, loaded, error }

class HomeState extends Equatable {
  final HomeStatus status;
  final List<SongModel> songs;
  final String currentTerm;
  final bool hasReachedMax;
  final String? errorMessage;
  final int offset;

  const HomeState({
    this.status = HomeStatus.initial,
    this.songs = const [],
    this.currentTerm = 'pop',
    this.hasReachedMax = false,
    this.errorMessage,
    this.offset = 0,
  });

  HomeState copyWith({
    HomeStatus? status,
    List<SongModel>? songs,
    String? currentTerm,
    bool? hasReachedMax,
    String? errorMessage,
    int? offset,
  }) {
    return HomeState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      currentTerm: currentTerm ?? this.currentTerm,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      errorMessage: errorMessage,
      offset: offset ?? this.offset,
    );
  }

  @override
  List<Object?> get props => [status, songs, currentTerm, hasReachedMax, errorMessage, offset];
}
