import 'package:flutter_test/flutter_test.dart';
import 'package:book_reader/domain/entities/book.dart';
import 'package:book_reader/domain/entities/reading_settings.dart';

void main() {
  group('Book entity tests', () {
    test('Book should have correct default values', () {
      final book = Book(
        id: 'test-id',
        title: 'Test Book',
        author: 'Test Author',
        filePath: '/path/to/book.epub',
        addedAt: DateTime(2024, 1, 1),
        format: 'epub',
      );

      expect(book.id, 'test-id');
      expect(book.title, 'Test Book');
      expect(book.author, 'Test Author');
      expect(book.readingProgress, 0.0);
      expect(book.lastOpened, isNull);
      expect(book.format, 'epub');
    });

    test('Book copyWith should update fields correctly', () {
      final original = Book(
        id: 'id-1',
        title: 'Original Title',
        author: 'Original Author',
        filePath: '/path/book.epub',
        addedAt: DateTime(2024, 1, 1),
        format: 'epub',
      );

      final updated = original.copyWith(
        title: 'Updated Title',
        readingProgress: 0.5,
      );

      expect(updated.id, 'id-1');
      expect(updated.title, 'Updated Title');
      expect(updated.author, 'Original Author');
      expect(updated.readingProgress, 0.5);
    });
  });

  group('ReadingSettings entity tests', () {
    test('ReadingSettings should have correct defaults', () {
      final settings = ReadingSettings();

      expect(settings.fontFamily, 'Georgia');
      expect(settings.fontSize, 18.0);
      expect(settings.lineSpacing, 1.5);
      expect(settings.theme, ReadingTheme.light);
      expect(settings.readingMode, ReadingMode.scroll);
      expect(settings.textAlignment, TextAlignment.justify);
    });

    test('ReadingSettings copyWith should update fields correctly', () {
      final original = ReadingSettings();
      final updated = original.copyWith(
        fontSize: 22.0,
        themeIndex: ReadingTheme.dark.index,
      );

      expect(updated.fontSize, 22.0);
      expect(updated.theme, ReadingTheme.dark);
      expect(updated.fontFamily, 'Georgia'); // unchanged
    });

    test('ReadingTheme enum should have correct values', () {
      expect(ReadingTheme.values.length, 3);
      expect(ReadingTheme.values, contains(ReadingTheme.light));
      expect(ReadingTheme.values, contains(ReadingTheme.sepia));
      expect(ReadingTheme.values, contains(ReadingTheme.dark));
    });

    test('ReadingMode enum should have correct values', () {
      expect(ReadingMode.values.length, 2);
      expect(ReadingMode.values, contains(ReadingMode.scroll));
      expect(ReadingMode.values, contains(ReadingMode.paginated));
    });
  });

  group('Book sorting tests', () {
    test('Books should be sortable by lastOpened date', () {
      final baseDate = DateTime(2024, 1, 10);
      final books = [
        Book(
          id: '1',
          title: 'Book A',
          author: 'Author A',
          filePath: '/a.epub',
          addedAt: baseDate.subtract(const Duration(days: 3)),
          lastOpened: baseDate.subtract(const Duration(days: 1)),
          format: 'epub',
        ),
        Book(
          id: '2',
          title: 'Book B',
          author: 'Author B',
          filePath: '/b.epub',
          addedAt: baseDate.subtract(const Duration(days: 2)),
          lastOpened: baseDate,
          format: 'epub',
        ),
        Book(
          id: '3',
          title: 'Book C',
          author: 'Author C',
          filePath: '/c.epub',
          addedAt: baseDate.subtract(const Duration(days: 1)),
          format: 'epub',
          // no lastOpened
        ),
      ];

      // Sort by lastOpened (or addedAt if not opened)
      books.sort((a, b) {
        final aDate = a.lastOpened ?? a.addedAt;
        final bDate = b.lastOpened ?? b.addedAt;
        return bDate.compareTo(aDate);
      });

      expect(books.first.id, '2'); // Most recently opened
      expect(books.last.id, '1'); // Opened yesterday
    });
  });
}
