import '../entities/reading_settings.dart';

abstract class SettingsRepository {
  Future<ReadingSettings> getSettings();
  Future<void> saveSettings(ReadingSettings settings);
}
