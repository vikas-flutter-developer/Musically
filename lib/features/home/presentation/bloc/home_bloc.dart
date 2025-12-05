
import 'package:bloc/bloc.dart';
import 'package:music_explorer_app/core/constants/api_constants.dart';
import '../../data/repositories/home_repository.dart';
import '../../data/models/song_model.dart'; 
import 'home_event.dart';
import 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final HomeRepository _repository;

  HomeBloc(this._repository) : super(const HomeState()) {
    on<FetchSongsInitial>(_onFetchSongsInitial);
    on<FetchSongsNextPage>(_onFetchSongsNextPage);
  }

  Future<void> _onFetchSongsInitial(
      FetchSongsInitial event,
      Emitter<HomeState> emit,
      ) async {
    if (state.status != HomeStatus.loaded) {
      emit(state.copyWith(status: HomeStatus.loading));
    }

    const initialOffset = 0;

    try {
      final newSongs = await _repository.fetchSongs(
        term: event.searchTerm,
        offset: initialOffset,
      );

      final nextOffset = newSongs.length;
      final hasReachedMax = newSongs.isEmpty || newSongs.length < ApiConstants.pageSize;

      emit(state.copyWith(
        status: HomeStatus.loaded,
        songs: newSongs,
        currentTerm: event.searchTerm,
        offset: nextOffset,
        hasReachedMax: hasReachedMax,
        errorMessage: null,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.error,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onFetchSongsNextPage(
      FetchSongsNextPage event,
      Emitter<HomeState> emit,
      ) async {
    if (state.hasReachedMax || state.status == HomeStatus.loading) return;


    try {
      final newSongs = await _repository.fetchSongs(
        term: state.currentTerm,
        offset: state.offset,
      );

      final hasReachedMax = newSongs.isEmpty || newSongs.length < ApiConstants.pageSize;

      if (hasReachedMax) {
        emit(state.copyWith(hasReachedMax: true));
      } else {
        final updatedSongs = List<SongModel>.from(state.songs)..addAll(newSongs);
        emit(state.copyWith(
          songs: updatedSongs,
          offset: state.offset + newSongs.length,
          hasReachedMax: false,
          errorMessage: null,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: HomeStatus.loaded,
        errorMessage: e.toString(),
      ));
    }
  }
}
