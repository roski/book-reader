import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/reader_provider.dart';
import '../../../core/constants/app_constants.dart';

class TtsControls extends ConsumerWidget {
  final String text;
  final Color backgroundColor;
  final Color foregroundColor;

  const TtsControls({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.foregroundColor,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ttsState = ref.watch(ttsProvider);
    final settingsAsync = ref.watch(readingSettingsProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: backgroundColor.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous / Play / Pause / Stop
          IconButton(
            icon: Icon(
              ttsState == TtsState.playing
                  ? Icons.pause_circle_filled
                  : Icons.play_circle_filled,
              color: foregroundColor,
              size: 36,
            ),
            onPressed: () {
              settingsAsync.whenData((settings) async {
                if (ttsState == TtsState.playing) {
                  await ref.read(ttsProvider.notifier).pause();
                } else if (ttsState == TtsState.paused) {
                  // Re-speak from beginning of current chapter
                  await ref.read(ttsProvider.notifier).speak(
                        text,
                        rate: settings.ttsRate,
                        voice: settings.ttsVoice,
                      );
                } else {
                  await ref.read(ttsProvider.notifier).speak(
                        text,
                        rate: settings.ttsRate,
                        voice: settings.ttsVoice,
                      );
                }
              });
            },
          ),
          IconButton(
            icon: Icon(Icons.stop_circle_outlined, color: foregroundColor),
            onPressed: () => ref.read(ttsProvider.notifier).stop(),
          ),

          const Spacer(),

          // TTS state indicator
          Text(
            _stateLabel(ttsState),
            style: TextStyle(color: foregroundColor, fontSize: 12),
          ),

          const Spacer(),

          // Rate control
          settingsAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
            data: (settings) => Row(
              children: [
                Icon(Icons.speed, color: foregroundColor, size: 16),
                SizedBox(
                  width: 100,
                  child: Slider(
                    value: settings.ttsRate,
                    min: AppConstants.minTtsRate,
                    max: AppConstants.maxTtsRate,
                    divisions: 18,
                    activeColor: foregroundColor,
                    inactiveColor: foregroundColor.withValues(alpha: 0.3),
                    onChanged: (value) {
                      ref
                          .read(readingSettingsProvider.notifier)
                          .updateSettings(settings.copyWith(ttsRate: value));
                      ref.read(ttsProvider.notifier).setRate(value);
                    },
                  ),
                ),
                Text(
                  '${settings.ttsRate.toStringAsFixed(1)}x',
                  style: TextStyle(color: foregroundColor, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _stateLabel(TtsState state) {
    switch (state) {
      case TtsState.playing:
        return '🔊 Playing';
      case TtsState.paused:
        return '⏸ Paused';
      case TtsState.stopped:
        return '⏹ Stopped';
    }
  }
}
