import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_html/flutter_html.dart';
import '../../../data/datasources/epub_datasource.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/entities/reading_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/reader_provider.dart';
import '../../bookshelf/providers/bookshelf_provider.dart';
import '../widgets/reader_settings_panel.dart';
import '../widgets/tts_controls.dart';

class ReaderScreen extends ConsumerStatefulWidget {
  final String bookId;

  const ReaderScreen({super.key, required this.bookId});

  @override
  ConsumerState<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends ConsumerState<ReaderScreen> {
  Book? _book;
  bool _showControls = true;
  bool _showTts = false;
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBook();
      _scheduleHideControls();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    _hideControlsTimer?.cancel();
    // Stop TTS when leaving reader
    ref.read(ttsProvider.notifier).stop();
    super.dispose();
  }

  Future<void> _loadBook() async {
    final repo = ref.read(bookRepositoryProvider);
    final book = await repo.getBookById(widget.bookId);
    if (book == null || !mounted) return;

    setState(() => _book = book);

    ref.read(readerProvider.notifier).setLoading(true);

    try {
      if (book.format == 'epub') {
        final epubDS = ref.read(epubDataSourceProvider);
        final epubBook = await epubDS.parseEpub(book.filePath);
        if (epubBook == null) {
          ref.read(readerProvider.notifier).setError('Failed to parse EPUB file');
          return;
        }
        final chapters = epubDS.getChaptersContent(epubBook);
        final chapterHtmlList = chapters.map((c) => c.htmlContent).toList();

        // Restore position
        final startChapter = (book.readingProgress * chapterHtmlList.length).round().clamp(
          0,
          chapterHtmlList.isEmpty ? 0 : chapterHtmlList.length - 1,
        );

        ref.read(readerProvider.notifier).setChapters(chapterHtmlList, startChapter);
      } else if (book.format == 'fb2') {
        // FB2 - read as plain text/XML
        ref.read(readerProvider.notifier).setChapters(
          ['<p>FB2 format preview. Full FB2 rendering coming soon.</p>'],
          0,
        );
      }
    } catch (e) {
      ref.read(readerProvider.notifier).setError('Error loading book: $e');
    }
  }

  void _scheduleHideControls() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() => _showControls = false);
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) {
      _scheduleHideControls();
    }
  }

  Future<void> _saveProgress(int chapterIndex, int totalChapters) async {
    if (_book == null || totalChapters == 0) return;
    final progress = totalChapters > 1
        ? chapterIndex / (totalChapters - 1)
        : 1.0;
    await ref.read(booksProvider.notifier).updateReadingProgress(
      widget.bookId,
      progress.clamp(0.0, 1.0),
      currentPage: chapterIndex,
      totalPages: totalChapters,
    );
  }

  @override
  Widget build(BuildContext context) {
    final readerState = ref.watch(readerProvider);
    final settingsAsync = ref.watch(readingSettingsProvider);

    return settingsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Scaffold(
        body: Center(child: Text('Settings error: $e')),
      ),
      data: (settings) => _buildReader(context, readerState, settings),
    );
  }

  Widget _buildReader(
    BuildContext context,
    ReaderState readerState,
    ReadingSettings settings,
  ) {
    final themeColors = AppTheme.getReaderTheme(settings.theme);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: settings.theme == ReadingTheme.dark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: themeColors.background,
        body: Stack(
          children: [
            // Main reading area
            GestureDetector(
              onTap: _toggleControls,
              child: _buildContent(context, readerState, settings, themeColors),
            ),

            // Top app bar
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              top: _showControls ? 0 : -100,
              left: 0,
              right: 0,
              child: _buildTopBar(context, settings, themeColors, readerState),
            ),

            // Bottom TTS controls
            if (_showTts)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: TtsControls(
                  text: readerState.chapters.isNotEmpty
                      ? _stripHtml(readerState.chapters[readerState.currentChapterIndex])
                      : '',
                  backgroundColor: themeColors.appBar,
                  foregroundColor: themeColors.appBarText,
                ),
              ),

            // Chapter navigation (paginated mode)
            if (settings.readingMode == ReadingMode.paginated && _showControls)
              _buildPaginationControls(context, readerState, themeColors),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext context,
    ReadingSettings settings,
    ReaderThemeColors themeColors,
    ReaderState readerState,
  ) {
    return Container(
      color: themeColors.appBar,
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: themeColors.appBarText),
              onPressed: () => Navigator.pop(context),
            ),
            Expanded(
              child: Text(
                _book?.title ?? '',
                style: TextStyle(
                  color: themeColors.appBarText,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            // TTS toggle
            IconButton(
              icon: Icon(
                _showTts ? Icons.record_voice_over : Icons.play_arrow,
                color: themeColors.appBarText,
              ),
              tooltip: 'Text to Speech',
              onPressed: () => setState(() => _showTts = !_showTts),
            ),
            // Settings
            IconButton(
              icon: Icon(Icons.settings, color: themeColors.appBarText),
              onPressed: () => _showSettings(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    ReaderState readerState,
    ReadingSettings settings,
    ReaderThemeColors themeColors,
  ) {
    if (readerState.isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: themeColors.text,
        ),
      );
    }

    if (readerState.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: themeColors.text),
              const SizedBox(height: 16),
              Text(
                readerState.error!,
                style: TextStyle(color: themeColors.text),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadBook,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (readerState.chapters.isEmpty) {
      return Center(
        child: Text(
          'No content found in this book.',
          style: TextStyle(color: themeColors.text),
        ),
      );
    }

    if (settings.readingMode == ReadingMode.paginated) {
      return _buildPaginatedView(readerState, settings, themeColors);
    } else {
      return _buildScrollView(readerState, settings, themeColors);
    }
  }

  Widget _buildScrollView(
    ReaderState readerState,
    ReadingSettings settings,
    ReaderThemeColors themeColors,
  ) {
    final padding = MediaQuery.of(context).padding;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        24,
        padding.top + 72,
        24,
        _showTts ? 100 : 24,
      ),
      child: Column(
        children: readerState.chapters.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 32),
            child: _buildHtmlContent(
              entry.value,
              settings,
              themeColors,
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaginatedView(
    ReaderState readerState,
    ReadingSettings settings,
    ReaderThemeColors themeColors,
  ) {
    final padding = MediaQuery.of(context).padding;

    return PageView.builder(
      controller: _pageController,
      itemCount: readerState.chapters.length,
      onPageChanged: (index) {
        ref.read(readerProvider.notifier).goToChapter(index);
        _saveProgress(index, readerState.chapters.length);
      },
      itemBuilder: (context, index) {
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            padding.top + 72,
            24,
            _showTts ? 120 : 48,
          ),
          child: _buildHtmlContent(
            readerState.chapters[index],
            settings,
            themeColors,
          ),
        );
      },
    );
  }

  Widget _buildHtmlContent(
    String html,
    ReadingSettings settings,
    ReaderThemeColors themeColors,
  ) {
    final textAlign = _getTextAlign(settings.textAlignment);

    return Html(
      data: html,
      style: {
        'body': Style(
          fontSize: FontSize(settings.fontSize),
          fontFamily: settings.fontFamily,
          color: themeColors.text,
          lineHeight: LineHeight(settings.lineSpacing),
          textAlign: textAlign,
          backgroundColor: themeColors.background,
        ),
        'p': Style(
          fontSize: FontSize(settings.fontSize),
          fontFamily: settings.fontFamily,
          color: themeColors.text,
          lineHeight: LineHeight(settings.lineSpacing),
          textAlign: textAlign,
        ),
        'h1': Style(
          fontSize: FontSize(settings.fontSize * 1.6),
          fontFamily: settings.fontFamily,
          color: themeColors.text,
          fontWeight: FontWeight.bold,
        ),
        'h2': Style(
          fontSize: FontSize(settings.fontSize * 1.4),
          fontFamily: settings.fontFamily,
          color: themeColors.text,
          fontWeight: FontWeight.bold,
        ),
        'h3': Style(
          fontSize: FontSize(settings.fontSize * 1.2),
          fontFamily: settings.fontFamily,
          color: themeColors.text,
          fontWeight: FontWeight.bold,
        ),
        'a': Style(color: themeColors.text.withOpacity(0.7)),
      },
    );
  }

  Widget _buildPaginationControls(
    BuildContext context,
    ReaderState readerState,
    ReaderThemeColors themeColors,
  ) {
    final total = readerState.chapters.length;
    final current = readerState.currentChapterIndex;

    return Positioned(
      bottom: _showTts ? 100 : 24,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          if (current > 0)
            _NavButton(
              icon: Icons.chevron_left,
              onTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              color: themeColors.appBarText,
              background: themeColors.appBar,
            )
          else
            const SizedBox(width: 56),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: themeColors.appBar.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${current + 1} / $total',
              style: TextStyle(color: themeColors.appBarText, fontSize: 12),
            ),
          ),
          if (current < total - 1)
            _NavButton(
              icon: Icons.chevron_right,
              onTap: () {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
              color: themeColors.appBarText,
              background: themeColors.appBar,
            )
          else
            const SizedBox(width: 56),
        ],
      ),
    );
  }

  TextAlign _getTextAlign(TextAlignment alignment) {
    switch (alignment) {
      case TextAlignment.left:
        return TextAlign.left;
      case TextAlignment.center:
        return TextAlign.center;
      case TextAlignment.right:
        return TextAlign.right;
      case TextAlignment.justify:
        return TextAlign.justify;
    }
  }

  String _stripHtml(String html) {
    return html
        .replaceAll(RegExp(r'<[^>]*>'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  void _showSettings(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.85,
        maxChildSize: 0.95,
        minChildSize: 0.4,
        expand: false,
        builder: (_, controller) => SingleChildScrollView(
          controller: controller,
          child: const ReaderSettingsPanel(),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;
  final Color background;

  const _NavButton({
    required this.icon,
    required this.onTap,
    required this.color,
    required this.background,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: background.withValues(alpha: 0.8),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 24),
      ),
    );
  }
}
