import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/entities/reading_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl implements SettingsRepository {
  static const String _boxName = 'settings';
  static const String _settingsKey = 'reading_settings';

  Box<ReadingSettings> get _box => Hive.box<ReadingSettings>(_boxName);

  @override
  Future<ReadingSettings> getSettings() async {
    return _box.get(_settingsKey) ?? ReadingSettings();
  }

  @override
  Future<void> saveSettings(ReadingSettings settings) async {
    await _box.put(_settingsKey, settings);
  }
}
