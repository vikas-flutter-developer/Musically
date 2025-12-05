
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math';
import 'dart:ui';

import 'package:music_explorer_app/features/home/data/models/song_model.dart';
import 'package:music_explorer_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:music_explorer_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:music_explorer_app/features/favorites/presentation/cubit/favorites_state.dart';
import 'package:music_explorer_app/features/song_detail/presentation/cubit/player_cubit.dart';

class SongDetailScreen extends StatelessWidget {
  final SongModel song;

  const SongDetailScreen({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Always use white for the foreground so the title & back button
        // are visible on top of the blurred dark background image.
        foregroundColor: Colors.white,
        title: Text(
          song.collectionName,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: song.highResArtworkUrl,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
              child: Container(
                color: Colors.black.withOpacity(0.4), 
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),
                  Expanded(
                    child: Center(
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.6),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(24.0),
                          child: AspectRatio(
                            aspectRatio: 1,
                            child: CachedNetworkImage(
                              imageUrl: song.highResArtworkUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                color: Colors.black26,
                                child: const Center(
                                    child: CircularProgressIndicator()),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.black26,
                                child: const Center(
                                  child: Icon(Icons.broken_image,
                                      size: 50, color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    song.trackName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ) ??
                        const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    song.artistName,
                    style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                              color: Colors.white70,
                            ) ??
                        const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<PlayerCubit, PlayerState>(
                    builder: (context, playerState) {
                      final totalSeconds =
                          playerState.duration.inSeconds.toDouble();
                      final positionSeconds =
                          playerState.position.inSeconds.toDouble();
                      final max = totalSeconds > 0 ? totalSeconds : 1.0;
                      final value = positionSeconds.clamp(0, max);

                      final remaining =
                          playerState.duration - playerState.position;

                      return Column(
                        children: [
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              trackHeight: 3,
                              thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6),
                            ),
                            child: Slider(
                              value: value.toDouble(),
                              min: 0,
                              max: max,
                              onChanged: (v) {
                                context.read<PlayerCubit>().seek(
                                      Duration(seconds: v.toInt()),
                                    );
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                _formatDuration(playerState.position),
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                              Text(
                                '-${_formatDuration(remaining.isNegative ? Duration.zero : remaining)}',
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 12),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<PlayerCubit, PlayerState>(
                    builder: (context, playerState) {
                      final status = playerState.status;
                      final playerCubit = context.read<PlayerCubit>();

                      final homeState = context.watch<HomeBloc>().state;
                      final songs = homeState.songs;
                      final currentIndex =
                          songs.indexWhere((s) => s.trackId == song.trackId);

                      void playSongAt(int targetIndex) {
                        if (songs.isEmpty || targetIndex < 0) return;
                        final normalizedIndex = targetIndex % songs.length;
                        final targetSong = songs[normalizedIndex];
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => SongDetailScreen(song: targetSong),
                          ),
                        );
                        playerCubit.playSong(targetSong);
                      }

                      int? getPrevIndex() {
                        if (songs.isEmpty || currentIndex == -1) return null;
                        if (playerState.isShuffle && songs.length > 1) {
                          final rand = Random();
                          int idx;
                          do {
                            idx = rand.nextInt(songs.length);
                          } while (idx == currentIndex);
                          return idx;
                        }
                        return currentIndex == 0
                            ? songs.length - 1
                            : currentIndex - 1;
                      }

                      int? getNextIndex() {
                        if (songs.isEmpty || currentIndex == -1) return null;
                        if (playerState.isShuffle && songs.length > 1) {
                          final rand = Random();
                          int idx;
                          do {
                            idx = rand.nextInt(songs.length);
                          } while (idx == currentIndex);
                          return idx;
                        }
                        return (currentIndex + 1) % songs.length;
                      }

                      final prevIndex = getPrevIndex();
                      final nextIndex = getNextIndex();

                      return Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                iconSize: 28,
                                color: prevIndex == null
                                    ? Colors.white24
                                    : Colors.white70,
                                onPressed: prevIndex == null
                                    ? null
                                    : () => playSongAt(prevIndex),
                                icon: const Icon(Icons.skip_previous),
                              ),
                              IconButton(
                                iconSize: 64,
                                color: Colors.white,
                                onPressed: song.previewUrl.isEmpty
                                    ? null
                                    : () {
                                        if (status == PlayerStatus.playing) {
                                          playerCubit.pause();
                                        } else {
                                          playerCubit.playSong(song);
                                        }
                                      },
                                icon: _buildPlayerIcon(status),
                              ),
                              IconButton(
                                iconSize: 28,
                                color: nextIndex == null
                                    ? Colors.white24
                                    : Colors.white70,
                                onPressed: nextIndex == null
                                    ? null
                                    : () => playSongAt(nextIndex),
                                icon: const Icon(Icons.skip_next),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                iconSize: 24,
                                color: playerState.isShuffle
                                    ? Colors.greenAccent
                                    : Colors.white70,
                                onPressed: () {
                                  context
                                      .read<PlayerCubit>()
                                      .toggleShuffle();
                                },
                                icon: const Icon(Icons.shuffle),
                              ),
                              IconButton(
                                iconSize: 24,
                                color: playerState.isRepeat
                                    ? Colors.greenAccent
                                    : Colors.white70,
                                onPressed: () {
                                  context
                                      .read<PlayerCubit>()
                                      .toggleRepeat();
                                },
                                icon: const Icon(Icons.repeat),
                              ),
                            ],
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  BlocBuilder<FavoritesCubit, FavoritesState>(
                    builder: (context, favState) {
                      final isFavorite =
                          favState.favoriteTrackIds.contains(song.trackId);
                      return Align(
                        alignment: Alignment.centerRight,
                        child: IconButton(
                          iconSize: 28,
                          color: isFavorite
                              ? Colors.greenAccent
                              : Colors.white70,
                          onPressed: () {
                            context.read<FavoritesCubit>().toggleFavorite(song);
                          },
                          icon: Icon(
                            isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon _buildPlayerIcon(PlayerStatus status) {
    if (status == PlayerStatus.loading) {
      return const Icon(Icons.hourglass_bottom);
    } else if (status == PlayerStatus.playing) {
      return const Icon(Icons.pause_circle_filled);
    } else {
      return const Icon(Icons.play_circle_filled);
    }
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(1, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }
}
