import 'dart:io';
import 'dart:typed_data';
import 'package:epubx/epubx.dart';
import 'package:path_provider/path_provider.dart';

class EpubDataSource {
  /// Parses an EPUB file and returns the book metadata
  Future<EpubBook?> parseEpub(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      return await EpubReader.readBook(bytes);
    } catch (e) {
      return null;
    }
  }

  /// Extracts the cover image from an EPUB book and saves it locally
  Future<String?> extractCoverImage(EpubBook epubBook, String bookId) async {
    try {
      // Try to find cover image in the book content
      final images = epubBook.Content?.Images;
      if (images == null || images.isEmpty) return null;

      // Look for an image file that contains 'cover' in its name
      EpubByteContentFile? coverFile;
      for (final entry in images.entries) {
        if (entry.key.toLowerCase().contains('cover')) {
          coverFile = entry.value;
          break;
        }
      }

      // If no cover-named image, use the first image
      coverFile ??= images.values.first;

      final imageBytes = coverFile.Content;
      if (imageBytes == null || imageBytes.isEmpty) return null;

      final appDir = await getApplicationDocumentsDirectory();
      final coversDir = Directory('${appDir.path}/covers');
      if (!await coversDir.exists()) {
        await coversDir.create(recursive: true);
      }

      // Determine extension from content type or default to jpg
      final extension = _getImageExtension(coverFile.ContentType);
      final coverPath = '${coversDir.path}/$bookId$extension';
      final coverFileOut = File(coverPath);
      await coverFileOut.writeAsBytes(Uint8List.fromList(imageBytes));
      return coverPath;
    } catch (e) {
      return null;
    }
  }

  String _getImageExtension(EpubContentType? contentType) {
    switch (contentType) {
      case EpubContentType.IMAGE_PNG:
        return '.png';
      case EpubContentType.IMAGE_GIF:
        return '.gif';
      case EpubContentType.IMAGE_SVG:
        return '.svg';
      default:
        return '.jpg';
    }
  }

  /// Gets all chapter content from an EPUB book as HTML strings
  List<EpubChapterContent> getChaptersContent(EpubBook epubBook) {
    final chapters = <EpubChapterContent>[];
    _extractChapters(epubBook.Chapters ?? [], chapters);
    return chapters;
  }

  void _extractChapters(
    List<EpubChapter> chapterList,
    List<EpubChapterContent> result,
  ) {
    for (final chapter in chapterList) {
      if (chapter.HtmlContent != null && chapter.HtmlContent!.isNotEmpty) {
        result.add(EpubChapterContent(
          title: chapter.Title ?? 'Chapter',
          htmlContent: chapter.HtmlContent!,
        ));
      }
      if (chapter.SubChapters != null && chapter.SubChapters!.isNotEmpty) {
        _extractChapters(chapter.SubChapters!, result);
      }
    }
  }

  /// Extracts title and author from EPUB metadata
  Map<String, String> extractMetadata(EpubBook epubBook) {
    final title = epubBook.Title ?? 'Unknown Title';
    final author = epubBook.Author ?? 'Unknown Author';
    return {'title': title, 'author': author};
  }
}

class EpubChapterContent {
  final String title;
  final String htmlContent;

  const EpubChapterContent({
    required this.title,
    required this.htmlContent,
  });
}
