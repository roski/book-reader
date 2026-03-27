import 'package:hive/hive.dart';

part 'reading_settings.g.dart';

enum ReadingTheme { light, sepia, dark }

enum ReadingMode { scroll, paginated }

enum TextAlignment { left, center, right, justify }

@HiveType(typeId: 1)
class ReadingSettings extends HiveObject {
  @HiveField(0)
  String fontFamily;

  @HiveField(1)
  double fontSize;

  @HiveField(2)
  double lineSpacing;

  @HiveField(3)
  int textAlignmentIndex; // index of TextAlignment enum

  @HiveField(4)
  int themeIndex; // index of ReadingTheme enum

  @HiveField(5)
  int readingModeIndex; // index of ReadingMode enum

  @HiveField(6)
  double ttsRate;

  @HiveField(7)
  String? ttsVoice;

  ReadingSettings({
    this.fontFamily = 'Georgia',
    this.fontSize = 18.0,
    this.lineSpacing = 1.5,
    this.textAlignmentIndex = 3, // justify
    this.themeIndex = 0, // light
    this.readingModeIndex = 0, // scroll
    this.ttsRate = 0.5,
    this.ttsVoice,
  });

  TextAlignment get textAlignment => TextAlignment.values[textAlignmentIndex];
  ReadingTheme get theme => ReadingTheme.values[themeIndex];
  ReadingMode get readingMode => ReadingMode.values[readingModeIndex];

  ReadingSettings copyWith({
    String? fontFamily,
    double? fontSize,
    double? lineSpacing,
    int? textAlignmentIndex,
    int? themeIndex,
    int? readingModeIndex,
    double? ttsRate,
    String? ttsVoice,
  }) {
    return ReadingSettings(
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      lineSpacing: lineSpacing ?? this.lineSpacing,
      textAlignmentIndex: textAlignmentIndex ?? this.textAlignmentIndex,
      themeIndex: themeIndex ?? this.themeIndex,
      readingModeIndex: readingModeIndex ?? this.readingModeIndex,
      ttsRate: ttsRate ?? this.ttsRate,
      ttsVoice: ttsVoice ?? this.ttsVoice,
    );
  }
}
