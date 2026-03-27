import 'package:flutter/material.dart';
import '../../domain/entities/reading_settings.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5C6BC0),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: 4,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF5C6BC0),
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: true,
      ),
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  // Reading theme colors
  static ReaderThemeColors getReaderTheme(ReadingTheme theme) {
    switch (theme) {
      case ReadingTheme.light:
        return const ReaderThemeColors(
          background: Color(0xFFFFFFFF),
          text: Color(0xFF1A1A1A),
          appBar: Color(0xFFF5F5F5),
          appBarText: Color(0xFF1A1A1A),
        );
      case ReadingTheme.sepia:
        return const ReaderThemeColors(
          background: Color(0xFFF4ECD8),
          text: Color(0xFF3B2F2F),
          appBar: Color(0xFFE8D5B7),
          appBarText: Color(0xFF3B2F2F),
        );
      case ReadingTheme.dark:
        return const ReaderThemeColors(
          background: Color(0xFF1A1A2E),
          text: Color(0xFFE0E0E0),
          appBar: Color(0xFF16213E),
          appBarText: Color(0xFFE0E0E0),
        );
    }
  }
}

class ReaderThemeColors {
  final Color background;
  final Color text;
  final Color appBar;
  final Color appBarText;

  const ReaderThemeColors({
    required this.background,
    required this.text,
    required this.appBar,
    required this.appBarText,
  });
}
