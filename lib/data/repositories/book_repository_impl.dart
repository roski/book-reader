import 'package:hive_flutter/hive_flutter.dart';
import '../../core/constants/app_constants.dart';
import '../../domain/entities/book.dart';
import '../../domain/repositories/book_repository.dart';

class BookRepositoryImpl implements BookRepository {
  Box<Book> get _box => Hive.box<Book>(AppConstants.booksBox);

  @override
  Future<List<Book>> getAllBooks() async {
    return _box.values.toList();
  }

  @override
  Future<Book?> getBookById(String id) async {
    try {
      return _box.values.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> addBook(Book book) async {
    await _box.put(book.id, book);
  }

  @override
  Future<void> updateBook(Book book) async {
    await _box.put(book.id, book);
  }

  @override
  Future<void> deleteBook(String id) async {
    await _box.delete(id);
  }

  @override
  Future<List<Book>> getBooksSortedByLastOpened() async {
    final books = _box.values.toList();
    books.sort((a, b) {
      final aDate = a.lastOpened ?? a.addedAt;
      final bDate = b.lastOpened ?? b.addedAt;
      return bDate.compareTo(aDate);
    });
    return books;
  }
}
