
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_explorer_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:music_explorer_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:music_explorer_app/features/favorites/data/repositories/favorites_repository.dart';
import 'package:music_explorer_app/features/home/data/models/song_model.dart';
import 'package:music_explorer_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:music_explorer_app/features/home/presentation/bloc/home_state.dart';
import 'package:music_explorer_app/features/home/presentation/widgets/song_list_item.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, favState) {
        final favoriteIds = favState.favoriteTrackIds;

        return BlocBuilder<HomeBloc, HomeState>(
          builder: (context, homeState) {
            final favoritesRepo = context.read<FavoritesRepository>();

            final allKnownSongs = homeState.songs;

            final List<SongModel> favoriteSongs = [];
            for (final id in favoriteIds) {
              final fromHome =
                  allKnownSongs.where((s) => s.trackId == id).cast<SongModel?>();
              if (fromHome.isNotEmpty) {
                favoriteSongs.add(fromHome.first!);
                continue;
              }

              final cached = favoritesRepo.loadCachedFavoriteSong(id);
              if (cached != null) {
                favoriteSongs.add(cached);
              }
            }

            if (favoriteIds.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.favorite_border,
                        size: 80,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.6),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No Favorites Saved',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Tap the heart icon on the Home Screen to save songs here. Favorites are visible offline!',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            return ListView.builder(
              itemCount: favoriteSongs.length,
              itemBuilder: (context, index) {
                final song = favoriteSongs[index];

                return Dismissible(
                  key: Key(song.trackId.toString()), 
                  direction: DismissDirection.endToStart,
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20.0),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  onDismissed: (direction) {
                    context.read<FavoritesCubit>().toggleFavorite(song);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('${song.trackName} removed from Favorites')),
                    );
                  },
                  child: SongListItem(song: song),
                );
              },
            );
          },
        );
      },
    );
  }
}
