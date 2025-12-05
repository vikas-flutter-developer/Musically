
import 'package:equatable/equatable.dart';

class FavoritesState extends Equatable {
  final List<int> favoriteTrackIds;

  const FavoritesState({
    this.favoriteTrackIds = const [],
  });

  FavoritesState copyWith({
    List<int>? favoriteTrackIds,
  }) {
    return FavoritesState(
      favoriteTrackIds: favoriteTrackIds ?? this.favoriteTrackIds,
    );
  }

  @override
  List<Object> get props => [favoriteTrackIds];
}
