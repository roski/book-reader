import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../domain/entities/reading_settings.dart';
import '../providers/reader_provider.dart';
import '../../../core/constants/app_constants.dart';

class ReaderSettingsPanel extends ConsumerWidget {
  const ReaderSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(readingSettingsProvider);

    return settingsAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => SizedBox(
        height: 200,
        child: Center(child: Text('Error: $e')),
      ),
      data: (settings) => _buildPanel(context, ref, settings),
    );
  }

  Widget _buildPanel(
    BuildContext context,
    WidgetRef ref,
    ReadingSettings settings,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outline,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Reading Settings',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),

          // Theme selection
          Text('Theme', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: ReadingTheme.values.map((theme) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _ThemeButton(
                  theme: theme,
                  isSelected: settings.theme == theme,
                  onTap: () {
                    ref.read(readingSettingsProvider.notifier).updateSettings(
                          settings.copyWith(themeIndex: theme.index),
                        );
                  },
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // Font family
          Text('Font Family', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: settings.fontFamily,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            items: AppConstants.fontFamilies
                .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                ref.read(readingSettingsProvider.notifier).updateSettings(
                      settings.copyWith(fontFamily: value),
                    );
              }
            },
          ),
          const SizedBox(height: 16),

          // Font size
          Text(
            'Font Size: ${settings.fontSize.round()}pt',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: settings.fontSize,
            min: AppConstants.minFontSize,
            max: AppConstants.maxFontSize,
            divisions: 20,
            onChanged: (value) {
              ref.read(readingSettingsProvider.notifier).updateSettings(
                    settings.copyWith(fontSize: value),
                  );
            },
          ),

          // Line spacing
          Text(
            'Line Spacing: ${settings.lineSpacing.toStringAsFixed(1)}',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: settings.lineSpacing,
            min: AppConstants.minLineSpacing,
            max: AppConstants.maxLineSpacing,
            divisions: 20,
            onChanged: (value) {
              ref.read(readingSettingsProvider.notifier).updateSettings(
                    settings.copyWith(lineSpacing: value),
                  );
            },
          ),

          // Text alignment
          Text(
            'Text Alignment',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              _AlignmentButton(
                icon: Icons.format_align_left,
                label: 'Left',
                isSelected:
                    settings.textAlignment == TextAlignment.left,
                onTap: () {
                  ref.read(readingSettingsProvider.notifier).updateSettings(
                        settings.copyWith(
                            textAlignmentIndex: TextAlignment.left.index),
                      );
                },
              ),
              const SizedBox(width: 8),
              _AlignmentButton(
                icon: Icons.format_align_center,
                label: 'Center',
                isSelected:
                    settings.textAlignment == TextAlignment.center,
                onTap: () {
                  ref.read(readingSettingsProvider.notifier).updateSettings(
                        settings.copyWith(
                            textAlignmentIndex: TextAlignment.center.index),
                      );
                },
              ),
              const SizedBox(width: 8),
              _AlignmentButton(
                icon: Icons.format_align_right,
                label: 'Right',
                isSelected:
                    settings.textAlignment == TextAlignment.right,
                onTap: () {
                  ref.read(readingSettingsProvider.notifier).updateSettings(
                        settings.copyWith(
                            textAlignmentIndex: TextAlignment.right.index),
                      );
                },
              ),
              const SizedBox(width: 8),
              _AlignmentButton(
                icon: Icons.format_align_justify,
                label: 'Justify',
                isSelected:
                    settings.textAlignment == TextAlignment.justify,
                onTap: () {
                  ref.read(readingSettingsProvider.notifier).updateSettings(
                        settings.copyWith(
                            textAlignmentIndex: TextAlignment.justify.index),
                      );
                },
              ),
            ],
          ),

          // Reading mode
          const SizedBox(height: 16),
          Text('Reading Mode', style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  label: 'Scroll',
                  icon: Icons.unfold_more,
                  isSelected: settings.readingMode == ReadingMode.scroll,
                  onTap: () {
                    ref.read(readingSettingsProvider.notifier).updateSettings(
                          settings.copyWith(
                              readingModeIndex: ReadingMode.scroll.index),
                        );
                  },
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _ModeButton(
                  label: 'Pages',
                  icon: Icons.menu_book,
                  isSelected:
                      settings.readingMode == ReadingMode.paginated,
                  onTap: () {
                    ref.read(readingSettingsProvider.notifier).updateSettings(
                          settings.copyWith(
                              readingModeIndex: ReadingMode.paginated.index),
                        );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ThemeButton extends StatelessWidget {
  final ReadingTheme theme;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeButton({
    required this.theme,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getThemeColors();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : colors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          _getLabel(),
          style: TextStyle(color: colors.text, fontWeight: FontWeight.w500),
        ),
      ),
    );
  }

  _ThemeButtonColors _getThemeColors() {
    switch (theme) {
      case ReadingTheme.light:
        return _ThemeButtonColors(
          background: Colors.white,
          border: Colors.grey.shade300,
          text: Colors.black87,
        );
      case ReadingTheme.sepia:
        return const _ThemeButtonColors(
          background: Color(0xFFF4ECD8),
          border: Color(0xFFD4B896),
          text: Color(0xFF3B2F2F),
        );
      case ReadingTheme.dark:
        return const _ThemeButtonColors(
          background: Color(0xFF1A1A2E),
          border: Color(0xFF444466),
          text: Colors.white,
        );
    }
  }

  String _getLabel() {
    switch (theme) {
      case ReadingTheme.light:
        return 'Light';
      case ReadingTheme.sepia:
        return 'Sepia';
      case ReadingTheme.dark:
        return 'Dark';
    }
  }
}

class _ThemeButtonColors {
  final Color background;
  final Color border;
  final Color text;

  const _ThemeButtonColors({
    required this.background,
    required this.border,
    required this.text,
  });
}

class _AlignmentButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _AlignmentButton({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.outline,
            ),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
    );
  }
}

class _ModeButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.outline,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurface,
              size: 18,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.onSurface,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
