import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../../data/repositories/settings_repository_impl.dart';
import '../../../domain/entities/reading_settings.dart';
import '../../../domain/repositories/settings_repository.dart';

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  return SettingsRepositoryImpl();
});

// Reading settings
final readingSettingsProvider =
    AsyncNotifierProvider<ReadingSettingsNotifier, ReadingSettings>(
  ReadingSettingsNotifier.new,
);

class ReadingSettingsNotifier extends AsyncNotifier<ReadingSettings> {
  @override
  Future<ReadingSettings> build() async {
    final repo = ref.read(settingsRepositoryProvider);
    return repo.getSettings();
  }

  Future<void> updateSettings(ReadingSettings settings) async {
    final repo = ref.read(settingsRepositoryProvider);
    await repo.saveSettings(settings);
    state = AsyncData(settings);
  }
}

// TTS state
enum TtsState { stopped, playing, paused }

class TtsNotifier extends Notifier<TtsState> {
  late FlutterTts _flutterTts;
  List<String> _availableVoices = [];

  @override
  TtsState build() {
    _flutterTts = FlutterTts();
    _setupTts();
    ref.onDispose(() => _flutterTts.stop());
    return TtsState.stopped;
  }

  void _setupTts() {
    _flutterTts.setCompletionHandler(() {
      state = TtsState.stopped;
    });
    _flutterTts.setErrorHandler((msg) {
      state = TtsState.stopped;
    });
    _flutterTts.setCancelHandler(() {
      state = TtsState.stopped;
    });
    _flutterTts.setPauseHandler(() {
      state = TtsState.paused;
    });
    _flutterTts.setContinueHandler(() {
      state = TtsState.playing;
    });
  }

  Future<void> speak(String text, {double rate = 0.5, String? voice}) async {
    await _flutterTts.setLanguage('en-US');
    await _flutterTts.setSpeechRate(rate);
    if (voice != null) {
      await _flutterTts.setVoice({'name': voice, 'locale': 'en-US'});
    }
    final result = await _flutterTts.speak(text);
    if (result == 1) {
      state = TtsState.playing;
    }
  }

  Future<void> pause() async {
    final result = await _flutterTts.pause();
    if (result == 1) {
      state = TtsState.paused;
    }
  }

  Future<void> resume() async {
    // flutter_tts doesn't have a direct resume; re-speak from paused position
    // We use platform-level continue if available
    state = TtsState.playing;
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    state = TtsState.stopped;
  }

  Future<void> setRate(double rate) async {
    await _flutterTts.setSpeechRate(rate);
  }

  Future<List<String>> getAvailableVoices() async {
    try {
      final voices = await _flutterTts.getVoices as List<dynamic>?;
      if (voices != null) {
        _availableVoices = voices
            .map((v) => (v as Map)['name']?.toString() ?? '')
            .where((n) => n.isNotEmpty)
            .toList();
        return _availableVoices;
      }
    } catch (_) {}
    return [];
  }

  FlutterTts get tts => _flutterTts;
}

final ttsProvider = NotifierProvider<TtsNotifier, TtsState>(TtsNotifier.new);

// Current book reader state
class ReaderState {
  final List<String> chapters;
  final int currentChapterIndex;
  final bool isLoading;
  final String? error;

  const ReaderState({
    this.chapters = const [],
    this.currentChapterIndex = 0,
    this.isLoading = false,
    this.error,
  });

  ReaderState copyWith({
    List<String>? chapters,
    int? currentChapterIndex,
    bool? isLoading,
    String? error,
  }) {
    return ReaderState(
      chapters: chapters ?? this.chapters,
      currentChapterIndex: currentChapterIndex ?? this.currentChapterIndex,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class ReaderNotifier extends Notifier<ReaderState> {
  @override
  ReaderState build() => const ReaderState();

  void setChapters(List<String> chapters, int startChapter) {
    state = state.copyWith(
      chapters: chapters,
      currentChapterIndex: startChapter,
      isLoading: false,
    );
  }

  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  void setError(String error) {
    state = state.copyWith(error: error, isLoading: false);
  }

  void nextChapter() {
    if (state.currentChapterIndex < state.chapters.length - 1) {
      state = state.copyWith(
        currentChapterIndex: state.currentChapterIndex + 1,
      );
    }
  }

  void previousChapter() {
    if (state.currentChapterIndex > 0) {
      state = state.copyWith(
        currentChapterIndex: state.currentChapterIndex - 1,
      );
    }
  }

  void goToChapter(int index) {
    if (index >= 0 && index < state.chapters.length) {
      state = state.copyWith(currentChapterIndex: index);
    }
  }
}

final readerProvider =
    NotifierProvider<ReaderNotifier, ReaderState>(ReaderNotifier.new);
