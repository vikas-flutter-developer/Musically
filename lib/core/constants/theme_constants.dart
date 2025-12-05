import 'package:flutter/material.dart';


const _primaryColor = Color(0xFF1DB954); 
const _secondaryColor = Color(0xFF1ED760); 
const _backgroundLight = Color(0xFFFDFDFD);
const _backgroundDark = Color(0xFF000000); 
const _surfaceLight = Colors.white;
const _surfaceDark = Color(0xFF121212); 

ThemeData _baseTheme(ColorScheme colorScheme, {required bool isDark}) {
  final textTheme = Typography.englishLike2021.apply(
    fontFamily: 'Poppins', 
    bodyColor: colorScheme.onBackground,
    displayColor: colorScheme.onBackground,
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: colorScheme,
    scaffoldBackgroundColor:
        isDark ? _backgroundDark : _backgroundLight,
    textTheme: textTheme,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: isDark ? _surfaceDark : _surfaceLight,
      foregroundColor: isDark ? Colors.white : Colors.black,
      centerTitle: true,
      titleTextStyle: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
      iconTheme: IconThemeData(
        color: isDark ? Colors.white : Colors.black,
      ),
    ),
    cardTheme: CardThemeData(
      color: isDark ? _surfaceDark : _surfaceLight,
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: isDark
          ? colorScheme.surface.withOpacity(0.9)
          : Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      hintStyle: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withOpacity(0.6),
      ),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: isDark ? _surfaceDark : Colors.white,
      selectedItemColor: _secondaryColor,
      unselectedItemColor: colorScheme.onSurface.withOpacity(0.6),
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      selectedIconTheme: const IconThemeData(size: 26),
    ),
    iconTheme: IconThemeData(color: colorScheme.onBackground),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(999),
        ),
      ),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: _secondaryColor,
      foregroundColor: Colors.black,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    splashFactory: InkSparkle.splashFactory,
  );
}

final ColorScheme _lightColorScheme = ColorScheme.fromSeed(
  seedColor: _primaryColor,
  brightness: Brightness.light,
).copyWith(
  background: _backgroundLight,
  surface: _surfaceLight,
);

final ColorScheme _darkColorScheme = ColorScheme.fromSeed(
  seedColor: _primaryColor,
  brightness: Brightness.dark,
).copyWith(
  background: _backgroundDark,
  surface: _surfaceDark,
);

final lightTheme = _baseTheme(
  _lightColorScheme,
  isDark: false,
);

final darkTheme = _baseTheme(
  _darkColorScheme,
  isDark: true,
);
