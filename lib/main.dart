
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_explorer_app/core/constants/theme_constants.dart';
import 'package:music_explorer_app/core/utils/local_storage_service.dart';
import 'package:music_explorer_app/core/utils/theme_cubit.dart';
import 'package:music_explorer_app/features/favorites/data/repositories/favorites_repository.dart';
import 'package:music_explorer_app/features/favorites/presentation/cubit/favorites_cubit.dart';
import 'package:music_explorer_app/features/favorites/presentation/pages/favorites_screen.dart' as fav_page;
import 'package:music_explorer_app/features/home/data/repositories/home_repository.dart';
import 'package:music_explorer_app/features/home/presentation/bloc/home_bloc.dart';
import 'package:music_explorer_app/features/home/presentation/pages/home_screen.dart';
import 'package:music_explorer_app/features/song_detail/presentation/cubit/player_cubit.dart';
import 'package:music_explorer_app/core/widgets/now_playing_bar.dart';

final LocalStorageService localStorageService = LocalStorageService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await localStorageService.init(); 
  runApp(const MusicExplorerApp());
}

class MusicExplorerApp extends StatelessWidget {
  const MusicExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final homeRepository = HomeRepository();
    final favoritesRepository = FavoritesRepository(localStorageService);

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<HomeRepository>(create: (_) => homeRepository),
        RepositoryProvider<FavoritesRepository>(create: (_) => favoritesRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(localStorageService),
          ),
          BlocProvider<HomeBloc>(
            create: (context) => HomeBloc(homeRepository),
          ),
          BlocProvider<FavoritesCubit>(
            create: (context) => FavoritesCubit(favoritesRepository),
          ),
          BlocProvider<PlayerCubit>(
            create: (_) => PlayerCubit(),
          ),
        ],
        child: BlocBuilder<ThemeCubit, bool>(
          builder: (context, isDark) {
            return MaterialApp(
              title: 'Music Explorer',
              debugShowCheckedModeBanner: false,
              theme: isDark ? darkTheme : lightTheme,
              home: const SplashScreen(),
            );
          },
        ),
      ),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();

    
    Future.delayed(const Duration(milliseconds: 1800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const MainAppShell(),
        ),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.black,
              Colors.black,
              colorScheme.primary.withOpacity(0.35),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            
            Positioned(
              top: -80,
              right: -40,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.primary.withOpacity(0.45),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -60,
              left: -40,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      colorScheme.secondaryContainer.withOpacity(0.4),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            Center(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondaryContainer,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.6),
                              blurRadius: 28,
                              spreadRadius: 4,
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              Icons.music_note_rounded,
                              color: Colors.black,
                              size: 56,
                            ),
                            Positioned(
                              bottom: 18,
                              right: 20,
                              child: Container(
                                width: 26,
                                height: 26,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.black,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(0.9),
                                    width: 1.6,
                                  ),
                                ),
                                child: Icon(
                                  Icons.play_arrow_rounded,
                                  color: colorScheme.primary,
                                  size: 18,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 26),
                      Text(
                        'Musically',
                        style: theme.textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.4,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Discover, play & favorite new tracks',
                        style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.74),
                              letterSpacing: 0.6,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 34),
                      SizedBox(
                        width: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.primary,
                            ),
                            backgroundColor:
                                Colors.white.withOpacity(0.18),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainAppShell extends StatefulWidget {
  const MainAppShell({super.key});

  @override
  State<MainAppShell> createState() => _MainAppShellState();
}

class _MainAppShellState extends State<MainAppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    fav_page.FavoritesScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
          ),
          const NowPlayingBar(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
