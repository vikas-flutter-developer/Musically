
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import 'package:music_explorer_app/core/constants/api_constants.dart';
import 'package:music_explorer_app/core/utils/theme_cubit.dart';
import 'package:music_explorer_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:music_explorer_app/features/home/presentation/bloc/home_event.dart';
import 'package:music_explorer_app/features/home/presentation/bloc/home_state.dart';
import 'package:music_explorer_app/features/home/presentation/widgets/song_list_item.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const FetchSongsInitial(ApiConstants.defaultSearchTerm));

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<HomeBloc>().add(FetchSongsNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.8);
  }

  void _onSearch(String term) {
    if (term.trim().isNotEmpty) {
      context.read<HomeBloc>().add(FetchSongsInitial(term.trim()));
      FocusScope.of(context).unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = context.watch<ThemeCubit>().state;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;


    final appBarGradient = isDark
        ? const LinearGradient(
            colors: [
              Color(0xFF191414),
              Color(0xFF000000),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )
        : null;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: const Text('Musically'),
        flexibleSpace: isDark && appBarGradient != null
            ? Container(
                decoration: BoxDecoration(
                  gradient: appBarGradient,
                ),
              )
            : null,
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              context
                  .read<ThemeCubit>()
                  .toggleTheme(isDark: !isDark);
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? const [Color(0xFF000000), Color(0xFF121212)]
                : [
                    colorScheme.background,
                    colorScheme.background.withOpacity(0.95),
                  ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  hintText: 'Search songs or artists...',
                  prefixIcon: Icon(Icons.search),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: _onSearch,
              ),
            ),
            Expanded(
              child: BlocBuilder<HomeBloc, HomeState>(
                builder: (context, state) {
                  if (state.status == HomeStatus.loading && state.songs.isEmpty) {
                    return const SongShimmerLoader();
                  }

                  if (state.status == HomeStatus.error && state.songs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Text(
                          'Error: ${state.errorMessage}. Please try again.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colorScheme.error),
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    controller: _scrollController,
                    itemCount: state.songs.length + (state.hasReachedMax ? 0 : 1),
                    itemBuilder: (context, index) {
                      if (index >= state.songs.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final song = state.songs[index];
                      return SongListItem(song: song);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }
}

class SongShimmerLoader extends StatelessWidget {
  const SongShimmerLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 14, width: double.infinity, color: Colors.white),
                      const SizedBox(height: 8),
                      Container(height: 12, width: 150, color: Colors.white),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
