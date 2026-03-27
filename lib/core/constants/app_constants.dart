class AppConstants {
  static const String appName = 'BookReader';
  static const String booksBox = 'books';
  static const String settingsBox = 'settings';

  // Supported formats
  static const List<String> supportedFormats = ['epub', 'fb2'];
  static const List<String> epubExtensions = ['epub'];
  static const List<String> fb2Extensions = ['fb2'];

  // Font families for reader
  static const List<String> fontFamilies = [
    'Georgia',
    'Times New Roman',
    'Arial',
    'Helvetica',
    'Verdana',
    'Roboto',
    'OpenSans',
  ];

  // Font size range
  static const double minFontSize = 12.0;
  static const double maxFontSize = 32.0;
  static const double defaultFontSize = 18.0;

  // Line spacing range
  static const double minLineSpacing = 1.0;
  static const double maxLineSpacing = 3.0;
  static const double defaultLineSpacing = 1.5;

  // TTS rate range
  static const double minTtsRate = 0.1;
  static const double maxTtsRate = 1.0;
  static const double defaultTtsRate = 0.5;
}
