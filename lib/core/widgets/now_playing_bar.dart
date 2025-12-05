
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music_explorer_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:music_explorer_app/features/song_detail/presentation/cubit/player_cubit.dart';
import 'package:music_explorer_app/features/song_detail/presentation/pages/song_detail_screen.dart';
import 'package:music_explorer_app/features/home/data/models/song_model.dart';

class NowPlayingBar extends StatelessWidget {
  const NowPlayingBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerCubit, PlayerState>(
      builder: (context, state) {
        final isActive =
            (state.status == PlayerStatus.playing ||
                state.status == PlayerStatus.paused ||
                state.status == PlayerStatus.loading) &&
            state.trackId != null;

        if (!isActive) {
          return const SizedBox.shrink();
        }

        final song = _resolveSongModel(context, state);
        if (song == null) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final progress = state.duration.inMilliseconds == 0
            ? 0.0
            : state.position.inMilliseconds /
                state.duration.inMilliseconds.clamp(1, double.maxFinite.toInt());

        return Material(
          color: theme.colorScheme.surface,
          elevation: 6,
          child: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => SongDetailScreen(song: song),
                ),
              );
            },
            child: SizedBox(
              height: 64,
              child: Column(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      child: Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CachedNetworkImage(
                              imageUrl: song.artworkUrl100,
                              width: 48,
                              height: 48,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                width: 48,
                                height: 48,
color: theme.colorScheme.surfaceContainerHighest,
                              ),
                              errorWidget: (context, url, error) => Container(
                                width: 48,
                                height: 48,
color: theme.colorScheme.surfaceContainerHighest,
                                child: const Icon(Icons.music_note),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  song.trackName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodyMedium
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  song.artistName,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            iconSize: 28,
                            icon: Icon(
                              state.status == PlayerStatus.playing
                                  ? Icons.pause
                                  : Icons.play_arrow,
                            ),
                            onPressed: () {
                              final cubit = context.read<PlayerCubit>();
                              if (state.status == PlayerStatus.playing) {
                                cubit.pause();
                              } else {
                                cubit.playSong(song);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    minHeight: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  SongModel? _resolveSongModel(BuildContext context, PlayerState state) {
    final homeState = context.read<HomeBloc>().state;
    final fromHome = homeState.songs
        .where((s) => s.trackId == state.trackId)
        .cast<SongModel?>();
    if (fromHome.isNotEmpty) return fromHome.first;

    if (state.trackId == null ||
        state.trackName == null ||
        state.artistName == null ||
        state.collectionName == null ||
        state.artworkUrl100 == null ||
        state.previewUrl == null) {
      return null;
    }

    return SongModel(
      trackId: state.trackId!,
      trackName: state.trackName!,
      artistName: state.artistName!,
      collectionName: state.collectionName!,
      artworkUrl100: state.artworkUrl100!,
      previewUrl: state.previewUrl!,
      artistId: 0,
      collectionId: 0,
    );
  }
}
