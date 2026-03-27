import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uuid/uuid.dart';
import '../../../data/datasources/epub_datasource.dart';
import '../../../data/repositories/book_repository_impl.dart';
import '../../../domain/entities/book.dart';
import '../../../domain/repositories/book_repository.dart';

final bookRepositoryProvider = Provider<BookRepository>((ref) {
  return BookRepositoryImpl();
});

final epubDataSourceProvider = Provider<EpubDataSource>((ref) {
  return EpubDataSource();
});

final booksProvider =
    AsyncNotifierProvider<BooksNotifier, List<Book>>(BooksNotifier.new);

class BooksNotifier extends AsyncNotifier<List<Book>> {
  @override
  Future<List<Book>> build() async {
    return _loadBooks();
  }

  Future<List<Book>> _loadBooks() async {
    final repo = ref.read(bookRepositoryProvider);
    return repo.getBooksSortedByLastOpened();
  }

  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _loadBooks());
  }

  Future<void> addBookFromFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['epub', 'fb2'],
      allowMultiple: false,
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    final filePath = file.path;
    if (filePath == null) return;

    final format = file.extension?.toLowerCase() ?? 'epub';

    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final id = const Uuid().v4();
      String title = file.name.replaceAll(RegExp(r'\.(epub|fb2)$', caseSensitive: false), '');
      String author = 'Unknown Author';
      String? coverPath;

      if (format == 'epub') {
        final epubDS = ref.read(epubDataSourceProvider);
        final epubBook = await epubDS.parseEpub(filePath);
        if (epubBook != null) {
          final metadata = epubDS.extractMetadata(epubBook);
          title = metadata['title'] ?? title;
          author = metadata['author'] ?? author;
          coverPath = await epubDS.extractCoverImage(epubBook, id);
        }
      }

      final book = Book(
        id: id,
        title: title,
        author: author,
        filePath: filePath,
        coverImagePath: coverPath,
        addedAt: DateTime.now(),
        format: format,
      );

      final repo = ref.read(bookRepositoryProvider);
      await repo.addBook(book);
      return _loadBooks();
    });
  }

  Future<void> deleteBook(String id) async {
    final repo = ref.read(bookRepositoryProvider);
    await repo.deleteBook(id);
    await refresh();
  }

  Future<void> updateReadingProgress(
    String bookId,
    double progress, {
    int? currentPage,
    int? totalPages,
    String? lastCfiPosition,
  }) async {
    final repo = ref.read(bookRepositoryProvider);
    final book = await repo.getBookById(bookId);
    if (book == null) return;

    final updatedBook = book.copyWith(
      readingProgress: progress,
      lastOpened: DateTime.now(),
      currentPage: currentPage,
      totalPages: totalPages,
      lastCfiPosition: lastCfiPosition,
    );

    await repo.updateBook(updatedBook);
    await refresh();
  }
}
